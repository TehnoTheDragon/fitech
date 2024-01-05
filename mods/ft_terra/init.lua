_G.ftt = {}
ftt.plugins = {}

local PRESENTS_PATH = ft.mod_path_get("presents")
local PRESENT_SELECTED = ft.config:get("fitech_world_generation_present", "test")
local PRESENT_DEFINITION_TABLE = minetest.parse_json(ft.read_file(("%s/%s.json"):format(PRESENTS_PATH, PRESENT_SELECTED)))

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

-- Loading

-- ft.write_file(PRESENTS_PATH.."/test.bin", "wb", table.concat({"hello", string.char(253)}, ""))

local Present = ft.mod_load("src/present.lua")(PRESENT_SELECTED, PRESENT_DEFINITION_TABLE)

function ftt.pipeline(gen)
    Present:generate(gen)
end

ft.mod_load("src/gen.lua")