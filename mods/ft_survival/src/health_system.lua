local hud = ft_ui.hud
local ensure = ft.ensure

local function update_health_bar(player)
    ensure(hud(player, "ft_survival:health_bar"), function(health_bar)
        local current = player:get_hp()
        local nominal = 20
        local max_display = math.max(nominal, current)
        health_bar.number = math.ceil(current / max_display * nominal)
    end)
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

minetest.register_playerevent(update_health_bar)