local AST = {}

local Node = {}
Node.__index = Node
function Node.new()
    return setmetatable({}, Node)
end

local BinOp = { __name = "BinOp" }
BinOp.__index = BinOp
setmetatable(BinOp, {__index = Node})
function AST.BinOp(left, op, right)
    local self = setmetatable({}, BinOp)
    self.left = left; self.op = op; self.right = right
    return self
end

local Num = { __name = "Num" }
Num.__index = Num
setmetatable(Num, {__index = Node})
function AST.Num(token)
    local self = setmetatable({}, Num)
    self.token = token; self.value = token.value
    return self
end

local UnaryOp = { __name = "UnaryOp" }
UnaryOp.__index = UnaryOp
setmetatable(UnaryOp, {__index = Node})
function AST.UnaryOp(op, expr)
    local self = setmetatable({}, UnaryOp)
    self.op = op; self.expr = expr
    return self
end

local Compound = { __name = "Compound" }
Compound.__index = Compound
setmetatable(Compound, {__index = Node})
function AST.Compound()
    local self = setmetatable({}, Compound)
    self.children = {}
    return self
end

local Assign = { __name = "Assign" }
Assign.__index = Assign
setmetatable(Assign, {__index = Node})
function AST.Assign(left, op, right)
    local self = setmetatable({}, Assign)
    self.left = left; self.op = op; self.right = right
    return self
end

local Var = { __name = "Var" }
Var.__index = Var
setmetatable(Var, {__index = Node})
function AST.Var(token)
    local self = setmetatable({}, Var)
    self.token = token; self.value = token.value
    return self
end

local NoOp = { __name = "NoOp" }
NoOp.__index = NoOp
setmetatable(NoOp, {__index = Node})
function AST.NoOp()
    return setmetatable({}, NoOp)
end

return AST