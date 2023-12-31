local function create_config()
    local settings = minetest.settings
    local config = {}

    function config:get(key, orValue)
        return settings:get(key) or orValue
    end

    function config:boolean(key, orValue)
        return settings:get_bool(key, orValue)
    end

    function config:noise(key, orValue)
        return settings:get_np_group(key) or orValue
    end

    function config:get_flags(key)
        return settings:get_flags(key)
    end

    function config:table()
        return settings:to_table()
    end

    return config
end

_G.ft = {}

ft.config = create_config()
ft.mod_name = minetest.get_current_modname
ft.world_path = minetest.get_worldpath
function ft.vargs_to_message(...)
    local vargs = {...}
    local vargc = #vargs

    if vargc <= 0 then
        return ""
    end

    if vargc == 1 then
        return tostring(vargs[1])
    end

    local message = ""
    for index, value in pairs(vargs) do
        message = ("%s%1s"):format(message, tostring(value) or "nil")
        if index < vargc then
            message = message .. " "
        end
    end

    return message
end
function ft.debug(...)
    minetest.debug(ft.vargs_to_message(...))
end
function ft.log(...)
    minetest.log(ft.vargs_to_message(...))
end
print = ft.log

function ft.namespace(namespace, ...)
    local namespace = namespace:gsub("%s+", "_"):lower()

    local subspace = ft.vargs_to_message(...):lower():gsub("%s+", "_")
    if subspace:len() > 0 then
        subspace = subspace .. "_"
    end

    return function(name)
        return ("%s:%s"):format(namespace, subspace .. name:gsub("%s+", "_"):lower())
    end
end

function ft.get_dirs(path)
    return minetest.get_dir_list(path, true)
end

function ft.get_files(path)
    return minetest.get_dir_list(path, false)
end

function ft.mod_path(modname)
    return minetest.get_modpath(modname ~= nil and modname or minetest.get_current_modname())
end

function ft.mod_load(path)
    return dofile(("%s/%s"):format(minetest.get_modpath(minetest.get_current_modname()), path))
end

function ft.mod_path_get(path)
    return ("%s/%s"):format(minetest.get_modpath(minetest.get_current_modname()), path)
end

function ft.read_file(path, mode)
    local file = io.open(path, mode or "r")
    local content = file:read('a')
    file:close()
    return content
end

function ft.write_file(path, mode, content)
    local file = io.open(path, mode or "w")
    file:write(content)
    file:flush()
    file:close()
end

function ft.is_file_exist(path)
    local file = io.open(path)
    if file == nil then
        return false
    end
    file:close()
    return true
end

function ft.bulk_load(container, rootpath)
    local function load(container, path)
        local files = ft.get_files(path)
        for _, filename in pairs(files) do
            local value = dofile(("%s/%s"):format(path, filename))
            container[filename:sub(1, -5)] = value
        end
        local dirs = ft.get_dirs(path)
        for _, dir in pairs(dirs) do
            container[dir] = container[dir] or {}
            load(container[dir], ("%s/%s"):format(path, dir))
        end
    end

    local container = container or {}

    load(container, rootpath)

    return container
end

local function _preload()
    ft.registered_recipe_types = {}
    ft.registered_recipes = {}

    _G.class = ft.mod_load("vendors/nex/nex.lua")
end

local function _afterload()
    ft.mod_load("afterload/minetest_recipes_2_ft_recipes.lua")
    ft.mod_load("afterload/rich_tooltip.lua")
end

_preload()
ft.bulk_load(ft, ft.mod_path_get("src"))
_afterload()