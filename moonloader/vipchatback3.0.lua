script_name('vipchatback3.0')
script_author('pewpewpewpew')

local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
require 'lib.moonloader'

encoding.default = 'CP1251'
local u8 = encoding.UTF8

local ITEMS_URL = 'https://raw.githubusercontent.com/muygresiwesggg/arz_item/refs/heads/main/items.json'
local ITEMS_FILE = getWorkingDirectory() .. '\\items_cache.json'
local ITEM_NAMES = {}
local DOWNLOAD_DONE = 6
local WHITE_COLOR = -1

local ANNOUNCE_TAG = string.char(
    0xCE, 0xE1, 0xFA, 0xFF, 0xE2,
    0xEB, 0xE5, 0xED, 0xE8, 0xE5,
    0x3A
)

local ITEM_WORD = string.char(
    0xCF, 0xF0, 0xE5, 0xE4, 0xEC, 0xE5, 0xF2
)

local VIP_CHAT_TAG = string.char(
    0x5B, 0xC2, 0xC8, 0xCF, 0x20,
    0xD7, 0xC0, 0xD2, 0x5D
)

local VIP_AD_TAG = string.char(
    0x5B, 0xC2, 0xC8, 0xCF, 0x20,
    0x41, 0x44, 0x5D
)

local ADMIN_TAG = string.char(
    0x5B, 0xC0, 0xC4, 0xCC,
    0xC8, 0xCD, 0x5D
)

local function utf8char(n)
    if n <= 0x7F then
        return string.char(n)
    elseif n <= 0x7FF then
        return string.char(
            0xC0 + math.floor(n / 0x40),
            0x80 + (n % 0x40)
        )
    end

    return string.char(
        0xE0 + math.floor(n / 0x1000),
        0x80 + (math.floor(n / 0x40) % 0x40),
        0x80 + (n % 0x40)
    )
end

local function rawUf(code)
    return utf8char(tonumber('F' .. code, 16))
end

local function tokenList(code)
    local l = code:lower()
    local u = code:upper()

    return {
        ':uf' .. l .. ':',
        ':uf' .. u .. ':',
        ':UF' .. l .. ':',
        ':UF' .. u .. ':',
        rawUf(code)
    }
end

local CHAT_RULES = {
    { old = 'D7A926', tag = '[FOREVER]', color = 'D7A926' },
    { old = '3D63FF', tag = '[FOREVER]', color = 'B56CFF' },
    { old = '35A7FF', tag = '[PREMIUM]', color = 'B56CFF' },
    { old = 'DF8426', tag = '[FOREVER]', color = 'DF8426' },
    { old = '8F989C', tag = '[VIP]', color = '788FD4' },
    { old = 'FCAA4D', prefix = ':envelope: ', tag = '[VIP] ' .. ANNOUNCE_TAG, color = 'FCAA4D' },
}

local AD_RULES = {
    { old = 'D7A926', tag = '[VIP ADV]', color = 'E75773' },
    { old = '3D63FF', tag = '[VIP ADV]', color = 'E75773' },
    { old = '35A7FF', tag = '[VIP ADV]', color = 'E75773' },
    { old = 'DF8426', tag = '[VIP ADV]', color = 'E75773' },
    { old = '8F989C', tag = '[VIP ADV]', color = 'E75773' },
}

local ADMIN_RULES = {
    { old = 'FA8072', tag = '[ADMIN]', color = 'F2C455' },
}

local UF_RULES = {
    { tokens = tokenList('234'), tag = '[FOREVER]', color = 'D7A926' },
    { tokens = tokenList('232'), tag = '[FOREVER]', color = 'B56CFF' },
    { tokens = tokenList('231'), tag = '[PREMIUM]', color = 'B56CFF' },
    { tokens = tokenList('233'), tag = '[FOREVER]', color = 'DF8426' },
    { tokens = tokenList('230'), tag = '[VIP]', color = '788FD4' },

    { tokens = tokenList('23c'), prefix = ':envelope: ', tag = '[VIP] ' .. ANNOUNCE_TAG, color = 'FCAA4D' },

    { tokens = tokenList('23a'), tag = '[VIP ADV]', color = 'E75773' },
    { tokens = tokenList('238'), tag = '[VIP ADV]', color = 'E75773' },
    { tokens = tokenList('237'), tag = '[VIP ADV]', color = 'E75773' },
    { tokens = tokenList('239'), tag = '[VIP ADV]', color = 'E75773' },
    { tokens = tokenList('236'), tag = '[VIP ADV]', color = 'E75773' },

    { tokens = tokenList('235'), tag = '[ADMIN]', color = 'F2C455' },
}

