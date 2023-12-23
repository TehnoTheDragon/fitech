-- GUI Element
local function element_argument(self, argument)
    if type(argument) == "table" then
        if argument[1] == nil then
            for k, v in pairs(argument) do
                self:append(("%s="):format(k))
                element_argument(self, v)
                self:append(";")
            end
        else
            self:append(table.concat(argument, ","))
        end
    else
        self:append(tostring(argument))
    end
end

local function element(key)
    return function(self, ...)
        local argv = {...}
        local argc = #argv

        self:append(("%s["):format(key))
        for i, v in pairs(argv) do
            element_argument(self, v)
            if i < argc and self:read_top() ~= ";" then
                self:append(";")
            end
        end
        if self:read_top() == ";" then
            self:cut(1, -2)
        end
        self:append("]")
        return self
    end
end

-- Formspec
local formspec_metatable = {}

function formspec_metatable:__index(key)
    local builtin_field = formspec_metatable[key]
    return builtin_field ~= nil and builtin_field or element(key)
end

function formspec_metatable:__tostring()
    return self.formspec
end

function formspec_metatable:get()
    return self.formspec
end

function formspec_metatable:append(rawElement)
    self.formspec = self.formspec .. rawElement
    return self
end

function formspec_metatable:cut(at, to)
    self.formspec = self.formspec:sub(at, to)
    return self
end

function formspec_metatable:read(at, to)
    return self.formspec:sub(at, to)
end

function formspec_metatable:read_top(offset)
    offset = offset or 0
    return self.formspec:sub(-1-offset,-1-offset)
end

return function()
    return setmetatable({formspec = ""}, formspec_metatable)
end