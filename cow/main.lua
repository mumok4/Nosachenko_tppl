local Interpreter = require("src.interpreter")

local args = {...}
if #args < 1 then
    os.exit(1)
end

local file = io.open(args[1], "r")
if not file then
    os.exit(1)
end

local source = file:read("*a")
file:close()

local vm = Interpreter.new()
vm:run(source)
print()