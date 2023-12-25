local Block = ft.block
local Item = ft.item
local formspec = ft_ui.formspec

local machine = Block()
machine.textures = "NaN.png^[multiply:#ffffff"
machine.description = "Shard Mixer"
machine:event("on_construct", function(pos, placer)
    local machineFormspec = formspec()
        :formspec_version(6)
        :size({10, 7})
        :bgcolor("#111a")
        :container({0.025, 0})
            :style_type("list", {size={0.95, 0.95}, spacing={0.05, 0.05}})
            :listcolors("#1115", "#2225", "#444f")
            :list("current_player", "main", {0, 4}, {10, 3}, 0)
            :list("context", "input", {3.5, 0.5}, {3, 1}, 0)
            :list("context", "output", {4.5, 2.5}, {1, 1}, 0)
        :container_end()

    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("input", 3)
    inv:set_size("output", 1)

    meta:set_string("formspec", machineFormspec:get())
end)
machine:tag("soft", 3)
machine:register("rawr")
print(machine)

-- print(dump(ft.registered_recipe_types))
-- print(dump(ft.registered_recipes))

local circuit = Item()
circuit.description = [[Circuit
<color=#ff00ff>Hello <color=#ffff00>World!]]
circuit.texture = "circuit_0.png"
circuit:register("circuit")