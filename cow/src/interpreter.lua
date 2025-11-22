local Interpreter = {}
Interpreter.__index = Interpreter

function Interpreter.new()
    local self = setmetatable({}, Interpreter)
    self.memory = {[0] = 0}
    self.ptr = 0
    self.register = nil
    self.input_buffer = {}
    self.output_buffer = {}
    return self
end

function Interpreter:_parse(source)
    local tokens = {}
    local i = 1
    local len = #source
    while i <= len do
        local sub = source:sub(i, i + 2)
        if sub == "MoO" or sub == "MOo" or sub == "moO" or
           sub == "mOo" or sub == "moo" or sub == "MOO" or
           sub == "OOM" or sub == "oom" or sub == "mOO" or
           sub == "Moo" or sub == "OOO" or sub == "MMM" then
            table.insert(tokens, sub)
            i = i + 3
        else
            i = i + 1
        end
    end
    return tokens
end

function Interpreter:_get_loops(tokens)
    local stack = {}
    local loops = {}
    for i, op in ipairs(tokens) do
        if op == "MOO" then
            table.insert(stack, i)
        elseif op == "moo" then
            if #stack > 0 then
                local start = table.remove(stack)
                loops[start] = i
                loops[i] = start
            end
        end
    end
    return loops
end

function Interpreter:_ensure_mem()
    if not self.memory[self.ptr] then
        self.memory[self.ptr] = 0
    end
end

function Interpreter:_read_input(is_number)
    if #self.input_buffer > 0 then
        local val = table.remove(self.input_buffer, 1)
        return is_number and tonumber(val) or string.byte(val)
    end
    if is_number then
        return io.read("*n") or 0
    else
        local char = io.read(1)
        return char and string.byte(char) or 0
    end
end

function Interpreter:_exec_instruction(op, tokens, loops, n)
    self:_ensure_mem()
    local next_n = n + 1 

    if op == "MoO" then
        self.memory[self.ptr] = self.memory[self.ptr] + 1
    elseif op == "MOo" then
        self.memory[self.ptr] = self.memory[self.ptr] - 1
    elseif op == "moO" then
        self.ptr = self.ptr + 1
        self:_ensure_mem()
    elseif op == "mOo" then
        self.ptr = self.ptr - 1
        self:_ensure_mem()
    elseif op == "MOO" then 
        if self.memory[self.ptr] == 0 then
            if loops[n] then
                next_n = loops[n] + 1 
            else
                next_n = #tokens + 1 
            end
        end
    elseif op == "moo" then 
        if loops[n] then
            next_n = loops[n] 
        end
    elseif op == "OOM" then
        io.write(self.memory[self.ptr])
        table.insert(self.output_buffer, tostring(self.memory[self.ptr]))
    elseif op == "oom" then
        self.memory[self.ptr] = self:_read_input(true)
    elseif op == "mOO" then
        local code = self.memory[self.ptr]
        if code == 3 then error("Recursive mOO") end
        local mapping = {
            [0]="moo", [1]="mOo", [2]="moO", [3]="mOO",
            [4]="Moo", [5]="MOo", [6]="MoO", [7]="MOO",
            [8]="OOO", [9]="MMM", [10]="OOM", [11]="oom"
        }
        local sub_op = mapping[code]
        if sub_op then
            if sub_op ~= "MOO" and sub_op ~= "moo" then
                self:_exec_instruction(sub_op, tokens, loops, n)
            end
        end
    elseif op == "Moo" then
        if self.memory[self.ptr] == 0 then
            local val = self:_read_input(false)
            self.memory[self.ptr] = val or 0
        else
            local char = string.char(self.memory[self.ptr] % 256)
            io.write(char)
            table.insert(self.output_buffer, char)
        end
    elseif op == "OOO" then
        self.memory[self.ptr] = 0
    elseif op == "MMM" then
        if self.register == nil then
            self.register = self.memory[self.ptr]
        else
            self.memory[self.ptr] = self.register
            self.register = nil
        end
    end

    return next_n
end

function Interpreter:run(source, inputs)
    if inputs then self.input_buffer = inputs end
    self.output_buffer = {}
    self.memory = {[0] = 0}
    self.ptr = 0
    self.register = nil

    local tokens = self:_parse(source)
    local loops = self:_get_loops(tokens)
    local n = 1
    local len = #tokens

    while n <= len do
        local op = tokens[n]
        n = self:_exec_instruction(op, tokens, loops, n)
    end

    return table.concat(self.output_buffer)
end

return Interpreter