_G.ft_entity = {}

ft_entity.entitytype = ft.mod_load("entitytype.lua")
ft_entity.entity = ft.mod_load("entity.lua")

-- Entity Registry
local Registry = ft.registry
Registry._custom("ENTITY", function(name, data)
    local entity = {
        initial_properties = data.raw,
        data = data.data
    }

    function entity:get_staticdata()
        return minetest.write_json(entity.data)
    end

    function entity:on_activate(data)
        if data == "" or data == nil then
            data = "{}"
        end
        self.data = minetest.parse_json(data) or {}
    end
    
    for key, callbacks in pairs(data.events) do
        entity[key] = function(self, ...)
            for _, fn in ipairs(callbacks) do
                fn(self, ...)
            end
        end
    end
    
    minetest.register_entity(name, entity)
    data._name = name
end)

-- /spawnentity ft_entity:entity_idk

-- Sandbox
-- local IDK = ft_entity.entitytype()
--     :physical(true)
--     :collision_box({-0.3, -0.3, -0.3, 0.3, 0.3, 0.3})
--     :max_health(100)
--     :visual("wielditem")
--     :event("on_step", function(self, dt)
--         local pos = self.object:get_pos()
--         local pos_down = pos - vector.new(0, 1, 0)
--         local velocity = vector.new(self.data.velocity)
        
--         if minetest.get_node(pos_down).name == "air" then
--             velocity = velocity + vector.new(0, -1, 0)
--         else
--             velocity = velocity * vector.new(1, -0.5, 1)
--         end
        
--         self.object:move_to(pos + velocity * dt)
--         self.data.velocity = velocity

--         if pos.y < -100 or math.abs(velocity.y) < 2 then
--             self.object:set_hp(self.object:get_hp() - 1)
--         end
--     end)
--     :set("velocity", vector.new(0, 0, 0))
--     :register("idk")