script_name("oldmoneyseparator")
script_author("pewpewpewpew")

require "lib.moonloader"
local sampev = require "samp.events"

local STATS_MONEY_COLOR = "{FF6347}"

local function parse_cash_value(str)
    str = tostring(str or "")
    str = str:gsub("[ %t%.,]", "")
    return tonumber(str) or 0
end

local function format_number(num)
    num = math.floor(tonumber(num) or 0)

    local s = tostring(num)
    local rev = s:reverse():gsub("(%d%d%d)", "%1,")
    s = rev:reverse()

    if s:sub(1, 1) == "," then
        s = s:sub(2)
    end

    return s
end

local function is_stats_text(text)
    if type(text) ~= "string" then return false end

    return text:find("Авторизация на сервере", 1, true)
        or text:find("Текущее состояние счета", 1, true)
        or text:find("Наличные деньги (SA$)", 1, true)
        or text:find("Наличные деньги (VC$)", 1, true)
        or text:find("Деньги в банке", 1, true)
        or text:find("Состояние личного счета", 1, true)
end

local function make_money(prefix, value, colored)
    local money = prefix .. format_number(parse_cash_value(value))
    return colored and (STATS_MONEY_COLOR .. money) or money
end

local function fix_shop_spaces(text)
    text = text:gsub("(VC%$[%d,]+)за", "%1 за")
    text = text:gsub("(%$[%d,]+)за", "%1 за")
    return text
end

local function convert_money_tags(text, colored)
    if type(text) ~= "string" or text == "" then
        return text
    end

    text = text:gsub(":CASHV:[ \t]*([%d%., ]+)", function(value)
        return make_money("$", value, colored)
    end)

    text = text:gsub(":CASH:[ \t]*([%d%., ]+)", function(value)
        return make_money("$", value, colored)
    end)

    return fix_shop_spaces(text)
end

function main()
    repeat wait(100) until isSampAvailable()
    wait(-1)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    local colored = is_stats_text(title) or is_stats_text(text)

    return {
        dialogId,
        style,
        convert_money_tags(title, colored),
        convert_money_tags(button1, colored),
        convert_money_tags(button2, colored),
        convert_money_tags(text, colored)
    }
end

function sampev.onServerMessage(color, text)
    return {color, convert_money_tags(text, false)}
end

function sampev.onShowTextDraw(id, data)
    if data and data.text then
        data.text = convert_money_tags(data.text, false)
        return {id, data}
    end
end

function sampev.onTextDrawSetString(id, text)
    return {id, convert_money_tags(text, false)}
end

function sampev.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
    return {
        id,
        color,
        position,
        distance,
        testLOS,
        attachedPlayerId,
        attachedVehicleId,
        convert_money_tags(text, false)
    }
end