local hud = ft_ui.hud

local function update_health_bar(player, custom)
    hud(player, "ft_survival:health_bar").number = player:get_hp()
end

minetest.register_on_joinplayer(function(player)
    player:hud_set_flags({
        healthbar = false
    })

    local health_bar = hud(player, {
        hud_elem_type = "statbar",
        text = "full_health.png",
        text2 = "empty_health.png",
        item = 20,
        number = player:get_hp(),
        direction = 0,

        position = {x = 0.5, y = 1},
        offset = {x = -280, y = -96},
        alignment = {x = 0, y = 0},
        size = {x = 24, y = 24},

        _name = "ft_survival:health_bar"
    })
end)

minetest.register_on_player_hpchange(function(player, hp)
    update_health_bar(player, player:get_hp() - math.max(math.abs(hp), 0))
end)

minetest.register_on_respawnplayer(function(player)
    update_health_bar(player)
end)