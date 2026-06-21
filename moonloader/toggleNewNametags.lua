local ffi = require 'ffi'
ffi.cdef("void __cdecl toggle_nametags(bool enable);")
local inicfg = require 'inicfg'
local directIni = 'newnametags.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        enabled = true
    },
}, directIni))
inicfg.save(ini, directIni)

function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand("newtags", function ()
        ini.main.enabled = not ini.main.enabled
        ffi.load("_chat.asi").toggle_nametags(not ini.main.enabled)
    end)
    wait(-1)
end