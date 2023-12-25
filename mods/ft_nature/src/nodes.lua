local Block = ft.block
local Registries = ft.registry

local function create_tree_wood_type(name, light, dark, plankColor)
    local log_block = Block()
    log_block.textures = {
        "log_top.png^[multiply:"..light,
        "log_top.png^[multiply:"..light,
        "log_side.png^[multiply:"..dark,
        "log_side.png^[multiply:"..dark,
        "log_side.png^[multiply:"..dark,
        "log_side.png^[multiply:"..dark
    }
    log_block.description = name.." Log"
    log_block:tag("soft", 3)
    log_block:register(name:lower().."_log")

    local planks_block = Block()
    planks_block.textures = "planks.png^[multiply:"..plankColor
    planks_block.description = name.." Planks"
    planks_block:tag("soft", 3)
    planks_block:register(name:lower().."_planks")
end

-- Solid Blocks

local stone_block = Block()
stone_block.textures = "stone.png"
stone_block.description = "Stone"
stone_block:register("stone")
stone_block:tag("hard", 1)
minetest.register_alias("mapgen_stone", stone_block:name())

local dirt_block = Block()
dirt_block.textures = "dirt.png"
dirt_block.description = "Dirt"
dirt_block:tag("soft", 3)
dirt_block:register("dirt")

local grass_block = Block()
grass_block.textures = {
    "grass_top.png^[multiply:#0ff03a",
    "dirt.png",
    "dirt.png^(grass_side.png^[multiply:#0ff03a)",
    "dirt.png^(grass_side.png^[multiply:#0ff03a)",
    "dirt.png^(grass_side.png^[multiply:#0ff03a)",
    "dirt.png^(grass_side.png^[multiply:#0ff03a)"
}
grass_block.description = "Grass"
grass_block:tag("soft", 3)
grass_block:register("grass")

create_tree_wood_type("Oak", "#CCA352", "#665229", "#B38F47")
create_tree_wood_type("Birch", "#b3b3b3", "#b3b3b3", "#a1a1a1")

-- Flora

local tall_grass = Block()
tall_grass.textures = "tall_grass.png^[multiply:#0ff03a"
tall_grass.description = "Tall Grass"
tall_grass:prop("walkable", false)
tall_grass:prop("buildable_to", true)
tall_grass:prop("paramtype", "light")
tall_grass:prop("sunlight_propagates", true)
tall_grass:prop("drawtype", "plantlike")
tall_grass:tag("soft", 3)
tall_grass:register("tall_grass")

-- Test Biome

local Biome = ft.biome

local plains_biome = Biome({
    node_top = grass_block:name(),
    depth_top = 1,
    node_filler = dirt_block:name(),
    depth_filler = 3,
    y_max = 31000,
    y_min = -10
}):register("plains")

ft.log(stone_block, dirt_block, grass_block, tall_grass, plains_biome)