local Item = class "Item" {}

function Item:init(name)
    self.description = ""
    self.texture = "NaN.png"
    self.is_tool = false
    self.events = {}
    self.props = {}
    self.tags = {}

    self._instance = nil
    self._identity = nil
    self._name = name
end

function Item:__tostring()
    return self._name
end

function Item:instance()
    return self._instance
end

function Item:identity()
    return self._identity
end

function Item:name()
    return self._name
end

function Item:event(event, callback)
    if not self.events[event] then
        self.events[event] = {}
    end
    table.insert(self.events[event], callback)
    return self
end

function Item:tag(tag, value)
    self.tags[tag] = value
end

function Item:prop(key, value)
    self.props[key] = value
end

function Item:register(name)
    ft.registry.ITEM:register(name, self)
    return self
end

return Item