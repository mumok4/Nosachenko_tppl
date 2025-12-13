local token_module = require('pascal.token')
local TokenType = token_module.TokenType
local AST = require('pascal.ast')

local Parser = {}
Parser.__index = Parser

function Parser.new(lexer)
    local self = setmetatable({}, Parser)
    self.lexer = lexer
    self.current_token = self.lexer:get_next_token()
    return self
end

function Parser:_error()
    error('Invalid syntax')
end

function Parser:_eat(token_type)
    if self.current_token.type_ == token_type then
        self.current_token = self.lexer:get_next_token()
    else
        self:_error()
    end
end

function Parser:_factor()
    local token = self.current_token
    if token.type_ == TokenType.PLUS then
        self:_eat(TokenType.PLUS)
        return AST.UnaryOp(token, self:_factor())
    elseif token.type_ == TokenType.MINUS then
        self:_eat(TokenType.MINUS)
        return AST.UnaryOp(token, self:_factor())
    elseif token.type_ == TokenType.INTEGER then
        self:_eat(TokenType.INTEGER)
        return AST.Num(token)
    elseif token.type_ == TokenType.LPAREN then
        self:_eat(TokenType.LPAREN)
        local node = self:_expr()
        self:_eat(TokenType.RPAREN)
        return node
    else
        local node = self:_variable()
        return node
    end
end

function Parser:_term()
    local node = self:_factor()

    while self.current_token.type_ == TokenType.MUL or self.current_token.type_ == TokenType.DIV do
        local token = self.current_token
        if token.type_ == TokenType.MUL then
            self:_eat(TokenType.MUL)
        elseif token.type_ == TokenType.DIV then
            self:_eat(TokenType.DIV)
        end
        node = AST.BinOp(node, token, self:_factor())
    end

    return node
end

function Parser:_expr()
    local node = self:_term()

    while self.current_token.type_ == TokenType.PLUS or self.current_token.type_ == TokenType.MINUS do
        local token = self.current_token
        if token.type_ == TokenType.PLUS then
            self:_eat(TokenType.PLUS)
        elseif token.type_ == TokenType.MINUS then
            self:_eat(TokenType.MINUS)
        end
        node = AST.BinOp(node, token, self:_term())
    end
    return node
end

function Parser:_program()
    local node = self:_compound_statement()
    self:_eat(TokenType.DOT)
    return node
end

function Parser:_compound_statement()
    self:_eat(TokenType.BEGIN)
    local nodes = self:_statement_list()
    self:_eat(TokenType.END)

    local root = AST.Compound()
    for _, node in ipairs(nodes) do
        table.insert(root.children, node)
    end

    return root
end

function Parser:_statement_list()
    local node = self:_statement()
    local results = {node}

    while self.current_token.type_ == TokenType.SEMI do
        self:_eat(TokenType.SEMI)
        table.insert(results, self:_statement())
    end

    if self.current_token.type_ == TokenType.ID then
        self:_error()
    end

    return results
end

function Parser:_statement()
    local node
    if self.current_token.type_ == TokenType.BEGIN then
        node = self:_compound_statement()
    elseif self.current_token.type_ == TokenType.ID then
        node = self:_assignment_statement()
    else
        node = self:_empty()
    end
    return node
end

function Parser:_assignment_statement()
    local left = self:_variable()
    local token = self.current_token
    self:_eat(TokenType.ASSIGN)
    local right = self:_expr()
    return AST.Assign(left, token, right)
end

function Parser:_variable()
    local node = AST.Var(self.current_token)
    self:_eat(TokenType.ID)
    return node
end

function Parser:_empty()
    return AST.NoOp()
end

function Parser:parse()
    local node = self:_program()
    if self.current_token.type_ ~= TokenType.EOF then
        self:_error()
    end
    return node
end

return Parser