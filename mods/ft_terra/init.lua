_G.ftt = {}
ftt.plugins = {}

local terra = ft_cfg.get_workspace()
local terra_plugins = terra:request_folder("plugins")
local terra_presents = terra:request_folder("presents")

local PRESENT_SELECTED = ft.config:get("fitech_world_generation_present", "test")

function ftt.load_plugin(plugin_name)
    assert(plugin_name:find("%s+") == nil, ("Plugin name `%s` must not contain spaces in it's name"):format(plugin_name))

    if ftt.plugins[plugin_name] ~= nil then
        return
    end

    local plugin_container = {}
    plugin_container.methods = {}
    plugin_container.constants = {}
    
    local source = terra_plugins:request_read_file(plugin_name, "lua")
    assert(source ~= nil, ("Plugin `%s` not found by path: `%s`"):format(plugin_name, terra_plugins:get_path() .. plugin_name .. ".lua"))

    local plugin = loadstring(source, plugin_name)()
    local module = plugin.module
    
    ftt.load_plugins(plugin.depends or {})
    module:_init()
    
    for k, v in pairs(plugin.module) do
        if k:sub(1, 1) ~= '_' then
            local t = type(v)
            if t == "function" then
                plugin_container.methods[k] = v
            else
                plugin_container.constants[k] = v
            end
        end
    end
    
    function plugin_container.call(method, ...)
        plugin_container.methods[method](module, ...)
    end
    
    plugin_container.post_init = function(pdt) module:_post(pdt) plugin_container.post_init = nil end
    ftt.plugins[plugin_name] = plugin_container
end

function ftt.load_plugins(plugins_name)
    for _, plugin_name in pairs(plugins_name) do
        ftt.load_plugin(plugin_name)
    end
end

-- Loading

local tokenizer = ft.mod_load("src/wpl/tokenizer.lua")
local parser = ft.mod_load("src/wpl/parser.lua")
local interpret = ft.mod_load("src/wpl/interpreter.lua")

local SUCCESS, PRESENT_CONTENT = pcall(function()
    return terra_presents:request_read_file(PRESENT_SELECTED, "wpl")
end)
assert(SUCCESS, ("Error during trying read `%s`! Probably the file is not exist anymore."):format(terra_presents:get_path() .. PRESENT_SELECTED .. ".wpl"))

local ast = parser(tokenizer(PRESENT_CONTENT)):parse()
local state = interpret(ast)

ft.mod_load("src/gen.lua")

-- local Present = ft.mod_load("src/present.lua")(PRESENT_SELECTED, PRESENT_DEFINITION_TABLE)

minetest.register_on_generated(function(pmin, pmax, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local gen = ftt.create_gen(pmin, pmax, emin, emax, seed, vm)

    gen.mapping(function(x, y, z, vid, dt)
        local gp = gen.globali(vid)
        state.generator({
            x = gp.x,
            y = gp.y,
            z = gp.z,
        })
        if state.set then
            gen.set(vid, state.set)
        end
    end)

    -- gen.mapping(function(x, y, z, vid, dt)
    --     local gp = gen.globali(vid)
    --     if gp.y <= 0 then
    --         gen.set(vid, 2)
    --     end
    --     if gp.y >= 1 and gp.y <= math.ceil(math.cos(gp.x / 8) * 30) then
    --         gen.set(vid, 3)
    --         gen.set(vid + gen.ystride, 4)
    --     end
    -- end)

    gen.mark_dirty()
end)