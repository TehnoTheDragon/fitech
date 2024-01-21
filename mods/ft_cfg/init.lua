local NOT_TRUSTED_MESSAGE = ("Mod won't work without being in trusted. It won't be able to create folders and files inside minetest root folder.")

local fmt = string.format
local ROOT_PATH = minetest.get_worldpath() ROOT_PATH = ROOT_PATH:sub(1, ROOT_PATH:find("bin") - 2)

local ie = minetest.request_insecure_environment()
local is_in_trusted = ie ~= nil
local ie_os = ie.require("os")
local ie_io = ie.require("io")

local ie_ffi = ie.require("ffi")
local OPERATION_SYSTEM = ie_ffi.os
ie_ffi = nil

ie = nil

local function create_folder(path)
    ie_os.execute("mkdir " .. path)
end

local list_fad

if OPERATION_SYSTEM == "Windows" then
    list_fad = function(path)
        return ie_io.popen("dir \"" .. path .. "\" /b"):lines()
    end
elseif OPERATION_SYSTEM == "Linux" then
    list_fad = function(path)
        return ie_io.popen("ld -pa" .. path .. " | grep -v /"):lines()
    end
end

create_folder("config")

local function check_access()
    assert(is_in_trusted, NOT_TRUSTED_MESSAGE)
end

local function create_config_interface(workspace, filename, pattern)
    local content = workspace:request_read_file(filename, "json")
    local result, config = pcall(function()
        if content:len() == 0 then
            return nil
        end
        return minetest.parse_json(content)
    end)

    local function save()
        workspace:request_write_file(filename, "json", minetest.write_json(config, true))
    end

    if content:len() == 0 or result == false or config == nil then
        config = pattern
        save()
    end

    local interface = {}

    function interface:save()
        save()
    end

    return setmetatable(interface, {
        __index = function(self, key)
            return config[key]
        end,
        __newindex = function(self, key, value)
            config[key] = value
            save()
        end
    })
end

local function create_workspace_interface(path)
    local mod_name = ft.mod_name()
    local interface = {}

    function interface:request_file(name, format)
        assert(type(name) == "string" and type(format) == "string")
        local f, result = ie_io.open(path .. name .. "." .. format, "r")
        if result ~= nil then
            f = ie_io.open(path .. name .. "." .. format, "w+")
            f:write("")
            f:close()
        else
            f:close()
        end
    end
    
    function interface:request_write_file(name, format, content, mode)
        assert(type(name) == "string" and type(format) == "string" and type(content) == "string" and (type(mode) == "string" or mode == nil))
        local f = ie_io.open(path .. name .. "." .. format, mode or "w+")
        f:write(content)
        f:close()
    end

    function interface:request_read_file(name, format, mode)
        assert(type(name) == "string" and type(format) == "string" and (type(mode) == "string" or mode == nil))
        local f = ie_io.open(path .. name .. "." .. format, mode or "r")
        if f ~= nil then
            local c = f:read("a")
            f:close()
            return c
        end
        return nil
    end

    function interface:request_list()
        local fad = {}
        for item in list_fad(path:sub(1, -2)) do
            table.insert(fad, item)
        end
        return fad
    end

    function interface:request_config(name, pattern)
        name = name or mod_name
        pattern = pattern or {}
        assert(type(name) == "string" and type(pattern) == "table")
        interface:request_file(name, "json")
        return create_config_interface(interface, name, pattern or {})
    end

    function interface:request_folder(name)
        assert(type(name) == "string")
        create_folder(path .. name)
        return create_workspace_interface(path .. name .. "\\")
    end

    function interface:get_path()
        return path
    end

    return setmetatable(interface, {__index = interface, __newindex = function() end})
end

local function get_workspace()
    check_access()

    local mod_workspace_path = fmt("%s\\config\\%s", ROOT_PATH, ft.mod_name())
    create_folder(mod_workspace_path .. "\\")
    return create_workspace_interface(mod_workspace_path .. "\\")
end

local function request_folder(name)
    check_access()
    assert(type(name) == "string" and name:find("/") == nil and name:find("\\.") == nil)

    local workspace_path = fmt("%s\\%s", ROOT_PATH, name)
    create_folder(workspace_path .. "\\")
    return create_workspace_interface(workspace_path .. "\\")
end

_G.ft_cfg = {}

ft_cfg.get_workspace = get_workspace
ft_cfg.request_folder = request_folder
