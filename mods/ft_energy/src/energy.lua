local Energy = class "Energy" {}

function Energy:init(energyType, capacity)
    self._energytype = ft_energy.get_energy_type(energyType)
    self._capacity = (capacity <= 0 or capacity == nil) and math.huge or capacity
    self._store = 0
end

function Energy:__tostring()
    return ("Energy (%s) [%.1f / %.1f]"):format(self._energytype:name(), self._store, self._capacity)    
end

function Energy:get()
    return self._store
end

function Energy:max()
    return self._capacity
end

function Energy:cap(units)
    self._capacity = (units <= 0 or units == nil) and math.huge or units
    self._store = math.max(0, math.min(self._store, self._capacity))
end

function Energy:set(units)
    self._store = math.max(0, math.min(units, self._capacity))
    return units - self._store
end

function Energy:increase(units)
    local set = self._store + units
    self._store = math.max(0, math.min(set, self._capacity))
    return set - self._store
end

function Energy:decrease(units)
    local set = self._store - units
    self._store = math.max(0, math.min(set, self._capacity))
    return set
end

function Energy:exchange(to, units)
    return ft_energy.exchange(self._energytype, to._energytype, units)
end

function Energy:transfer(to, units)
    local transferUnits = math.min(units, units + self:decrease(units))
    local backUnits = to:increase(ft_energy.exchange(self._energytype, to._energytype, transferUnits))
    self:increase(ft_energy.exchange(to._energytype, self._energytype, backUnits))
end

function Energy:serialize()
    return minetest.serialize({
        self._energytype:name(), self._capacity, self._store
    })
end

function Energy:deserialize(data)
    local data = minetest.deserialize(data)
    self._energytype = ft_energy.get_energy_type(data[1])
    self._capacity = data[2]
    self._store = data[3]
end

return Energy