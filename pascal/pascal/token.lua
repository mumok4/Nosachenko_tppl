local Token = {}
Token.__index = Token

function Token.new(type_, value)
    local self = setmetatable({}, Token)
    self.type_ = type_
    self.value = value
    return self
end

function Token:__tostring()
    return string.format("Token(%s, %s)", self.type_, self.value)
end

local TokenType = {
    -- Операторы и символы
    PLUS          = 'PLUS',
    MINUS         = 'MINUS',
    MUL           = 'MUL',
    DIV           = 'DIV',
    LPAREN        = 'LPAREN',
    RPAREN        = 'RPAREN',
    SEMI          = 'SEMI',
    DOT           = 'DOT',
    -- Зарезервированные слова
    BEGIN         = 'BEGIN',
    END           = 'END',
    -- Служебные токены
    ID            = 'ID',
    ASSIGN        = 'ASSIGN',
    INTEGER       = 'INTEGER',
    EOF           = 'EOF',
}

return {
    Token = Token,
    TokenType = TokenType
}