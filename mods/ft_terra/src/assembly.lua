--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --

-- Constants

local PRESENTS_PATH = ft.mod_path_get("presents")

local PLUGIN_PREFIX = "@"
local VARIABLE_PREFIX = "$"

local TERMINATOR_CODE = string.char(0xFF)
local NULL_CODE = string.char(0xFE)
local GLUE_CODE = string.char(0xFD)

local INSTRUCTION_END_CODE = TERMINATOR_CODE..TERMINATOR_CODE

local SHORT_TYPE = {
    table = "t", array = "a", boolean = 'b', number = 'i', string = 's'
}

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
    if arguments == nil or #arguments == 0 then
        return {}
    end

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

    local colon_begin, _ = method:find(":")
    local prefix = method:sub(1, 1)
    local only_method_name = method:sub(colon_begin + 1, -1)
    
    if prefix == PLUGIN_PREFIX then
        local plugin_name = method:sub(2, colon_begin - 1)
        local plugin = ftt.plugins[plugin_name]
        plugin.call(only_method_name, unpack(args))
    elseif prefix == VARIABLE_PREFIX then
        local variable_name = get_variable_name(method:sub(2, colon_begin - 1))
        local variable = memory[variable_name]
        variable[only_method_name](unpack(args))
    end
end

function Assembler:set(memory)
    memory[get_variable_name(self.name)] = self.value
end

-- Math Operations

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

-- Compiler
                                                
local function compile_assembly(filename, instructions)
    local output = ""

    local function append(tail, ...)
        if tail == nil then goto exit end

        if type(tail) == "table" then
            if tail[1] ~= nil then
                append(SHORT_TYPE.array, GLUE_CODE)
                for _, v in pairs(tail) do
                    append(SHORT_TYPE[type(v)], v, TERMINATOR_CODE)
                end
            else
                append(SHORT_TYPE.table, GLUE_CODE)
                for k, v in pairs(tail) do
                    append(k, GLUE_CODE, SHORT_TYPE[type(v)], v, TERMINATOR_CODE)
                end
            end

            goto exit
        end

        output = output .. tostring(tail)
        append(...)

        ::exit::
    end

    for _, instruction in pairs(instructions) do
        append(instruction.type, TERMINATOR_CODE)
        for k, v in pairs(instruction) do
            if k == "type" then goto cont end
            if type(v) == "table" then
                append(k, GLUE_CODE, v, NULL_CODE)
                goto cont
            end
            append(k, GLUE_CODE, SHORT_TYPE[type(v)], v, TERMINATOR_CODE)
            ::cont::
        end
        append(TERMINATOR_CODE, NULL_CODE, TERMINATOR_CODE)
    end

    ft.write_file(PRESENTS_PATH.."/"..filename..".bin", "wb", output)
    return output
end

local function read_program(filename)
    return ft.read_file(PRESENTS_PATH.."/"..filename..".bin", "rb")
end

local function has_binary(filename)
    return ft.is_file_exist(PRESENTS_PATH.."/"..filename..".bin")
end

local function execute_instruction(memory, instruction)
    local instruction_method = Assembler[instruction.type]
    assert(instruction_method, ("No instruction `%s` exist!"):format(instruction.type))

    instruction_method(instruction, memory)
end

local function parse_binary_value(value)
    local prefix = value:sub(1, 1)
    local value = value:sub(2, -1)

    if prefix == SHORT_TYPE.boolean then
        return value == "true"
    elseif prefix == SHORT_TYPE.number then
        return tonumber(value)
    elseif prefix == SHORT_TYPE.string then
        return value
    end

    error(("Unknown binary value type `%s`"):format(prefix..value))
end

local function execute_program(memory, program)
    local instructions = string.split(program, TERMINATOR_CODE)
    local cinstructions = #instructions
    
    local PC = 1
    while PC <= cinstructions do
        local instruction = {type = instructions[PC]}
        
        PC = PC + 1
        while instructions[PC] ~= NULL_CODE do
            local argv = string.split(instructions[PC], GLUE_CODE)
            local argc = #argv

            if argc == 3 or argc == 4 then
                local key = argv[1]
                local table_type = argv[2]
                local T = {}
                if table_type == SHORT_TYPE.array then
                    local I = 3
                    while I <= argc do
                        T[I - 2] = parse_binary_value(argv[I])
                        I = I + 1
                    end
                else
                    local I = 3
                    while I <= argc do
                        T[argv[I]] = parse_binary_value(argv[I + 1])
                        I = I + 2
                    end
                end
                instruction[key] = T
            elseif argc == 2 then
                instruction[argv[1]] = parse_binary_value(argv[2])
            end

            PC = PC + 1
        end
        PC = PC + 1

        execute_instruction(memory, instruction)
    end
end

--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --
--      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --      --

local function compile_or_get_program(filename, assembly)
    if not has_binary(filename) then
        assembly = compile_assembly(filename, assembly)
    else
        assembly = read_program(filename)
    end
    return assembly
end

return function(filename, assembly)
    assembly = compile_assembly(filename, assembly)

    return function(init_memory)
        local memory = init_memory or {}
        execute_program(memory, assembly)
    end
end