local CROWNS = {}
local ANNOUNCE_UF = tokenList('23b')

for i = 0, 4 do
    local tokens = tokenList('24' .. i)

    for _, token in ipairs(tokens) do
        table.insert(CROWNS, token)
    end
end

local ANNOUNCE_COLORS = {
    ['73B461'] = true,
    ['079C1C'] = true,
    ['FCAA4D'] = true,
}

local function hexToSampColor(hex)
    local color = tonumber('0xFF' .. hex)

    if color and color > 0x7FFFFFFF then
        color = color - 0x100000000
    end

    return color or WHITE_COLOR
end

local function itemMessage(text)
    sampAddChatMessage('{73B461}[Items] ' .. text, hexToSampColor('73B461'))
end

local function normalizeColor(color)
    if color < 0 then
        color = 0x100000000 + color
    end

    return ('%08X'):format(color)
end

local function colorArgIs(color, hex)
    local c = normalizeColor(color)

    return c:sub(1, 6) == hex
        or c:sub(-6) == hex
        or c:sub(3, 8) == hex
end

local function colorFromArg(color)
    local c = normalizeColor(color)

    local variants = {
        c:sub(1, 6),
        c:sub(-6),
        c:sub(3, 8)
    }

    for _, hex in ipairs(variants) do
        hex = hex:upper()

        if ANNOUNCE_COLORS[hex] then
            return hex
        end
    end
end

local function escapePattern(s)
    return (s:gsub('([%(%)%.%%%+%-%*%?%[%]%^%$])', '%%%1'))
end

local function findToken(text, tokens)
    for _, token in ipairs(tokens) do
        local pos1, pos2 = text:find(token, 1, true)

        if pos1 then
            return pos1, pos2
        end
    end
end

local function hasToken(text, tokens)
    return findToken(text, tokens) ~= nil
end

local function stripColors(text)
    return (text:gsub('{%x%x%x%x%x%x}', ''))
end

local function isDirectEnvelopeAnnounce(text)
    local plain = stripColors(text)

    local pos = plain:find(ANNOUNCE_TAG, 1, true)
    if not pos then return false end

    return pos <= 20
end

local function shouldHandleServerLine(text)
    if text:find(VIP_CHAT_TAG, 1, true)
        or text:find(VIP_AD_TAG, 1, true)
        or text:find(ADMIN_TAG, 1, true)
        or isDirectEnvelopeAnnounce(text)
        or hasToken(text, ANNOUNCE_UF)
    then
        return true
    end

    for _, rule in ipairs(UF_RULES) do
        if hasToken(text, rule.tokens) then
            return true
        end
    end

    for _, token in ipairs(CROWNS) do
        if text:find(token, 1, true) then
            return true
        end
    end

    return false
end

local function countItems(t)
    local count = 0

    for _ in pairs(t) do
        count = count + 1
    end

    return count
end

local function utf8FromCodepoint(cp)
    if cp <= 0x7F then
        return string.char(cp)
    elseif cp <= 0x7FF then
        return string.char(
            0xC0 + math.floor(cp / 0x40),
            0x80 + (cp % 0x40)
        )
    elseif cp <= 0xFFFF then
        return string.char(
            0xE0 + math.floor(cp / 0x1000),
            0x80 + (math.floor(cp / 0x40) % 0x40),
            0x80 + (cp % 0x40)
        )
    end

    return ''
end

local function jsonUnescape(s)
    s = s:gsub('\\u(%x%x%x%x)', function(hex)
        return utf8FromCodepoint(tonumber(hex, 16))
    end)

    s = s:gsub('\\"', '"')
    s = s:gsub('\\\\', '\\')
    s = s:gsub('\\/', '/')
    s = s:gsub('\\b', '\b')
    s = s:gsub('\\f', '\f')
    s = s:gsub('\\n', '\n')
    s = s:gsub('\\r', '\r')
    s = s:gsub('\\t', '\t')

    return s
end

