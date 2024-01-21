local sub = string.sub
local find = string.find
local match = string.match

local SYMBOLS = "<>{}():;.,=+-*/"
local SYMBOLS_KINDS = {
    ["{"] = "open_bracket",
    ["}"] = "close_bracket",
    ["("] = "open_parenth",
    [")"] = "close_parenth",
    ["<"] = "less",
    [">"] = "greater",
    [":"] = "colon",
    [";"] = "semicolon",
    [","] = "comma",
    ["."] = "dot",
    ["="] = "equal",
    ["+"] = "plus",
    ["-"] = "minus",
    ["*"] = "star",
    ["/"] = "slash",
}

local function token(kind, data, pos, line)
    return {
        kind = kind,
        data = data,
        pos = pos,
        line = line,
    }
end

local tokenizer = {}

function tokenizer.new(source)
    local self = {}
    -- data
    self.source = source
    self.source_length = source:len()
    self.index = 1
    self.char = sub(source, self.index, self.index)

    -- debugging
    self.pos = 0
    self.line = 1

    return setmetatable(self, {__index = tokenizer})
end

function tokenizer:eof()
    return self.index > self.source_length
end

function tokenizer:look_ahead(index)
    return sub(self.source, index, index)
end

function tokenizer:compare_region(a, b, str)
    return sub(self.source, a, b) == str
end

function tokenizer:advance()
    if not self:eof() then
        -- debugging
        if self.char == '\n' then
            self.pos = 0
            self.line = self.line + 1
        end
        self.pos = self.pos + 1
        
        -- data
        self.index = self.index + 1
        self.char = sub(self.source, self.index, self.index)
    end
end

function tokenizer:skip_whitespaces()
    while find(self.char, "%s") ~= nil do
        self:advance()
    end
end

function tokenizer:skip_comments()
    if self:compare_region(self.index, self.index + 1, "//") then
        while self.char ~= '\n' do
            self:advance()
        end
        return true
    elseif self:compare_region(self.index, self.index + 1, "/*") then
        while not self:compare_region(self.index, self.index + 1, "*/") do
            self:advance()
        end
        self:advance()
        self:advance()
        return true
    end
    return false
end

function tokenizer:collect_identifier()
    local kind = self.char == '$' and "var" or self.char == '@' and "preproc" or self.char == '#' and "label" or "iden"
    local A = self.index
    local B = A
    local pos = self.pos
    local line = self.line

    if kind ~= "iden" then
        A = A + 1
        B = A
        self:advance()
    end

    while find(self.char, "[a-zA-Z0-9_]") ~= nil do
        B = B + 1
        self:advance()
    end

    return token(kind, sub(self.source, A, B-1), pos, line)
end

function tokenizer:collect_string()
    local A = self.index + 1
    local B = A
    local pos = self.pos
    local line = self.line

    self:advance()

    while self.char ~= '"' do
        B = B + 1
        self:advance()
    end

    self:advance()

    return token("str", sub(self.source, A, B-1), pos, line)
end

function tokenizer:collect_number()
    local A = self.index
    local B = A
    local pos = self.pos
    local line = self.line

    local isfloat = false

    while find(self.char, "%d") or (self.char == '.' and isfloat == false) do
        if (self.char == '.' and isfloat == false) then
            isfloat = true
        end
        B = B + 1
        self:advance()
    end

    return token("num", sub(self.source, A, B-1), pos, line)
end

function tokenizer:next()
    ::back::
    self:skip_whitespaces()
    if self:skip_comments() then goto back end

    if self:eof() then
        return token("eof", "\x00", self.pos, self.line)
    end
    
    if find(self.char, "[a-zA-Z_]") ~= nil or
        ((self.char == '$' or self.char == '@' or self.char == '#') and find(self:look_ahead(self.index + 1), "[a-zA-Z_]") ~= nil)
    then
        return self:collect_identifier()
    elseif self.char == '"' then
        return self:collect_string()
    elseif find(self.char, "%d") then
        return self:collect_number()
    end

    if find(SYMBOLS, self.char, 1, true) ~= nil then
        local char = self.char
        self:advance()
        return token(SYMBOLS_KINDS[char], char, self.pos, self.line)
    end
    
    return token("error", ("unexpected symbol `%s(%d)` cursor: %d, line: %d"):format(self.char, self.char:byte(), self.pos, self.line), self.pos, self.line)
end

return tokenizer.new