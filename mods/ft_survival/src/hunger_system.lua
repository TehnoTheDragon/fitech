local hud = ft_ui.hud
local ensure = ft.ensure

local function update_hunger_bar(player)
    ensure(hud(player, "ft_survival:hunger_bar"), function(hunger_bar)
        local meta = player:get_meta()
        local current = meta:get_int("hunger")
        local nominal = 20
        local max_display = math.max(nominal, current)
        hunger_bar.number = math.ceil(current / max_display * nominal)
    end)
end

minetest.register_on_joinplayer(function(player)
    local player = ft.players.getByInstance(player)
    if player.hunger == nil then
        player.hunger = 20
    end

    local hunger_bar = hud(player.instance, {
        hud_elem_type = "statbar",
        text = "full_hunger.png",
        text2 = "empty_hunger.png",
        item = 20,
        number = player.hunger,
        direction = 1,

        position = {x = 0.5, y = 1},
        offset = {x = 260, y = -96},
        alignment = {x = 0, y = 0},
        size = {x = 24, y = 24},

        _name = "ft_survival:hunger_bar"
    })
end)

minetest.register_on_respawnplayer(function(player)
    local meta = player:get_meta()
    meta:set_int("hunger", 20)
    update_hunger_bar(player)
end)

local tick = 0
minetest.register_globalstep(function(dt)
    tick = tick + dt
    if tick < 100 then
        return
    end
    tick = 0

    for _, player in ipairs(minetest.get_connected_players()) do
        local current_health = player:get_hp()
        if current_health > 0 then
            local meta = player:get_meta()
            local current_hunger = meta:get_int("hunger")
            meta:set_int("hunger", math.max(current_hunger - 1, 0))
            update_hunger_bar(player)
        end
    end
end)