local richtext = ft.richtext

local ignore_table = {
    [""] = true,
    ["air"] = true,
    ["ignore"] = true,
    ["unknown"] = true,
}

local function can_modify_tooltip(name, definition)
    return ignore_table[name] == nil and definition.description:len() > 0
end

local function modify_tooltips()
    for name, definition in pairs(minetest.registered_items) do
        if can_modify_tooltip(name, definition) then
            minetest.override_item(name, { description = richtext(definition.description) })
        end
    end
end

minetest.register_on_mods_loaded(modify_tooltips)