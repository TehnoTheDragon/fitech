local function parse_keys(unfiltered_keys)
    local keys = {}
    for key, name in pairs(unfiltered_keys) do
        keys[key] = minetest.get_content_id(name)
    end
    return keys
end

local Assembly = ft.mod_load("src/assembly.lua")

local Present = {}
Present.__index = Present

-- local terrain_noise = {
--     offset = 0.5,
--     scale = 1.0,
--     spread = { x = 72, y = 46, z = 72 },
--     seed = 576834,
--     octaves = 5,
--     persistence = 0.7,
--     lacunarity = 1.5,
--     flags = "eased"
-- }

function Present:generate(gen)
    -- local c_stone = minetest.get_content_id("mapgen_stone")
    -- local tnm = gen.get_perlin_map_3d(terrain_noise)
    
    -- gen.mapping(function(x, y, z, vid, xslice)
    --     local gpos = gen.globali(vid)

    --     if tnm[xslice] ^ 1.05 + gen.gradient(y, 32) >= 0 then
    --         gen.set(vid, c_stone)
    --     end
    -- end)

    -- gen.mark_dirty()
end

return function(filename, present_definition_table)
    if present_definition_table.plugins then
        ftt.load_plugins(present_definition_table.plugins)
    end

    local self = {}
    self.keys = parse_keys(present_definition_table.keys)
    self.noises = present_definition_table.noises
    self.assembly = Assembly(filename, present_definition_table.assembly)

    self.assembly()

    return setmetatable(self, Present)
end