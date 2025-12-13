local Lexer = require('pascal.lexer')
local Parser = require('pascal.parser')
local Interpreter = require('pascal.interpreter')

describe("Pascal Interpreter", function()

    local function run_interpreter(text)
        local lexer = Lexer.new(text)
        local parser = Parser.new(lexer)
        local interpreter = Interpreter.new(parser)
        return interpreter:interpret()
    end

    it("should handle an empty program", function()
        local text = "BEGIN END."
        local result = run_interpreter(text)
        assert.are.same({}, result)
    end)

    it("should handle simple arithmetic and assignments", function()
        local text = [[
            BEGIN
                x:= 2 + 3 * (2 + 3);
                y:= 2 / 2 - 2 + 3 * ((1 + 1) + (1 + 1));
            END.
        ]]
        local result = run_interpreter(text)
        local expected = {
            X = 17,
            Y = 11
        }
        assert.are.same(expected, result)
    end)

    it("should handle nested blocks and complex assignments", function()
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
        local result = run_interpreter(text)
        local expected = {
            Y = 2,
            A = 3,
            B = 18,
            C = -15,
            X = 11
        }
        assert.are.same(expected, result)
    end)

    it("should correctly handle variable lookups", function()
        local text = [[
            BEGIN
                a := 5;
                b := a + 10;
            END.
        ]]
        local result = run_interpreter(text)
        local expected = { A = 5, B = 15 }
        assert.are.same(expected, result)
    end)

    it("should handle unary operators", function()
        local text = [[
            BEGIN
                x := -3;
                y := +x;
            END.
        ]]
        local result = run_interpreter(text)
        local expected = { X = -3, Y = -3 }
        assert.are.same(expected, result)
    end)
    
end)