local RecipeType = ft.recipe.RecipeType

-- type: shaped | shapeless
RecipeType()
:validate(function(def)
    local valid_type = def.type == "shaped" or def.type == "shapeless"
    local has_output = def.output ~= nil
    local has_recipe = def.recipe ~= nil
    return valid_type and has_output and has_recipe
end)
:transform(function(def)
    minetest.register_craft(def)
    return def
end)
:register("mt_craft")

-- type: cooking
RecipeType()
:validate(function(def)
    local has_output = def.output ~= nil
    local has_recipe = def.recipe ~= nil
    local has_cooktime = def.cooktime ~= nil
    return has_output and has_recipe and has_cooktime
end)
:transform(function(def)
    minetest.register_craft({
        type = "cooking",
        recipe = def.recipe,
        output = def.output,
        replacements = def.replacements
    })
    return def
end)
:register("mt_cook")

-- type: fuel
RecipeType()
:validate(function(def)
    local has_recipe = def.recipe ~= nil
    local has_burntime = def.burntime ~= nil
    return has_recipe and has_burntime
end)
:transform(function(def)
    minetest.register_craft({
        type = "fuel",
        recipe = def.recipe,
        burntime = def.burntime,
        replacements = def.replacements
    })
    return def
end)
:register("mt_fuel")

-- type: toolrepair
RecipeType()
:validate(function(def)
    local has_additional_wear = def.additional_wear ~= nil
    return has_additional_wear
end)
:transform(function(def)
    minetest.register_craft({
        type = "toolrepair",
        additional_wear = def.additional_wear,
    })
    return def
end)
:register("mt_toolrepair")