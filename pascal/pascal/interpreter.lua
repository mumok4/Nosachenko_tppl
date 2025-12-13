local token_module = require('pascal.token')
local TokenType = token_module.TokenType

local NodeVisitor = {}
NodeVisitor.__index = NodeVisitor

function NodeVisitor:visit(node)
    if getmetatable(node).__index.__name == "BinOp" then
        return self:visit_BinOp(node)
    elseif getmetatable(node).__index.__name == "Num" then
        return self:visit_Num(node)
    elseif getmetatable(node).__index.__name == "UnaryOp" then
        return self:visit_UnaryOp(node)
    elseif getmetatable(node).__index.__name == "Compound" then
        return self:visit_Compound(node)
    elseif getmetatable(node).__index.__name == "Assign" then
        return self:visit_Assign(node)
    elseif getmetatable(node).__index.__name == "Var" then
        return self:visit_Var(node)
    elseif getmetatable(node).__index.__name == "NoOp" then
        return self:visit_NoOp(node)
    else
        error("Не найден метод visit для узла типа " .. tostring(getmetatable(node).__index.__name))
    end
end


local Interpreter = {}
Interpreter.__index = Interpreter
setmetatable(Interpreter, {__index = NodeVisitor})

function Interpreter.new(parser)
    local self = setmetatable({}, Interpreter)
    self.parser = parser
    self.GLOBAL_SCOPE = {}
    return self
end

function Interpreter:visit_BinOp(node)
    if node.op.type_ == TokenType.PLUS then
        return self:visit(node.left) + self:visit(node.right)
    elseif node.op.type_ == TokenType.MINUS then
        return self:visit(node.left) - self:visit(node.right)
    elseif node.op.type_ == TokenType.MUL then
        return self:visit(node.left) * self:visit(node.right)
    elseif node.op.type_ == TokenType.DIV then
        return self:visit(node.left) / self:visit(node.right)
    end
end

function Interpreter:visit_Num(node)
    return node.value
end

function Interpreter:visit_UnaryOp(node)
    local op = node.op.type_
    if op == TokenType.PLUS then
        return self:visit(node.expr)
    elseif op == TokenType.MINUS then
        return -self:visit(node.expr)
    end
end

function Interpreter:visit_Compound(node)
    for _, child in ipairs(node.children) do
        self:visit(child)
    end
end

function Interpreter:visit_Assign(node)
    local var_name = node.left.value
    self.GLOBAL_SCOPE[var_name] = self:visit(node.right)
end

function Interpreter:visit_Var(node)
    local var_name = node.value
    local val = self.GLOBAL_SCOPE[var_name]
    if val == nil then
        error("Ошибка: переменная не определена '" .. var_name .. "'")
    end
    return val
end

function Interpreter:visit_NoOp(node)
end

function Interpreter:interpret()
    local tree = self.parser:parse()
    if not tree then return end
    self:visit(tree)
    return self.GLOBAL_SCOPE
end

return Interpreter