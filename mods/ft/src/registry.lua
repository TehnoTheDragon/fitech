local Registry = class "Registry" {}

function Registry:init(constructor, ...)
    self._constructor = constructor
    self._subspace = {...}
end

function Registry:register(name, object, ...)
    return self._constructor(ft.namespace(ft.mod_name(), unpack(self._subspace), ...)(name), object)
end

local Registries = {}

function Registries._custom(type, fn)
    assert(type ~= "_custom", "_custom is reserved function and cannot be used as registry type!")
    Registries[type] = Registry(fn, type)
end

Registries.ITEM = Registry(function(name, data)
    local def = {}

    def.description = data.description
    def.inventory_image = data.texture
    def.groups = data.tags

    for i, callbacks in pairs(data.events) do
        def[i] = function(...)
            for _, callback in pairs(callbacks) do
                callback(...)
            end
        end
    end
    for i, v in pairs(data.props) do def[i] = v end

    local instance

    if data.is_tool then
        instance = minetest.register_tool(name, def)
    else
        instance = minetest.register_craftitem(name, def)
    end

    data._instance = instance
    data._identity = minetest.get_content_id(name)
    data._name = name

    return instance
end, "item")

Registries.BLOCK = Registry(function(name, data)
    local def = {}

    def.description = data.description
    def.tiles = type(data.textures) == "table" and data.textures or {data.textures}
    def.groups = data.tags

    for i, callbacks in pairs(data.events) do
        def[i] = function(...)
            for _, callback in pairs(callbacks) do
                callback(...)
            end
        end
    end
    for i, v in pairs(data.props) do def[i] = v end

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

Registries.RECIPE_TYPE = Registry(function(name, data)
    local def = {}

    def.validate = data._validate
    def.transform = data._transform

    ft.registered_recipe_types[name] = def
    ft.registered_recipes[name] = {}

    data._name = name
end)
Registries.RECIPE = Registry(function(name, data)
    local recipeType = ft.registered_recipe_types[data.type]
    assert(recipeType ~= nil, ("No recipe type `%s` was found"):format(data.type))

    local valid, message = recipeType.validate(data.recipe, name, data.type)
    assert(valid, message or ("Invalid recipe: `%s` for recipe-type: `%s`"):format(name, data.type))
    local def = recipeType.transform(data.recipe)

    ft.registered_recipes[data.type][name] = def

    data._name = name
end)

return Registries