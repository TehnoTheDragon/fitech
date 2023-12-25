local Block = class "Block" {}

function Block:init()
    self.description = ""
    self.textures = "NaN.png"
    self.events = {}
    self.props = {}
    self.tags = {}

    self._instance = nil
    self._identity = nil
    self._name = nil
end

function Block:__tostring()
    return self._name
end

function Block:instance()
    return self._instance
end

function Block:identity()
    return self._identity
end

function Block:name()
    return self._name
end

function Block:event(event, callback)
    if not self.events[event] then
        self.events[event] = {}
    end
    table.insert(self.events[event], callback)
    return self
end

function Block:tag(tag, value)
    self.tags[tag] = value
end

function Block:prop(key, value)
    self.props[key] = value
end

function Block:register(name)
    ft.registry.BLOCK:register(name, self)
    return self
end

return Block