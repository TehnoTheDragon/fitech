ft.registered_recipe_types = {}
ft.registered_recipes = {}

local Registry = ft.registry
Registry._custom("RECIPE_TYPE", function(name, data)
    
end)
Registry._custom("RECIPE", function(name, data)
    
end)

local RecipeType = class "RecipeType" {}

function RecipeType:init()
    
end

function RecipeType:register(name)
    Registry.RECIPE_TYPE:register(name, self)
end

local Recipe = class "Recipe" {}

function Recipe:init(recipeType)
    self._recipeType = recipeType
end

function RecipeType:register(name)
    Registry.RECIPE:register(name, self)
end

return {
    RecipeType = RecipeType,
    Recipe = Recipe,
}