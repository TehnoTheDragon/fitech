local graph = {}

function graph.new(kind, data)
    assert(type(kind) == "string", "`kind` type can only be string")
    assert(type(data) == "table" or data == nil, "`data` type can only be table or nil")
    local self = data or {}
    self.kind = kind
    return setmetatable(self, {__index = graph})
end

function graph:get(index)
    if not self.children then
        return nil
    end
    return self.children[index]
end

function graph:append(kind, data)
    return self:add(graph.new(kind, data))
end

function graph:add(node)
    if not self.children then
        self.children = {}
    end
    table.insert(self.children, node)
    return node
end

local preprocs = {}
local parser = {}

function parser.new(tokenizer)
    local self = {}
    self.graph = graph.new("compound")
    self.tokenizer = tokenizer
    self.token = tokenizer:next()
    self.ptoken = self.token
    self.preproc_maps = {}
    return setmetatable(self, {__index = parser})
end

function parser:append(kind, data)
    return self.graph:append(kind, data)
end

function parser:eat()
    self.ptoken = self.token
    self.token = self.tokenizer:next()
    return self.ptoken
end

function parser:require(x, T)
    if T == "kind" then
        assert(self.token.kind == x, ("Expected token kind `%s` found `%s`"):format(x, self.token.kind))
    else
        assert(self.token.data == x, ("Expected token data `%s` found `%s`"):format(x, self.token.kind))
    end
end

function parser:is(x, T)
    return T == "kind" and self.token.kind == x or self.token.data == x
end

function parser:parse()
    local lasttoken = nil
    while self.token.kind ~= "eof" do
        if self.token.kind == "error" then
            error(self.token.data)
            break
        end

        if lasttoken == self.token then
            break
        end
        lasttoken = self.token

        local node = self:parse_kind(self.graph)
        if node.kind ~= "null" then
            self.graph:add(node)
        end
    end
    return self.graph
end

function parser:parse_kind(graph)
    local kind = self.token.kind

    if kind == "iden" then
        return self:parse_iden(graph)
    elseif kind == "num" then
        return self:parse_num(graph)
    elseif kind == "str" then
        return self:parse_str(graph)
    elseif kind == "open_bracket" then
        return self:parse_table(graph)
    elseif kind == "preproc" then
        return self:parse_preproc(graph)
    end

    return graph.new("null")
end

function parser:parse_iden(graph)
    local name = self:eat().data
    local value = self:parse_kind(graph)
    
    return graph.new("defvar", {
        name = name,
        value = value
    })
end

function parser:parse_num(graph)
    return graph.new("number", {
        value = tonumber(self:eat().data)
    })
end

function parser:parse_str(graph)
    return graph.new("string", {
        value = self:eat().data
    })
end

function parser:parse_table(graph)
    self:eat() -- {

    local table = graph.new("table")
    while self.token.kind ~= "close_bracket" do
        table:add(self:parse_kind(table))
    end

    self:require("close_bracket", "kind")
    self:eat() -- }
    return table
end

function parser:parse_preproc(graph)
    local preproc = preprocs[self.token.data]
    if preproc then
        self:eat()
        return preproc(self, graph)
    end

    return self:parse_preproc_map_call(graph)
end

function parser:parse_preproc_map_call(graph)
    local function get_value_from_token()
        if self.token.kind == "str" then
            return self:eat().data
        elseif self.token.kind == "num" then
            return tonumber(self:eat().data)
        end

        return nil
    end

    local map = self.preproc_maps[self:eat().data]
    local args = {}

    self:require("(") self:eat()
    if not self:is(")") then
        table.insert(args, get_value_from_token())
        if self:is(",") then
            for i = 1, #map[1] do
                if i < #map[1] then
                    self:require(",") self:eat()
                end
                table.insert(args, get_value_from_token())
            end
        end
    end
    self:require(")") self:eat()

    local source = map[2]
    for i, v in pairs(map[1]) do
        source = source:gsub("$"..v, tostring(args[i]))
    end

    return parser.new(self.tokenizer.new(source)):parse():get(1)
end

function preprocs:map(graph)
    local name = self:eat().data
    local args = {}
    local block = ""

    -- getting arguments
    self:require("(")
    self:eat()

    table.insert(args, self:eat().data)

    while self.token.data == ',' do
        self:eat()
        table.insert(args, self:eat().data)
    end

    self:require(")")
    self:eat()

    -- getting block
    self:require("=") self:eat()
    self:require(">") self:eat()
    self:require("{") self:eat()
    block = block .. "{"
    while self.token.data ~= '}' do
        if self.token.kind == "const" then
            block = block .. "$" .. self:eat().data .. " "
        else
            block = block .. self:eat().data .. " "
        end
    end
    block = block .. "}"
    self:require("}") self:eat()

    self.preproc_maps[name] = {args, block}

    return graph.new("null")
end

function preprocs:plugin(graph)
    self:require("(") self:eat()
    self:require("str", "kind")
    local name = self:eat().data
    self:require(")") self:eat()
    
    return graph.new("load_plugin", {
        name = name
    })
end

function preprocs:lua(graph)
    self:require("(") self:eat()
    self:require("str", "kind")
    local source = self:eat().data
    self:require(")") self:eat()

    local fn = loadstring(source)
    setfenv(fn, {
        print = print,
        math = math,
        noise = function(def)
            local noise = minetest.get_perlin(def)
            return function(x, y, z)
                return z == nil and noise:get_2d({x = x, y = y}) or noise:get_3d({x = x, y = y, z = z})
            end
        end
    })
    
    return graph.new("lua", {
        fn = fn
    })
end

return parser.new