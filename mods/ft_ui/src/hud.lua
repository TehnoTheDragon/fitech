local HUDs = {}
local element = {}
element.__index = element

function element.new(player, definition)
    if not HUDs[player] then
        HUDs[player] = {}
    end
    assert(definition._name ~= nil, "Definition must have field \"_name : string\"")
    local obj = setmetatable({player=player, identifier=player:hud_add(definition)}, element)
    HUDs[player][definition._name] = obj
    return obj
end

function element.iden(player, identifier)
    return setmetatable({player=player, identifier=identifier}, element)
end

function element.get(player, name)
    if HUDs[player] == nil then
        return nil
    end
    return HUDs[player][name]
end

function element:__newindex(key, value)
    self.player:hud_change(self.identifier, key, value)
end

function element:__gc()
    self:destroy()
end

function element:destroy()
    self.player:hud_remove(self.identifier)
end

--- Create or gets existed one
---@param player any - Player
---@param arg table | number | string - Definition to create new hud or identifier to get existed one or using string to get element by name
return function(player, arg)
    return type(arg) == "table"
        and element.new(player, arg) or type(arg) == "number"
        and element.iden(player, arg) or element.get(player, arg)
end