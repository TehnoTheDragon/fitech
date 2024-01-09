local TEMPERATURE_UNIT = 100 -- Celsius
local HUMIDITY_UNIT = 100 -- 100 = 100% humidity in an area, anything below zero is dry.

local biome = {}

function biome:_init()
    
end

function biome:_post(pdt)
    local keys = pdt.keys
    for biome_name, biome_definition in pairs(pdt.biomes) do
        biome_definition.main = minetest.get_content_id(keys[biome_definition.main] or "mapgen_stone")
        biome_definition.top = minetest.get_content_id(keys[biome_definition.top] or "mapgen_stone")
        biome_definition.bottom = minetest.get_content_id(keys[biome_definition.bottom] or "mapgen_stone")

        -- humidity
        local humidity = biome_definition.humidity or {0, 0}
        humidity = type(humidity) == "table" and humidity or {0, humidity}

        biome_definition.humidity = nil
        biome_definition.humidity_max = humidity[1]
        biome_definition.humidity_min = humidity[2]

        -- temperature
        local temperature = biome_definition.temperature or {0, 0}
        temperature = type(temperature) == "table" and temperature or {0, temperature}

        biome_definition.temperature = nil
        biome_definition.temperature_max = temperature[1]
        biome_definition.temperature_min = temperature[2]

        pdt.data[biome_name] = biome_definition
    end

    self.air = minetest.get_content_id("air")
    self.ignore = minetest.get_content_id("ignore")
end

function biome:generate_biome(gen, def, temperature_map, humidity_map)
    local c_air = self.air
    local c_ignore = self.ignore

    local filler = def.main

    local c_top = def.top
    local c_bottom = def.bottom
    local top_n = def.ntop
    local bottom_n = def.nbottom

    local max_y = def.max_y
    local min_y = def.min_y
    local humidity_max = def.humidity_max
    local humidity_min = def.humidity_min
    local temperature_max = def.temperature_max
    local temperature_min = def.temperature_min
    
    gen.for2d(function(x, z, xslice)
        local y_start = gen.pmax.y
        local vi = gen.index(x, gen.pmax.y, z)
        local ystride = gen.ystride
        
        local c_above = gen.get(vi+ystride)
        if c_above == c_ignore then
            y_start = y_start - 1
            c_above = gen.get(vi)
            vi = vi - ystride
        end
        local air_above = c_above == c_air
        
        local nplaced = air_above and 0 or 31000
        local depth_top = top_n
        local base_filler = 0
        
        local yslice = gen.pmax.y - y_start + xslice
        for y = y_start, gen.pmin.y-1, -1 do
            local map_index = yslice
            assert(humidity_map[map_index] ~= nil, ft.vargs_to_message(map_index))

            -- check height, humidity and temperature
            local distortion = math.random() * 5

            local global_y = gen.globali(vi).y + distortion
            local _ch = math.max(0, humidity_map[map_index]) * HUMIDITY_UNIT + distortion
            local _ct = temperature_map[map_index] * TEMPERATURE_UNIT + distortion

            local is_IB_of_height = global_y >= min_y and global_y <= max_y
            local is_IB_of_humidity = (_ch >= humidity_min or _ch <= humidity_max)
            local is_IB_of_temperature = (_ct >= temperature_min or _ct <= temperature_max)

            local everything_fine = is_IB_of_height and is_IB_of_humidity and is_IB_of_temperature

            -- generate biome
            if everything_fine then
                local c = gen.get(vi)
                local is_stone_surface = c == filler and air_above

                if is_stone_surface then
                    base_filler = math.max(depth_top + bottom_n, 0)
                end

                if c == filler then
                    local c_below = gen.get(vi - ystride)
                    if c_below == c_air then
                        nplaced = 31000
                    end
                    
                    if nplaced < depth_top then
                        gen.set(vi, c_top)
                        nplaced = nplaced + 1
                    elseif nplaced <= base_filler then
                        gen.set(vi, c_bottom)
                        nplaced = nplaced + 1
                    end
                elseif c == c_air then
                    nplaced = 0
                    air_above = true
                else
                    nplaced = 31000
                    air_above = false
                end

                vi = vi - ystride
            end

            yslice = yslice + 1
        end
    end)
end

return {
    module = biome,
    depends = {},
}