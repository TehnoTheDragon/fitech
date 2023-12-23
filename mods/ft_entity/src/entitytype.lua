local EntityType = class "EntityType" {}

function EntityType:init()
    self.raw = {}
    self.events = {}
    self.data = {}
end

function EntityType:set(key, value)
    self.data[key] = value
    return self
end

function EntityType:get(key)
    return self.data[key]
end

function EntityType:max_health(health)
    self.raw.hp_max = health
    return self
end

function EntityType:physical(flag)
    self.raw.physical = flag
    return self
end

function EntityType:collidable_with_objects(flag)
    self.raw.collide_with_objects = flag
    return self
end

function EntityType:collision_box(aabb)
    self.raw.collisionbox = aabb
    return self
end

function EntityType:visual(type)
    self.raw.visual = type
    return self
end

function EntityType:size(size)
    self.raw.visual_size = size
    return self
end

function EntityType:textures(textures)
    self.raw.textures = textures
    return self
end

function EntityType:sprite_div(div)
    self.raw.spritediv = div
    return self
end

function EntityType:sprite_base_position(pos)
    self.raw.initial_sprite_basepos = pos
    return self
end

function EntityType:event(event, callback)
    if not self.events[event] then
        self.events[event] = {}
    end
    table.insert(self.events[event], callback)
    return self
end

function EntityType:register(name)
    ft.registry.ENTITY:register(name, self)
    return self
end

return EntityType