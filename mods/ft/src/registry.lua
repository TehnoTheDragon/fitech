local Registry = class "Registry" {}

function Registry:init(constructor, ...)
    self._constructor = constructor
    self._subspace = {...}
end

function Registry:register(name, object, ...)
    return self._constructor(ft.namespace(ft.mod_name(), unpack(self._subspace), ...)(name), object)
end

local Registries = {}

Registries.ITEM = Registry(function(name, data)
    
end, "item")

Registries.BLOCK = Registry(function(name, data)
    local def = {}

    def.description = data.description
    def.tiles = type(data.textures) == "table" and data.textures or {data.textures}
    def.groups = data.tags

    for i,v in pairs(data.events) do def[i] = v end
    for i,v in pairs(data.props) do def[i] = v end

    local instance = minetest.register_node(name, def)

    data._instance = instance
    data._identity = minetest.get_content_id(name)
    data._name = name

    return instance
end, "block")

Registries.BIOME = Registry(function(name, data)
    local def = {}

    def = data.data
    def.name = name

    local instance = minetest.register_biome(def)

    data._instance = instance
    data._identifier = minetest.registered_biomes[name]
    data._name = name

    return instance
end, "biome")

Registries.DECORATION = Registry(function(name, data)
    
end, "decoration")

return Registries