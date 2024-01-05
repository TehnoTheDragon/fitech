minetest.set_mapgen_setting("mg_name", "singlenode", true)
minetest.set_mapgen_setting("mg_flags", "nolight", true)

local function create_gen_object(pmin, pmax, emin, emax, seed, vm)
    local va = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = {}
    vm:get_data(data)

    local sidelen = pmax.x - pmin.x + 1
    local xstride = 1
    local ystride = va.ystride
    local zstride = va.zstride

    local map = { x = sidelen, y = sidelen, z = sidelen }

    local gen = {}
    gen.vm = vm
    gen.seed = seed
    gen.pmin = pmin
    gen.pmax = pmax
    gen.emin = emin
    gen.emax = emax
    gen.data = data
    gen.area = va
    
    gen.sidelen = sidelen
    gen.xstride = xstride
    gen.ystride = ystride
    gen.zstride = zstride

    function gen.get_perlin_map_3d(noise)
        local temp = {}
        minetest.get_perlin_map(noise, map):get_3d_map_flat(pmin, temp)
        return temp
    end

    function gen.get_perlin_map_2d(noise)
        local temp = {}
        minetest.get_perlin_map(noise, map):get_2d_map_flat(pmin, temp)
        return temp
    end

    function gen.gradient(a, b)
        return (1 - a) / b
    end

    function gen.lerp(a, b, c)
        return a + (b - a) * c
    end

    function gen.global(x, y, z)
        local i = gen.index(x, y, z)
        return gen.position(i), i
    end

    function gen.globali(i)
        return gen.position(i)
    end

    function gen.position(index)
        return va:position(index or 0)
    end

    function gen.index(x, y, z)
        return va:index(x, y, z)
    end

    function gen.set(index, id)
        data[index] = id
    end

    function gen.for2d(fn)
        for x = pmin.x, pmax.x do
            for z = pmin.z, pmax.z do
                fn(x, z)
            end
        end
    end

    function gen.for3d(fn)
        for x = pmin.x, pmax.x do
            for y = pmin.y, pmax.y do
                for z = pmin.z, pmax.z do
                    fn(x, y, z)
                end
            end
        end
    end

    function gen.mapping(fn)
        local xslice = 1
        for z = pmin.z, pmax.z do
            for y = pmin.y, pmax.y do
                local vid = va:index(pmin.x, y, z)
                for x = pmin.x, pmax.x do
                    fn(x, y, z, vid, xslice)
                    
                    xslice = xslice + 1
                    vid = vid + 1
                end
            end
        end
    end

    function gen.mark_dirty()
        vm:set_data(data)
        vm:calc_lighting()
        vm:update_liquids()
        vm:write_to_map(true)
        minetest.after(0, function()
            minetest.fix_light(pmin, pmax)
        end)
    end

    return gen
end

minetest.register_on_generated(function(pmin, pmax, seed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local gen = create_gen_object(pmin, pmax, emin, emax, seed, vm)
    ftt.pipeline(gen)
end)