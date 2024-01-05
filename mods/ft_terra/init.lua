_G.ftt = {}
ftt.plugins = {}

local PRESENTS_PATH = ft.mod_path_get("presents")
local PRESENT_DEFINITION_TABLE = minetest.parse_json(ft.read_file(("%s/%s.json"):format(PRESENTS_PATH, ft.config:get("fitech_world_generation_present", "test"))))

function ftt.load_plugin(plugin_name)
    assert(plugin_name:find("%s+") == nil, ("Plugin name `%s` must not contain spaces in it's name"):format(plugin_name))

    if ftt.plugins[plugin_name] ~= nil then
        error(("Plugin name collision. Plugin with name `%s` already exist"):format(plugin_name))
    end

    local plugin = {}
    plugin.storage = {}
    plugin.methods = {}
    plugin.constants = {}

    local module = ft.mod_load(("plugins/%s.lua"):format(plugin_name))
    module:_init(plugin.storage)

    ftt.plugins[plugin_name] = plugin
    for k, v in pairs(module) do
        if k:sub(1, 1) ~= '_' then
            local t = type(v)
            if t == "function" then
                plugin.methods[k] = v
            else
                plugin.constants[k] = v
            end
        end
    end

    function plugin.call(method, ...)
        plugin.methods[method](plugin.storage, ...)
    end
end

function ftt.load_plugins(plugins_name)
    for _, plugin_name in pairs(plugins_name) do
        ftt.load_plugin(plugin_name)
    end
end

-- local c_air = minetest.get_content_id('air')
-- local c_stone = minetest.get_content_id('mapgen_stone')
-- local c_grass = minetest.get_content_id('ft_nature:block_grass')
-- local c_dirt = minetest.get_content_id('ft_nature:block_dirt')

-- local terrain_noise = {
--     offset = 0.0,
--     scale = 1.0,
--     spread = { x = 72, y = 45, z = 72 },
--     seed = 576834,
--     octaves = 5,
--     persistence = 0.7,
--     lacunarity = 1.5,
--     flags = "eased"
-- }

-- function ftt.shaping(gen, shared)
--     local height_map = gen.get_perlin_map_3d(terrain_noise)

--     gen.mapping(function(x, y, z, vid, xslice)
--         local density = height_map[xslice]
--         local gradient = gen.gradient(y, 32)
--         if density + gradient > 0 then
--             gen.set(vid, c_stone)
--         end
--     end)
-- end

-- function ftt.paining(gen, shared)
--     gen.for3d(function(x, y, z)
--         local vid = gen.index(x, y, z)
--         if gen.data[vid] == c_stone and gen.data[gen.index(x, y + 1, z)] == c_air and y > -(math.random(1, 2) + 32) then
--             gen.data[vid] = c_grass

--             for i = 1, math.random(3, 5) do
--                 local vid = gen.index(x, y-i, z)
--                 if gen.data[vid] == c_stone and gen.data[gen.index(x, y - i, z)] == c_stone then
--                     gen.data[vid] = c_dirt
--                 end
--             end
--         end
--     end)
-- end

-- function ftt.featuring(gen, shared)
    
-- end

local Present = ft.mod_load("src/present.lua")(PRESENT_DEFINITION_TABLE)

function ftt.pipeline(gen)
    Present:generate(gen)
end

ft.mod_load("src/gen.lua")