local Player = {}

function Player:__index(key)
    local self_field = rawget(self, key)
    if not self_field then
        local meta = rawget(self, "meta")
        return meta[key]
    end
    return self_field
end

function Player:__newindex(key, value)
    local meta = self.meta
    meta[key] = value
    if type(value) == "string" then
        self.pmeta:set_string(key, value)
    elseif type(value) == "number" then
        local _ = math.floor(value) - value == 0 and self.pmeta:set_int(key, value) or self.pmeta:set_float(key, value)
    else
        self.pmeta:set_string(key, "")
    end
end

function newPlayer(playerInstance)
    local pmt = playerInstance:get_meta():to_table()
    return setmetatable({ instance=playerInstance, name = playerInstance:get_player_name(), pmeta=playerInstance:get_meta(), meta=pmt == nil and {} or pmt.fields }, Player)
end

local PLAYERS = {}
local Players = {}

function Players.getByInstance(playerInstance)
    local player = PLAYERS[playerInstance]
    if not player then
        player = newPlayer(playerInstance)
        PLAYERS[playerInstance] = player
    end
    return player
end

function Players.getByUsername(username)
    return Players.getByInstance(minetest.get_player_by_name(username))
end

return Players