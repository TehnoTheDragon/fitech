local MAX_BUFFER_SIZE = math.pow(2, 16)
local NOT_TRUSTED_MESSAGE = ("Mod won't work without being in trusted. It won't be able use require to load ffi and string.buffer")

local ie = minetest.request_insecure_environment()
local is_in_trusted = ie ~= nil
assert(is_in_trusted, NOT_TRUSTED_MESSAGE)

local ie_ffi = ie.require("ffi")
local ie_buffer = ie.require("string.buffer")

local ie_buffer_new = ie_buffer.new
local ie_ffi_cast = ie_ffi.cast
local ie_ffi_new = ie_ffi.new

local function _buffer(size)
    size = size or 1024
    assert(size <= MAX_BUFFER_SIZE, ("Trying to allocate too much data, limit is `%d` got `%d`"):format(MAX_BUFFER_SIZE, size))
    local SIZE = size
    local buf = ie_buffer_new(SIZE)

    local self = {}

    function self:put(...)
        buf:put(...)
    end

    function self:get(...)
        return buf:get(...)
    end

    function self:size()
        return SIZE
    end

    function self:resize(size)
        assert(size <= MAX_BUFFER_SIZE, ("Trying to allocate too much data, limit is `%d` got `%d`"):format(MAX_BUFFER_SIZE, size))
        SIZE = size
    end

    function self:str()
        return buf:__tostring()
    end

    return self
end

local function _new(ctype, init)
    return ie_ffi_new(ctype, init)
end

local function _cast(toctype, fromctype, value)
    return ie_ffi.cast(toctype, _new(fromctype, value))
end

ie_buffer = nil
ie_ffi = nil
ie = nil

_G.ft_extra = {}
_G.ft_extra.buffer = _buffer
_G.ft_extra.cast = _cast