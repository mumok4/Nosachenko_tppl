local token_module = require('pascal.token')
local Token = token_module.Token
local TokenType = token_module.TokenType

local Lexer = {}
Lexer.__index = Lexer

local RESERVED_KEYWORDS = {
    BEGIN = Token.new(TokenType.BEGIN, 'BEGIN'),
    END = Token.new(TokenType.END, 'END')
}

function Lexer.new(text)
    local self = setmetatable({}, Lexer)
    self.text = text
    self.pos = 1
    self.current_char = self.text:sub(self.pos, self.pos)
    return self
end

function Lexer:_error()
    error("Invalid character")
end

function Lexer:_advance()
    self.pos = self.pos + 1
    if self.pos > #self.text then
        self.current_char = nil
    else
        self.current_char = self.text:sub(self.pos, self.pos)
    end
end

function Lexer:_peek()
    local peek_pos = self.pos + 1
    if peek_pos > #self.text then
        return nil
    else
        return self.text:sub(peek_pos, peek_pos)
    end
end

function Lexer:_skip_whitespace()
    while self.current_char and self.current_char:match("%s") do
        self:_advance()
    end
end

function Lexer:_number()
    local result = ""
    while self.current_char and self.current_char:match("%d") do
        result = result .. self.current_char
        self:_advance()
    end
    return tonumber(result)
end

function Lexer:_id()
    local result = ""
    while self.current_char and self.current_char:match("%w") do
        result = result .. self.current_char
        self:_advance()
    end
    result = result:upper()
    return RESERVED_KEYWORDS[result] or Token.new(TokenType.ID, result)
end


function Lexer:get_next_token()
    while self.current_char do
        if self.current_char:match("%s") then
            self:_skip_whitespace()
        end

        if self.current_char and self.current_char:match("%a") then
            return self:_id()
        end

        if self.current_char and self.current_char:match("%d") then
            return Token.new(TokenType.INTEGER, self:_number())
        end

        if self.current_char == ':' and self:_peek() == '=' then
            self:_advance()
            self:_advance()
            return Token.new(TokenType.ASSIGN, ':=')
        end
        
        if self.current_char == ';' then
            self:_advance()
            return Token.new(TokenType.SEMI, ';')
        end

        if self.current_char == '.' then
            self:_advance()
            return Token.new(TokenType.DOT, '.')
        end

        if self.current_char == '+' then
            self:_advance()
            return Token.new(TokenType.PLUS, '+')
        end

        if self.current_char == '-' then
            self:_advance()
            return Token.new(TokenType.MINUS, '-')
        end

        if self.current_char == '*' then
            self:_advance()
            return Token.new(TokenType.MUL, '*')
        end

        if self.current_char == '/' then
            self:_advance()
            return Token.new(TokenType.DIV, '/')
        end

        if self.current_char == '(' then
            self:_advance()
            return Token.new(TokenType.LPAREN, '(')
        end

        if self.current_char == ')' then
            self:_advance()
            return Token.new(TokenType.RPAREN, ')')
        end
        
        if self.current_char then
            self:_error()
        end
    end

    return Token.new(TokenType.EOF, nil)
end

return Lexer