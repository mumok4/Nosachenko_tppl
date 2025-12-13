local Lexer = require('pascal.lexer')
local Parser = require('pascal.parser')
local Interpreter = require('pascal.interpreter')

local text = [[
BEGIN
    y:= 2;
    BEGIN
        a := 3;
        a := a;
        b := 10 + a + 10 * y / 4;
        c := a - b
    END;
    x := 11;
END.
]]

local lexer = Lexer.new(text)
local parser = Parser.new(lexer)
local interpreter = Interpreter.new(parser)
local result = interpreter:interpret()

for k, v in pairs(result) do
    print(string.format("%s = %s", k, v))
end