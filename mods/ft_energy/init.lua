local EXCHANGE_TABLE_TO = 1
local EXCHANGE_TABLE_FROM = 2

_G.ft_energy = {}
ft_energy.registered_energy_types = {}

function ft_energy.get_energy_type(name)
    if type(name) == "table" then
        return name
    end

    local energy_type = ft_energy.registered_energy_types[name]
    assert(energy_type ~= nil, ("No energy with name `%s` was found"):format(name))
    return energy_type
end

--- Exchange 'from' energy to 'to' energy, units is how much 'from' energy is trying to be converted to 'to' energy
---@param from string | table
---@param to string | table
---@param units number
function ft_energy.exchange(from, to, units)
    local from = ft_energy.get_energy_type(from)
    local to = ft_energy.get_energy_type(to)

    local to_units = from.exchange_table[EXCHANGE_TABLE_TO][to:name()]
    
    return to_units * units
end

ft_energy.energytype = ft.mod_load("src/energytype.lua")
ft_energy.energy = ft.mod_load("src/energy.lua")

-- Energy Registry
local Registry = ft.registry
Registry._custom("ENERGY", function(name, data)
    ft_energy.registered_energy_types[name] = data
    data._name = name
end)