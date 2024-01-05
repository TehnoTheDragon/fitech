--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --

-- Helper Functions

local function is_variable(variable)
    return type(variable) == "string" and variable:sub(1, 1) == "$"
end

local function get_variable_name(variable)
    return is_variable(variable) and variable:sub(2, -1) or variable
end

local function parse_variable(variable, memory)
    return memory[get_variable_name(variable)] or variable
end

local function parse_arguments(arguments, memory)
    local args = {}
    for _, value in pairs(arguments) do
        if is_variable(value) then
            table.insert(args, parse_variable(value, memory))
        else
            table.insert(args, value)
        end
    end
    return args
end

local function math_operation(self, memory)
    local a = self.a
    assert(is_variable(a), "math operation requires `a` to be a variable!")
    local ptr = get_variable_name(a)
    return ptr, parse_variable(a, memory), parse_variable(self.b, memory)
end

local function transform_operation(self, memory)
    local value = self.value
    assert(is_variable(value), "transform operation requires `value` to be a variable!")
    local ptr = get_variable_name(value)
    return ptr, parse_variable(value, memory)
end

--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --

local Assembler = {}

-- Main Operations

function Assembler:call(memory)
    local args = parse_arguments(self.args, memory)
    local method = self.method

    local is_plugin_method = method:sub(1, 1) == '@'
    local plugin_name = nil
    
    if is_plugin_method then
        local plugin_name_end, _ = method:find(":")
        plugin_name = method:sub(2, plugin_name_end - 1)
        method = method:sub(plugin_name_end + 1, -1)

        local plugin = ftt.plugins[plugin_name]
        plugin.call(method, unpack(args))
    end
end

-- Math Operations

function Assembler:set(memory)
    memory[self.name] = self.value
end

function Assembler:add(memory)
    local ptr, a, b = math_operation(self, memory)
    memory[ptr] = a + b
end

function Assembler:sub(memory)
    local ptr, a, b = math_operation(self, memory)
    memory[ptr] = a - b
end

function Assembler:mul(memory)
    local ptr, a, b = math_operation(self, memory)
    memory[ptr] = a * b
end

function Assembler:div(memory)
    local ptr, a, b = math_operation(self, memory)
    memory[ptr] = a / b
end

function Assembler:mod(memory)
    local ptr, a, b = math_operation(self, memory)
    memory[ptr] = a % b
end

function Assembler:pow(memory)
    local ptr, a, b = math_operation(self, memory)
    memory[ptr] = a ^ b
end

-- Transform Operations

function Assembler:floor(memory)
    local ptr, value = transform_operation(self, memory)
    memory[ptr] = math.floor(value)
end

function Assembler:cos(memory)
    local ptr, value = transform_operation(self, memory)
    memory[ptr] = math.cos(value)
end

function Assembler:sin(memory)
    local ptr, value = transform_operation(self, memory)
    memory[ptr] = math.sin(value)
end

--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --

local function do_assembly(memory, instruction)
    local instruction_method = Assembler[instruction.type]
    assert(instruction_method, ("No instruction `%s` exist!"):format(instruction.type))

    instruction_method(instruction, memory)
end

return function(assembly)
    return function(gen)
        local memory = {
            gen = gen,
            huge = math.huge,
            pi = math.pi,
        }
        for _, instruction in pairs(assembly) do
            do_assembly(memory, instruction)
        end
    end
end