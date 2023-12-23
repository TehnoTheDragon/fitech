local Block = ft.block

return function(name, definition)
    local visual = definition.visual
    local main = visual.main
    local overlay = visual.overlay
    local tint = visual.tint

    local ore_block = Block()

    for group, value in pairs(definition.tags or {}) do
        ore_block:tag(group, value)
    end

    ore_block.textures = string.format("%s^(%s^[multiply:%s)", main, overlay, tint)
    ore_block.description = name
    ore_block:register(name)
end