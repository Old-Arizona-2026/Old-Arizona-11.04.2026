script_name('RestoreDialog')
script_author('quesada / https://t.me/quesada_self')

require('lib.moonloader')
local ffi = require('ffi')
local sampev = require "samp.events"

ffi.cdef[[
    void* LoadLibraryA(const char* lpLibFileName);
    void* GetProcAddress(void* hModule, const char* lpProcName);
    int   FreeLibrary(void* hModule);
]]

local kernel32 = ffi.load('kernel32')

local function format_with_dots(num) -- https://www.blast.hk/threads/253262/
    num = math.floor(tonumber(num) or 0)
    local s = tostring(num)
    local rev = s:reverse():gsub("(%d%d%d)", "%1.")
    s = rev:reverse()
    if s:sub(1, 1) == "." then
        s = s:sub(2)
    end
    return s
end

local function parse_k_value(str) -- https://www.blast.hk/threads/253262/
    str = tostring(str or "")
    str = str:gsub("%.", "")
    return tonumber(str) or 0
end

local function build_money(m, kk, k) -- https://www.blast.hk/threads/253262/
    local total = 0

    if m then
        total = total + (tonumber(m) or 0) * 1000000000
    end

    if kk then
        total = total + (tonumber(kk) or 0) * 1000000
    end

    if k then
        total = total + parse_k_value(k)
    end

    return format_with_dots(total)
end

local function convert_money_tags(text) -- https://www.blast.hk/threads/253262/
    if type(text) ~= "string" or text == "" then
        return text
    end

    text = text:gsub(":M:%s*(%d+)%s*:KK:%s*(%d+)%s*:K:%s*([%d%.]+)", function(m, kk, k)
        return build_money(m, kk, k)
    end)

    text = text:gsub(":M:%s*(%d+)%s*:KK:%s*(%d+)", function(m, kk)
        return build_money(m, kk, nil)
    end)

    text = text:gsub(":M:%s*(%d+)%s*:K:%s*([%d%.]+)", function(m, k)
        return build_money(m, nil, k)
    end)

    text = text:gsub(":KK:%s*(%d+)%s*:K:%s*([%d%.]+)", function(kk, k)
        return build_money(nil, kk, k)
    end)

    text = text:gsub(":M:%s*(%d+)", function(m)
        return build_money(m, nil, nil)
    end)

    text = text:gsub(":KK:%s*(%d+)", function(kk)
        return build_money(nil, kk, nil)
    end)

    text = text:gsub(":K:%s*([%d%.]+)", function(k)
        return build_money(nil, nil, k)
    end)

    return text
end

function loadDll()
    local hDll = kernel32.LoadLibraryA('vorbisFile.dll')
    if hDll == nil or hDll == ffi.cast('void*', 0) then
        print('error in LoadLibraryA')
        return nil, nil
    end
    local fnToggle = kernel32.GetProcAddress(hDll, 'ToggleCefDialogs')
    local fnAreEnabled = kernel32.GetProcAddress(hDll, 'AreCefDialogsEnabled')
    if fnToggle == nil or fnToggle == ffi.cast('void*', 0) then
        print('ToggleCefDialogs not found')
        return nil, nil
    end
    if fnAreEnabled == nil or fnAreEnabled == ffi.cast('void*', 0) then
        print('AreCefDialogsEnabled not found')
        return nil, nil
    end
    return ffi.cast('void(__cdecl*)(int)', fnToggle),
           ffi.cast('int(__cdecl*)(void)', fnAreEnabled)
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if style == 6 then
        title = convert_money_tags(title)
        text = convert_money_tags(text)
        return {id, 1, title, button1, button2, text}
    end
end

function main()
    while not isSampAvailable() do wait(100) end

    toggleFn, areEnabledFn = loadDll()
    if not toggleFn then
        return print('error load dll!')
    end

    local ok, err = pcall(function() toggleFn(0) end)
    if ok then
        print('CEF Dialogs disabled!')
    else
        print('error call ToggleCefDialogs: ' .. tostring(err))
        return
    end

    while true do wait(2000)
        local ok2, result = pcall(areEnabledFn)
        if ok2 and result ~= 0 then
            pcall(function() toggleFn(0) end)
        end
    end
end

