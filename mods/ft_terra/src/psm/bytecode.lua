local BYTECODE = {}

BYTECODE.C2S = {}
BYTECODE.S2C = {}

local function set(code, name)
    BYTECODE.C2S[code] = name
end

set('\x40', "set")
set('\x41', "add")

for i,v in pairs(BYTECODE.C2S) do
    BYTECODE.S2C[v] = i
end

return BYTECODE