local bytecode = ft.mod_load("src/psm/bytecode.lua")
local visitors = {}
local bytecodegen = {}

function bytecodegen.new(graph)
    local self = {}
    self.graph = graph
    self.bytecode = ft_extra.buffer()
    return setmetatable(self, {__index = bytecodegen})
end

function bytecodegen:put(...)
    self.bytecode:put(...)
end

function bytecodegen:generate()
    self:visit(self.graph)
end

function bytecodegen:visit(node)
    local visit = visitors[node.kind]
    assert(visit ~= nil, ("Invalid `%s` node kind"):format(node.kind))
    visit(self, node)
end

function visitors:compound(node)
    for _, child in pairs(node.children) do
        self:visit(child)
    end
end

function visitors:inst(node)
    local code = bytecode.S2C[node.name]
    self:put(code)
    for _, arg in pairs(node.args) do
        self:visit(arg)
    end
end

function visitors:variable(node)
    self:put('0xEF')
end

function visitors:number(node)
    self:put(node.value)
end

function visitors:string(node)
    self:put(node.value)
end

return function (graph)
    local bcg = bytecodegen.new(graph)
    bcg:generate()
    return bcg.bytecode:str()
end