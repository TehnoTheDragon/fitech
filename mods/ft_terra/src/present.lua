local function parse_keys(unfiltered_keys)
    local keys = {}
    for key, name in pairs(unfiltered_keys) do
        keys[key] = minetest.get_content_id(name)
    end
    return keys
end

local Assembly = ft.mod_load("src/assembly.lua")

local Present = {}
Present.__index = Present

function Present:generate(gen)
    -- local memory = {}

    -- for k, v in pairs(self.noises) do
    --     if v.type == "3d" then
    --         memory[k] = gen.get_perlin_map_3d(v.definition)
    --     elseif v.type == "2d" then
    --         memory[k] = gen.get_perlin_map_2d(v.definition)
    --     end
    -- end

    -- for k, v in pairs(self.keys) do
    --     memory[k] = v
    -- end

    -- for k, v in pairs(self.data) do
    --     memory[k] = v
    -- end

    -- memory.gen = gen

    -- self.assembly(memory)

    -- gen.mark_dirty()
end

return function(filename, PDT)
    PDT.noises = PDT.noises or {}
    PDT.data = PDT.data or {}

    local self = {}
    self.noises = PDT.noises
    self.data = PDT.data
    self.assembly = Assembly(filename, PDT.assembly)
    
    minetest.register_on_mods_loaded(function()
        self.keys = parse_keys(PDT.keys)
        if PDT.plugins then
            ftt.load_plugins(PDT.plugins)
            for _, plugin in pairs(ftt.plugins) do
                plugin.post_init(PDT)
            end
        end
    end)

    return setmetatable(self, Present)
end