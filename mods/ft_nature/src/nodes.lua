local Block = ft.block
local Registries = ft.registry

local function create_tree_wood_type(name, def)
    local top = def.top or "log_top.png"
    local side = def.side or "log_side.png"
    local planks = def.planks or "planks.png"
    local light = def.light
    local dark = def.dark
    local tint = def.tint

    local top_texture = top.."^[multiply:"..light
    local side_texture = side.."^[multiply:"..dark

    local log_block = Block()
    log_block.textures = { top, top, side, side, side, side }
    log_block.description = name.." Log"
    log_block:tag("soft", 3)
    log_block:register(name.."_log")

    local planks_block = Block()
    planks_block.textures = planks.."^[multiply:"..tint
    planks_block.description = name.." Planks"
    planks_block:tag("soft", 3)
    planks_block:register(name.."_planks")
end

local function create_flora(name, texture)
    local flora = Block()
    flora.textures = texture
    flora.description = name
    flora:prop("walkable", false)
    flora:prop("buildable_to", true)
    flora:prop("paramtype", "light")
    flora:prop("sunlight_propagates", true)
    flora:prop("drawtype", "plantlike")
    flora:prop("waving", math.random(1, 3))
    flora:tag("soft", 3)
    flora:register(name)
end

local function create_detail(name, texture)
    local detail = Block()
    detail.textures = texture
    detail.description = name
    detail:prop("walkable", false)
    detail:prop("buildable_to", false)
    detail:prop("paramtype", "light")
    detail:prop("sunlight_propagates", true)
    detail:prop("drawtype", "plantlike")
    detail:tag("soft", 3)
    detail:register(name)
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

create_tree_wood_type("Oak", {
    light="#CCA352",
    dark="#665229",
    tint="#B38F47"
})
create_tree_wood_type("Birch", {
    light="#b3b3b3",
    dark="#b3b3b3",
    tint="#a1a1a1"
})

-- Flora

create_flora("Tall Grass", "tall_grass.png^[multiply:#0ff03a")
create_flora("Red Flower", "red_flower.png")

-- Details

create_detail("Small Rock", "small_rock.png")

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