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
    local parse_kind_fn = self["parse_"..kind]
    
    if parse_kind_fn then
        return parse_kind_fn(self, graph)
    end

    return graph.new("null")
end

function parser:parse_iden(graph)
    local name = self:eat().data
    local args = {}

    while self.token.data ~= ';' do
        table.insert(args, self:parse_kind(graph))
    end
    self:eat() -- ;
    
    return graph.new("inst", {
        name = name,
        args = args
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

function parser:parse_label(graph)
    return graph.new("label", {
        name = self:eat().data
    })
end

function parser:parse_var(graph)
    return graph.new("variable", {
        name = self:eat().data
    })
end

function parser:parse_preproc(graph)
    local preproc = preprocs[self.token.data]
    if preproc then
        self:eat()
        return preproc(self, graph)
    end

    return graph.new("null")
end

return parser.new