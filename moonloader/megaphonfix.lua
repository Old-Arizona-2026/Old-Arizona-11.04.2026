-- мой ахуенный скрипт который я написал, кто смотрит ты пидор ебаный
local se = require 'samp.events'

function se.onServerMessage(color, text)
    if text:find("^%[M%]") then
        return {0xFFFF00FF, text}
    end
end