local Block = ft.block
local Registries = ft.registry

-- Solid Blocks

local stone_block = Block()
stone_block.textures = "stone.png"
stone_block.description = "Stone"
stone_block:register("stone")
minetest.register_alias("mapgen_stone", stone_block:name())

local dirt_block = Block()
dirt_block.textures = "dirt.png"
dirt_block.description = "Dirt"
dirt_block:register("dirt")

local grass_block = Block()
grass_block.textures = {
    "grass_top.png",
    "dirt.png",
    "grass_side.png",
    "grass_side.png",
    "grass_side.png",
    "grass_side.png"
}
grass_block.description = "Grass"
grass_block:register("grass")

-- Flora

local tall_grass = Block()
tall_grass.textures = "tall_grass.png"
tall_grass.description = "Tall Grass"
tall_grass:prop("walkable", false)
tall_grass:prop("buildable_to", true)
tall_grass:prop("paramtype", "light")
tall_grass:prop("sunlight_propagates", true)
tall_grass:prop("drawtype", "plantlike")
tall_grass:register("tall_grass")

-- Test

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

local tall