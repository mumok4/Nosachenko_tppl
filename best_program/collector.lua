local socket = require("socket")

local collector = {}

local BYTE_MAX = 256
local INT16_MAX = 32767
local INT16_RANGE = 65536
local INT32_MAX = 2147483647
local INT32_RANGE = 4294967296
local FLOAT32_MANTISSA_DIVISOR = 8388608
local FLOAT32_EXP_BIAS = 127
local FLOAT32_SIGN_BIT = 127
local FLOAT32_EXP_MULTIPLIER = 128

local MICROS_PER_SECOND = 1000000
local SOCKET_TIMEOUT = 2
local LOOP_SLEEP = 0.05

local HANDSHAKE_MSG = "isu_pt"
local HANDSHAKE_RESPONSE = "granted"
local FETCH_CMD = "get"

local POWER_8 = 2^8
local POWER_16 = 2^16
local POWER_24 = 2^24
local POWER_32 = 2^32
local POWER_40 = 2^40
local POWER_48 = 2^48
local POWER_56 = 2^56

function collector.calc_checksum(data)
    local sum = 0
    for i = 1, #data do
        sum = (sum + data:byte(i)) % BYTE_MAX
    end
    return sum
end

function collector.format_date(ts_micros)
    local seconds = math.floor(ts_micros / MICROS_PER_SECOND)
    return os.date("!%Y-%m-%d %H:%M:%S", seconds)
end

function collector.i16(b1, b2)
    local n = b1 * BYTE_MAX + b2
    return n > INT16_MAX and n - INT16_RANGE or n
end

function collector.i32(b1, b2, b3, b4)
    local n = b1 * POWER_24 + b2 * POWER_16 + b3 * BYTE_MAX + b4
    return n > INT32_MAX and n - INT32_RANGE or n
end

function collector.f32(b1, b2, b3, b4)
    local sign = b1 > FLOAT32_SIGN_BIT and -1 or 1
    local exp = (b1 % FLOAT32_EXP_MULTIPLIER) * 2 + math.floor(b2 / FLOAT32_EXP_MULTIPLIER)
    local mant = ((b2 % FLOAT32_EXP_MULTIPLIER) * POWER_16 + b3 * BYTE_MAX + b4) / FLOAT32_MANTISSA_DIVISOR + 1
    if exp == 0 then return 0 end
    return sign * mant * (2 ^ (exp - FLOAT32_EXP_BIAS))
end

function collector.u64(b1, b2, b3, b4, b5, b6, b7, b8)
    return b1 * POWER_56 + b2 * POWER_48 + b3 * POWER_40 + b4 * POWER_32 + 
           b5 * POWER_24 + b6 * POWER_16 + b7 * BYTE_MAX + b8
end

function collector.connect(host, port)
    print(string.format("Подключаюсь к %s:%d...", host, port))
    local sock = socket.tcp()
    if not sock then
        print("Ошибка: не удалось создать сокет")
        return nil
    end
    sock:settimeout(SOCKET_TIMEOUT)
    local success = sock:connect(host, port)
    if not success then
        print("Не удалось подключиться")
        sock:close()
        return nil 
    end
    
    if sock.send then
        sock:send(HANDSHAKE_MSG)
    end
    
    if sock.receive then
        local response = sock:receive(#HANDSHAKE_RESPONSE)
        if not response or response ~= HANDSHAKE_RESPONSE then
            print(string.format("Неверный ответ на handshake: %s", response or "nil"))
            sock:close()
            return nil
        end
    end
    
    print("Подключение установлено")
    return sock
end

function collector.fetch(sock, len)
    if not sock or not sock:send(FETCH_CMD) then return nil end
    local data = sock:receive(len)
    if not data or #data < len then
        print(string.format("Ошибка получения данных (получено %d из %d байт)", data and #data or 0, len))
        return nil
    end
    local cs_raw = sock:receive(1)
    if not cs_raw then
        print("Не удалось получить контрольную сумму")
        return nil
    end
    local expected_cs = collector.calc_checksum(data)
    local received_cs = cs_raw:byte(1)
    if expected_cs ~= received_cs then
        print(string.format("Ошибка контрольной суммы: ожидалось %d, получено %d", expected_cs, received_cs))
        return nil
    end
    return data
end

function collector.process_5123(d)
    local b = {d:byte(1, 14)}
    local ts = collector.u64(b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8])
    local t = collector.f32(b[9], b[10], b[11], b[12])
    local p = collector.i16(b[13], b[14])
    return string.format("%s | T: %.2f | P: %d\n", collector.format_date(ts), t, p)
end

function collector.process_5124(d)
    local b = {d:byte(1, 20)}
    local ts = collector.u64(b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8])
    local x = collector.i32(b[9], b[10], b[11], b[12])
    local y = collector.i32(b[13], b[14], b[15], b[16])
    local z = collector.i32(b[17], b[18], b[19], b[20])
    return string.format("%s | X: %d | Y: %d | Z: %d\n", collector.format_date(ts), x, y, z)
end

function collector.loop(sources, file, iterations)
    print("Запуск сборщика данных...")
    local count = 0
    while not iterations or count < iterations do
        for _, s in ipairs(sources) do
            if not s.sk then s.sk = collector.connect("95.163.237.76", s.p) end
            if s.sk then
                local d = collector.fetch(s.sk, s.l)
                if d then
                    file:write(s.fn(d))
                    file:flush()
                    print(string.format("Данные с порта %d записаны", s.p))
                else
                    print(string.format("Потеряно соединение с портом %d", s.p))
                    s.sk:close()
                    s.sk = nil
                end
            end
        end
        socket.sleep(LOOP_SLEEP)
        count = count + 1
    end
    print("Сборщик завершил работу")
end

return collector