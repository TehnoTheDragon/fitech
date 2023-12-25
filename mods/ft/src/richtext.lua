local function empty() end
local function parse_color(str)
    -- Init data
    local rich = ""
    
    local i = 1
    local l = str:len()
    local c = string.sub(str, i, i)

    -- Helper Functions
    local function inbound()
        return i <= l
    end

    local function adv()
        i = i + 1
        c = string.sub(str, i, i)
    end

    local function req(char, err)
        assert(c == char, err or ("Expected: `%s` at `%i`, got: `%s`"):format(char, i, c))
    end

    -- Collectors
    local function collect_text()
        local text = ""
        while c ~= '<' and inbound() do
            text = text .. c
            adv()
        end
        return text
    end

    -- Commands
    local function command_color()
        local colorstring = ""
        local text = ""

        req('=')
        adv()

        while c ~= '>' and inbound() do
            colorstring = colorstring .. c
            adv()
        end
        
        return function()
            text = collect_text()
            return minetest.colorize(colorstring, text)
        end
    end

    local function collect_command()
        local command = ""
        while c ~= '=' and c ~= '>' and inbound() do
            command = command .. c
            adv()
        end
        return command
    end

    -- State Machine?
    local function state()
        local lazy = collect_text
        if c == '<' then
            adv()
            local command = collect_command()
            if command == "color" then
                lazy = command_color()
            end
            req('>', ("No command close closure was found at `%i`"):format(i))
            adv()
        end

        return lazy()
    end

    -- Start
    while inbound() do
        rich = rich .. state()
    end

    return rich
end

return parse_color