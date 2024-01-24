local visitor = {}
local iterpreter = {}

function visitor:visit(state)
    local visit = visitor[self.kind]
    assert(visit ~= nil, ("Invalid `%s` node kind"):format(self.kind))
    return visit(self, state)
end

function visitor:compound(state)
    local container = {}
    for _, child in pairs(self.children) do
        local result = visitor.visit(child, state)
        if result then
            table.insert(container, result)
        end
    end
    return container
end

function visitor:load_plugin(state)
    
end

function visitor:defvar(state)
    state[self.name] = visitor.visit(self.value, state)
end

function visitor:lua(state)
    local fEnv = getfenv(self.fn)
    fEnv.math = math
    local wpl = {}
    fEnv.wpl = wpl
    for k,v in pairs(state) do
        fEnv[k] = v
    end
    setfenv(self.fn, fEnv)
    return function(data)
        for k,v in pairs(data) do
            fEnv[k] = v
        end
        self.fn()
        for k,v in pairs(wpl) do
            state[k] = v
        end
    end
end

function visitor:table(state)
    local container = {}
    for _, child in pairs(self.children) do
        container[child.name] = visitor.visit(child.value, container)
    end
    return container
end

function visitor:string(state)
    return self.value
end

function visitor:number(state)
    return self.value
end

return function(graph, state)
    local state = state or {}
    visitor.visit(graph, state)
    return state
end