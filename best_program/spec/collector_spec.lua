local collector = require("collector")
local socket = require("socket")

describe("Collector Tests", function()
    local function to_bytes(val, n)
        local res = ""
        for i = n-1, 0, -1 do
            local p = 256^i
            res = res .. string.char(math.floor(val / p) % 256)
        end
        return res
    end

    it("checksum", function()
        assert.equal(0, collector.calc_checksum("\0\0"))
        assert.equal(10, collector.calc_checksum("\5\5"))
    end)

    it("date", function()
        local ts = 1766826000 * 1000000
        assert.equal("2025-12-27 09:00:00", collector.format_date(ts))
    end)

    it("decoders", function()
        assert.equal(-1, collector.i16(255, 255))
        assert.equal(-1, collector.i32(255, 255, 255, 255))
        assert.equal(10.5, collector.f32(65, 40, 0, 0))
        assert.equal(0, collector.f32(0, 0, 0, 0))
    end)

    it("processing", function()
        local ts = 1766826000 * 1000000
        local d1 = to_bytes(ts, 8) .. string.char(65, 40, 0, 0) .. to_bytes(100, 2)
        assert.truthy(collector.process_5123(d1):match("T: 10.50"))
        local d2 = to_bytes(ts, 8) .. to_bytes(1, 4) .. to_bytes(4294967294, 4) .. to_bytes(10, 4)
        assert.truthy(collector.process_5124(d2):match("Y: %-2"))
    end)

    it("fetch", function()
        assert.is_nil(collector.fetch(nil, 10))
        local mock = {
            send = function() return true end,
            receive = function(_, l)
                if l == 10 then return "0123456789" end
                return "\0"
            end
        }
        assert.is_nil(collector.fetch(mock, 10))
    end)

    it("connect", function()
        local old_tcp = socket.tcp
        socket.tcp = function() return { 
            settimeout = function() end, 
            connect = function() return nil end,
            close = function() end 
        } end
        assert.is_nil(collector.connect("any", 0))
        socket.tcp = function() return { 
            settimeout = function() end, 
            connect = function() return true end,
            send = function() end,
            close = function() end
        } end
        assert.truthy(collector.connect("any", 0))
        socket.tcp = function() return nil end
        assert.is_nil(collector.connect("any", 0))
        socket.tcp = old_tcp
    end)

    it("loop success", function()
        local written = false
        local mock_f = { write = function() written = true end, flush = function() end }
        local mock_s = { {p = 1, l = 1, fn = function() return "" end, sk = {
            send = function() return true end,
            receive = function(_, l) return "\0" end,
            close = function() end
        }}}
        collector.loop(mock_s, mock_f, 1)
        assert.is_true(written)
    end)

    it("loop failure path", function()
        local mock_f = { write = function() end, flush = function() end }
        local closed = false
        local mock_sk = {
            send = function() return true end,
            receive = function() return nil end,
            close = function() closed = true end
        }
        local mock_s = { {p = 1, l = 1, fn = function() return "" end, sk = mock_sk} }
        collector.loop(mock_s, mock_f, 1)
        assert.is_true(closed)
        assert.is_nil(mock_s[1].sk)
        
        local old_c = collector.connect
        collector.connect = function() return nil end
        collector.loop(mock_s, mock_f, 1)
        collector.connect = old_c
    end)
end)