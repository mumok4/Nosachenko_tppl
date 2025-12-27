local collector = require("collector")
local sources = {
    {p = 5123, l = 14, fn = collector.process_5123},
    {p = 5124, l = 20, fn = collector.process_5124}
}
local f = io.open("data.log", "a")
if f then 
    pcall(function() collector.loop(sources, f) end)
end