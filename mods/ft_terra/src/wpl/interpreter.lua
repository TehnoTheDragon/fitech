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
    ftt.load_plugin(self.name)
    local plugin_container = ftt.plugins[self.name]
    local state_plugin = {}
    for k,v in pairs(plugin_container.methods) do
        state_plugin[k] = v
    end
    for k,v in pairs(plugin_container.constants) do
        state_plugin[k] = v
    end
    state[self.name] = state_plugin
end

function visitor:defvar(state)
    state[self.name] = visitor.visit(self.value, state)
end

function visitor:lua(state)
    local fEnv = getfenv(self.fn)
    for k,v in pairs(state) do
        fEnv[k] = v
    end
    
    return function(data)
        local wpl = {}
        fEnv.wpl = wpl

        for k,v in pairs(data) do
            fEnv[k] = v
        end
        setfenv(self.fn, fEnv)

        self.fn()
        
        return wpl
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