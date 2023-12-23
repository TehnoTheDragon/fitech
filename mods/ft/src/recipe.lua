local RecipeType = class "RecipeType" {}

function RecipeType:init()
    self._validate = function(def) return false end
    self._transform = function(def) return def end
end

function RecipeType:__tostring()
    return self._name
end

function RecipeType:name()
    return self._name
end

--- validate function which get a definition of recipe which must not be modified and return boolean value if that recipe is valid, may provide string as second return value to explain invalidation
---@param validate (table, string, string): (boolean, string?)
function RecipeType:validate(validate)
    self._validate = validate
    return self
end

--- transform function which get a definition of recipe which can be modified or do some action and must return it back
---@param transform (table): table
function RecipeType:transform(transform)
    self._transform = transform
    return self
end

function RecipeType:register(name)
    ft.registry.RECIPE_TYPE:register(name, self)
    return self
end

local Recipe = class "Recipe" {}

function Recipe:init(type, recipe)
    self.type = type
    self.recipe = recipe
end

function Recipe:__tostring()
    return self._name
end

function Recipe:name()
    return self._name
end

function Recipe:register(name)
    ft.registry.RECIPE:register(name, self)
    return self
end

return {
    RecipeType = RecipeType,
    Recipe = Recipe,
}