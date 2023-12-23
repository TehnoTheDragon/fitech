local EXCHANGE_TABLE_TO = 1
local EXCHANGE_TABLE_FROM = 2

local EnergyType = class "EnergyType" {}

function EnergyType:init()
    self.exchange_table = {{}, {}}
end

function EnergyType:__tostring()
    return self._name
end

function EnergyType:name()
    return self._name
end

function EnergyType:exchange_to(name, unit)
    self.exchange_table[EXCHANGE_TABLE_TO][name] = unit
    return self
end

function EnergyType:exchange_from(name, unit)
    self.exchange_table[EXCHANGE_TABLE_FROM][name] = unit
    return self
end

function EnergyType:register(name)
    ft.registry.ENERGY:register(name, self)
    return self
end

return EnergyType