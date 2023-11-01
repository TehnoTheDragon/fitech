local Biome = class "Biome" {}

function Biome:init(data)
    self.data = data

    self._instance = nil
    self._identity = nil
    self._name = nil
end

function Biome:__tostring()
    return self._name
end

function Biome:register(name)
    ft.registry.BIOME:register(name, self)
    return self
end

return Biome