local function parseJsonString(data, pos)
    pos = pos + 1
    local result = {}

    while pos <= #data do
        local c = data:sub(pos, pos)

        if c == '"' then
            return table.concat(result), pos + 1
        end

        if c == '\\' then
            local n = data:sub(pos + 1, pos + 1)

            if n == 'u' then
                local hex = data:sub(pos + 2, pos + 5)

                if hex:match('^%x%x%x%x$') then
                    result[#result + 1] = utf8FromCodepoint(tonumber(hex, 16))
                    pos = pos + 6
                else
                    return nil, pos
                end
            else
                result[#result + 1] = jsonUnescape('\\' .. n)
                pos = pos + 2
            end
        else
            result[#result + 1] = c
            pos = pos + 1
        end
    end

    return nil, pos
end

local function skipSpaces(data, pos)
    while pos <= #data and data:sub(pos, pos):match('%s') do
        pos = pos + 1
    end

    return pos
end

local function parseItemsJson(data)
    local items = {}
    local pos = 1

    data = data:gsub('^\239\187\191', '')
    pos = skipSpaces(data, pos)

    if data:sub(pos, pos) ~= '{' then
        return items
    end

    pos = pos + 1

    while pos <= #data do
        pos = skipSpaces(data, pos)

        if data:sub(pos, pos) == '}' then
            break
        end

        if data:sub(pos, pos) ~= '"' then
            break
        end

        local key
        key, pos = parseJsonString(data, pos)

        if not key then
            break
        end

        pos = skipSpaces(data, pos)

        if data:sub(pos, pos) ~= ':' then
            break
        end

        pos = skipSpaces(data, pos + 1)

        if data:sub(pos, pos) ~= '"' then
            break
        end

        local value
        value, pos = parseJsonString(data, pos)

        if not value then
            break
        end

        if key:match('^%d+$') then
            items[key] = value
        end

        pos = skipSpaces(data, pos)

        local sep = data:sub(pos, pos)

        if sep == ',' then
            pos = pos + 1
        elseif sep == '}' then
            break
        else
            break
        end
    end

    return items
end

local function toCp1251(text)
    local ok, result = pcall(function()
        return u8:decode(text)
    end)

    if ok and result then
        return result
    end

    return text
end

local function convertItemsToCp1251(items)
    local converted = {}

    for id, name in pairs(items) do
        if type(id) == 'string' and type(name) == 'string' then
            converted[id] = toCp1251(name)
        end
    end

    return converted
end

local function loadItemsJson(showMessage)
    local file = io.open(ITEMS_FILE, 'rb')
    if not file then return false end

    local data = file:read('*a')
    file:close()

    local ok, loaded = pcall(parseItemsJson, data)

    if ok and type(loaded) == 'table' and countItems(loaded) > 0 then
        ITEM_NAMES = convertItemsToCp1251(loaded)

        if showMessage and isSampAvailable() then
            itemMessage('Загружено предметов: ' .. countItems(ITEM_NAMES))
        end

        return true
    end

    return false
end

local function updateItemsFromGithub(showMessage)
    if ITEMS_URL == '' then return end

    downloadUrlToFile(ITEMS_URL, ITEMS_FILE, function(id, status)
        if status == DOWNLOAD_DONE then
            lua_thread.create(function()
                wait(500)

                if loadItemsJson(showMessage) then
                    if showMessage then
                        itemMessage('База предметов обновлена с GitHub.')
                    end
                else
                    if showMessage then
                        sampAddChatMessage('{FF7777}[Items] Ошибка загрузки items_cache.json.', hexToSampColor('FF7777'))
                    end
                end
            end)
        end
    end)
end

local function getItemName(id)
    return ITEM_NAMES[id] or ITEM_NAMES[tostring(id)] or (ITEM_WORD .. ' #' .. id)
end

local function fixItemTokens(text)
    local changed = false
    local result = {}
    local pos = 1
    local len = #text

    local function stripLocalColors(s)
        return (s:gsub('{%x%x%x%x%x%x}', ''))
    end

    local function needSpaceBefore(s)
        local plain = stripLocalColors(s)

        if plain == '' then
            return false
        end

        if plain:match('%s$') then
            return false
        end

        if plain:match('[%(%[%{]$') then
            return false
        end

        return true
    end

    local function nextVisibleChar(i)
        if i > len then
            return ''
        end

        local rest = text:sub(i)
        local color = rest:match('^{%x%x%x%x%x%x}')

        if color then
            return nextVisibleChar(i + #color)
        end

        return text:sub(i, i)
    end

    local function needSpaceAfter(i)
        local ch = nextVisibleChar(i)

        if ch == '' then
            return false
        end

        if ch:match('%s') then
            return false
        end

        if ch == ')' or ch == ']' or ch == '}'
            or ch == ',' or ch == '.' or ch == ':'
            or ch == ';' or ch == '!' or ch == '?'
        then
            return false
        end

        return true
    end

    while true do
        local s, e, id = text:find(':[Ii][Tt][Ee][Mm](%d+):?', pos)

        if not s then
            table.insert(result, text:sub(pos))
            break
        end

        local before = text:sub(pos, s - 1)
        table.insert(result, before)

        local names = { getItemName(id) }
        local runEnd = e
        local nextPos = e + 1

        while true do
            local ns, ne, nid = text:find(':[Ii][Tt][Ee][Mm](%d+):?', nextPos)

            if ns == nextPos then
                table.insert(names, getItemName(nid))
                runEnd = ne
                nextPos = ne + 1
            else
                break
            end
        end

        local replaced = table.concat(names, ', ')
        local currentText = table.concat(result)

        if needSpaceBefore(currentText) then
            replaced = ' ' .. replaced
        end

        if needSpaceAfter(runEnd + 1) then
            replaced = replaced .. ' '
        end

        table.insert(result, replaced)

        pos = runEnd + 1
        changed = true
    end

    return table.concat(result), changed
end

function sampev.onSendChat(text)
    local newText, changed = fixItemTokens(text)

    if changed then
        return {newText}
    end
end

function sampev.onSendCommand(cmd)
    local newCmd, changed = fixItemTokens(cmd)

    if changed then
        return {newCmd}
    end
end

local function replaceToken(text, pos1, pos2, rule)
    return text:sub(1, pos1 - 1)
        .. (rule.prefix or '')
        .. '{' .. rule.color .. '}'
        .. rule.tag
        .. text:sub(pos2 + 1)
end

local function lastTextColorBefore(text, pos)
    local before = text:sub(1, pos - 1)
    local lastHex, lastStart, lastEnd = nil, nil, nil

    for s, hex, e in before:gmatch('(){(%x%x%x%x%x%x)}()') do
        lastHex = hex:upper()
        lastStart = s
        lastEnd = e - 1
    end

    return lastHex, lastStart, lastEnd
end

local function textHasRuleColor(text, rules)
    for hex in text:gmatch('{(%x%x%x%x%x%x)}') do
        hex = hex:upper()

        for _, rule in ipairs(rules) do
            if rule.old == hex then
                return rule
            end
        end
    end
end

local function findRuleByColor(color, text, pos, rules)
    local lastHex = lastTextColorBefore(text, pos)

    if lastHex then
        for _, rule in ipairs(rules) do
            if rule.old == lastHex then
                return rule
            end
        end
    end

    for _, rule in ipairs(rules) do
        if colorArgIs(color, rule.old) then
            return rule
        end
    end

    return textHasRuleColor(text, rules)
end

local function processVisibleTag(sourceColor, text, oldTag, rules)
    local pos1, pos2 = text:find(oldTag, 1, true)
    if not pos1 then return text, false, nil end

    local rule = findRuleByColor(sourceColor, text, pos1, rules)
    if not rule then return text, false, nil end

    return replaceToken(text, pos1, pos2, rule), true, rule.color
end

local function processUfTags(text)
    for _, rule in ipairs(UF_RULES) do
        local pos1, pos2 = findToken(text, rule.tokens)

        if pos1 then
            return replaceToken(text, pos1, pos2, rule), true, rule.color
        end
    end

    return text, false, nil
end

local function anyAnnounceColorInText(text)
    for hex in text:gmatch('{(%x%x%x%x%x%x)}') do
        hex = hex:upper()

        if ANNOUNCE_COLORS[hex] then
            return hex
        end
    end
end

local function getAnnounceColor(color, text, pos)
    local hex = lastTextColorBefore(text, pos)

    if hex and ANNOUNCE_COLORS[hex] then
        return hex
    end

    hex = colorFromArg(color)

    if hex then
        return hex
    end

    hex = anyAnnounceColorInText(text)

    if hex then
        return hex
    end

    return '079C1C'
end

local function getDirectEnvelopeAnnounceColor(color, text)
    if not isDirectEnvelopeAnnounce(text) then
        return nil
    end

    local announcePos = text:find(ANNOUNCE_TAG, 1, true)

    if announcePos then
        local hex = lastTextColorBefore(text, announcePos)

        if hex and ANNOUNCE_COLORS[hex] then
            return hex
        end
    end

    for hex in text:gmatch('{(%x%x%x%x%x%x)}') do
        hex = hex:upper()

        if ANNOUNCE_COLORS[hex] then
            return hex
        end
    end

    local hex = colorFromArg(color)

    if hex and ANNOUNCE_COLORS[hex] then
        return hex
    end

    return nil
end

local function replaceAnnounceUf(sourceColor, text)
    for _, token in ipairs(ANNOUNCE_UF) do
        local pos1, pos2 = text:find(token, 1, true)

        if pos1 then
            local hex = getAnnounceColor(sourceColor, text, pos1)
            local lastHex, colorStart, colorEnd = lastTextColorBefore(text, pos1)

            local before = text:sub(1, pos1 - 1)

            if lastHex and ANNOUNCE_COLORS[lastHex] and colorStart and colorEnd then
                local between = text:sub(colorEnd + 1, pos1 - 1)

                if between:match('^%s*$') then
                    before = text:sub(1, colorStart - 1)
                end
            end

            local after = text:sub(pos2 + 1)

            after = after:gsub('^%s*:%s*', ' ')

            if after ~= '' and not after:match('^%s') then
                after = ' ' .. after
            end

            return before
                .. ':envelope: '
                .. '{' .. hex .. '}'
                .. ANNOUNCE_TAG
                .. after, true, hex
        end
    end

    return text, false, nil
end

local function removeCrowns(text)
    local changed = false

    for _, token in ipairs(CROWNS) do
        local p = escapePattern(token)
        local n

        text, n = text:gsub('%s*' .. p .. '%s*:', ':')
        if n > 0 then changed = true end

        text, n = text:gsub('%s*' .. p .. '%s+', ' ')
        if n > 0 then changed = true end

        text, n = text:gsub('%s*' .. p, '')
        if n > 0 then changed = true end
    end

    local n
    text, n = text:gsub('(%[%d+%])%s+:', '%1:')
    if n > 0 then changed = true end

    return text, changed
end

local lastFixedKey = ''
local lastFixedTime = 0

local function addFixedMessage(color, text)
    local now = os.clock()
    local key = tostring(color) .. text

    if key ~= lastFixedKey or now - lastFixedTime > 0.35 then
        sampAddChatMessage(text, color)
        lastFixedKey = key
        lastFixedTime = now
    end

    return false
end

function sampev.onServerMessage(color, text)
    local sourceColor = color
    local lineColor = WHITE_COLOR
    local newText = text
    local changed = false
    local announceColor = nil
    local replaceColor = nil

    local directAnnounceColor = getDirectEnvelopeAnnounceColor(sourceColor, newText)

    if directAnnounceColor then
        return addFixedMessage(hexToSampColor(directAnnounceColor), newText)
    end

    if not shouldHandleServerLine(newText) then
        return
    end

    local fixedItemsText, fixedItems = fixItemTokens(newText)

    if fixedItems then
        newText = fixedItemsText
        changed = true
    end

    local announceText, announceChanged, foundAnnounceColor = replaceAnnounceUf(sourceColor, newText)

    if announceChanged then
        newText = announceText
        announceColor = foundAnnounceColor
        replaceColor = foundAnnounceColor
        changed = true
    end

    local processedText, processed, ruleColor = processUfTags(newText)

    if processed then
        newText = processedText
        replaceColor = ruleColor
        changed = true
    end

    processedText, processed, ruleColor = processVisibleTag(sourceColor, newText, VIP_CHAT_TAG, CHAT_RULES)

    if processed then
        newText = processedText
        replaceColor = ruleColor
        changed = true
    end

    processedText, processed, ruleColor = processVisibleTag(sourceColor, newText, VIP_AD_TAG, AD_RULES)

    if processed then
        newText = processedText
        replaceColor = ruleColor
        changed = true
    end

    processedText, processed, ruleColor = processVisibleTag(sourceColor, newText, ADMIN_TAG, ADMIN_RULES)

    if processed then
        newText = processedText
        replaceColor = ruleColor
        changed = true
    end

    local cleanedText, removedCrowns = removeCrowns(newText)

    if removedCrowns then
        newText = cleanedText
        changed = true
    end

    fixedItemsText, fixedItems = fixItemTokens(newText)

    if fixedItems then
        newText = fixedItemsText
        changed = true
    end

    if changed then
        if not announceColor then
            announceColor = getDirectEnvelopeAnnounceColor(sourceColor, newText)
        end

        if announceColor then
            lineColor = hexToSampColor(announceColor)
        elseif replaceColor then
            lineColor = hexToSampColor(replaceColor)
        else
            lineColor = WHITE_COLOR
        end

        return addFixedMessage(lineColor, newText)
    end
end

function main()
    repeat wait(0) until isSampAvailable()

    loadItemsJson(false)

    lua_thread.create(function()
        wait(3000)
        updateItemsFromGithub(false)
    end)

    sampRegisterChatCommand('itemsupd', function()
        itemMessage('Обновляю базу предметов...')
        updateItemsFromGithub(true)
    end)

    while true do
        wait(1000)
    end
end