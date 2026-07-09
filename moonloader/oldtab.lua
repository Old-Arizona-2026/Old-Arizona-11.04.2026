local FIX_JS = [[
try {
    function forceDisableCEFTab() {
        if (window && window.cef) {
            for (let key in window.cef) {
                let k = key.toLowerCase();
                if ((k.includes('score') || k.includes('tab')) && typeof window.cef[key] === 'function') {
                    if (k.includes('receive') || k.includes('info')) {
                        continue;
                    }
                    try {
                        window.cef[key](false);
                    } catch(err) {}
                }
            }
        }
        if (typeof window.executeEvent === 'function') {
            window.executeEvent('event.scoreboard.setDisabled', `[true]`);
            window.executeEvent('event.scoreboard.setScoreboardDisabled', `[true]`);
        }
    }

    forceDisableCEFTab();

    if (!window._oldTabHook) {
        window._oldTabHook = true;
        const origExec = window.executeEvent;
        if (origExec) {
            window.executeEvent = function(evt, args) {
                let e = evt.toLowerCase();
                if (e.includes('score') || e.includes('tab')) {
                    if (e.includes('show') || e.includes('toggle') || e.includes('enable')) {
                        return;
                    }
                }
                return origExec(evt, args);
            };
        }
        setInterval(forceDisableCEFTab, 2000);
    }
} catch (e) {}
]]

local function applyOldTabFix()
    local code = ("(() => {%s})()"):format(FIX_JS)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 17) 
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt16(bs, #code)
    raknetBitStreamWriteInt8(bs, 0)
    raknetBitStreamWriteString(bs, code)
    raknetEmulPacketReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)
end

function onSendPacket(id, bs, priority, reliability, orderingChannel)
    if id == 220 then
        raknetBitStreamReadInt8(bs)
        if raknetBitStreamReadInt8(bs) == 18 then
            local strlen = raknetBitStreamReadInt16(bs)
            if raknetBitStreamReadString(bs, strlen):find("onSvelteAppVersion") then
                applyOldTabFix()
            end
        end
        raknetBitStreamResetReadPointer(bs)
    end
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(250) end
    wait(1500)
    applyOldTabFix()
    wait(-1)
end