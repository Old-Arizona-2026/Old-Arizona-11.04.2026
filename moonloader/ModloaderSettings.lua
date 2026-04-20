local lfs = require('lfs')
local imgui = require('mimgui')
local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

table.length, table.push = table.getn, table.insert;
function table.forEach(self, callback) for k, v in pairs(self) do callback(v, k); end end
function table.includes(self, value, searchStartIndex) local foundIndex; table.forEach(self, function(v, index) if (v == value and index >= (searchStartIndex or 1)) then foundIndex = index; end end); return foundIndex ~= nil, foundIndex; end
function table.filter(self, callback) table.forEach(self, function(value, index) if (not callback(value, index)) then self[index] = nil; end end); end
function table.keys(self) local keys = {}; table.forEach(self, function(_, k) table.insert(keys, k); end); return keys; end
function table.values(self) local values = {}; table.forEach(self, function(v, _) table.insert(values, v); end); return values; end

local config = {}
local mods = {}
local setupJScode = ""
local checkedChanges = {}

local renderWindow = imgui.new.bool(false)

addEventHandler("onWindowMessage", function (msg, wp, lp)
    if wp == 0x1B and renderWindow[0] then
        if msg == 0x100 then
            consumeWindowMessage(true, false)
        end
        if msg == 0x101 then
            renderWindow[0] = false
        end
    end
end)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    BlackTheme()
end)

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 860, 550
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        if imgui.Begin(u8('MODLOADER'), renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
            imgui.BeginChild("##modlist", imgui.ImVec2(400, -1), true)
            for k, v in pairs(mods) do
                imgui.BeginChild("##"..k..v.name, imgui.ImVec2(-1, 70), true)
                imgui.Text(u8(v.name))
                if ToggleButton("##toggle"..k..v.name, v.active) then
                    v.active[0] = not v.active[0]
                    saveCurrentConfig()
                end
                imgui.SameLine()
                imgui.PushItemWidth(120)
                if imgui.InputInt(u8("Ïðèîðèòåò"), v.priority, 1, 10) then
                    saveCurrentConfig()
                end
                imgui.EndChild()
            end
            imgui.EndChild()
            imgui.SameLine()
            imgui.BeginChild("##profiledefault", imgui.ImVec2(-1, -1), true)
            for k, v in pairs(config) do
                if imgui.CollapsingHeader(u8(k)) then
                    for kk, vv in pairs(v) do
                        if type(kk) == "string" then
                            imgui.Text(u8(string.format("%s = %s", kk, vv)))
                        else
                            imgui.Text(u8(vv))
                        end
                    end
                end
            end
            imgui.EndChild()
            imgui.End()
        end
    end
)

function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('mods', function()
        renderWindow[0] = not renderWindow[0]
    end)
    while true do
        wait(0)
        getChanges(function (modname, active, priority)
            for _, v in pairs(mods) do
                if v.name == modname then
                    v.active[0] = active
                    v.priority[0] = priority
                    saveCurrentConfig()
                    break
                end
            end
        end)
        mods = get_all_mods(getGameDirectory().."\\modloader")
        wait(500)
    end
end

lua_thread.create(function ()
    while not isSampAvailable() do wait(0) end
    while true do
        wait(0)
        evalanon(([[
            window.mods = %s
        ]]):format(modsToJson(mods)))
        wait(2500)
    end
end)

function modsToJson(list)
    local result = {}
    for k, v in ipairs(list) do
        table.insert(result, {
            active = v.active[0],
            name = v.name,
            priority = v.priority[0],
        })
    end

    return encodeJson(result)
end

function isModActive(modname)
    local res = table.includes(config.IgnoreMods, modname)
    return not res
end

function get_all_mods(path)
    local result = {}
    local entries = {}
    for entry in lfs.dir(path) do
        if entry ~= "." and entry ~= ".." then
            local entry_path = path .. "/" .. entry
            local entry_type = lfs.attributes(entry_path, "mode")
            if entry_type == "directory" and entry:sub(1, 1) ~= "." then
                table.insert(entries, entry)
            end
        end
    end
    config = loadConfig()
    for k, v in pairs(entries) do
        table.insert(result, {
            name = v,
            active = imgui.new.bool(isModActive(v)),
            priority = imgui.new.int(config.Priority[v] or 50),
        })
    end
    return result
end

function loadConfig()
    local ini = parse_ini(getGameDirectory().."\\modloader\\modloader.ini")
    local result = {}
    for key, value in pairs(ini) do
        local keyN = key:match("Profiles%..-%.(.+)")
        if keyN then result[keyN] = value end
    end

    return result
end

function BlackTheme()
    local style = imgui.GetStyle()
    local colors = style.Colors

    colors[imgui.Col.WindowBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[imgui.Col.ChildBg]        = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[imgui.Col.PopupBg]        = imgui.ImVec4(0.02, 0.02, 0.02, 0.95)

    colors[imgui.Col.Text]           = imgui.ImVec4(0.95, 0.95, 0.95, 1.00)
    colors[imgui.Col.TextDisabled]   = imgui.ImVec4(0.40, 0.40, 0.40, 1.00)

    colors[imgui.Col.Border]         = imgui.ImVec4(0.15, 0.15, 0.15, 0.60)
    colors[imgui.Col.BorderShadow]   = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)

    local accent       = imgui.ImVec4(0.00, 0.55, 1.00, 1.00)
    local accentHover  = imgui.ImVec4(0.10, 0.65, 1.00, 1.00)
    local accentActive = imgui.ImVec4(0.00, 0.45, 0.90, 1.00)
    local frameHover   = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
    local frameActive  = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)

    colors[imgui.Col.FrameBg]            = imgui.ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[imgui.Col.FrameBgHovered]     = frameHover
    colors[imgui.Col.FrameBgActive]      = frameActive

    colors[imgui.Col.TitleBg]            = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[imgui.Col.TitleBgActive]      = imgui.ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[imgui.Col.TitleBgCollapsed]   = imgui.ImVec4(0.00, 0.00, 0.00, 0.75)

    colors[imgui.Col.MenuBarBg]          = imgui.ImVec4(0.03, 0.03, 0.03, 1.00)

    colors[imgui.Col.Button]             = imgui.ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[imgui.Col.ButtonHovered]      = accentHover
    colors[imgui.Col.ButtonActive]       = accentActive

    colors[imgui.Col.Header]             = imgui.ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[imgui.Col.HeaderHovered]      = accentHover
    colors[imgui.Col.HeaderActive]       = accentActive

    colors[imgui.Col.ScrollbarBg]        = imgui.ImVec4(0.02, 0.02, 0.02, 1.00)
    colors[imgui.Col.ScrollbarGrab]      = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    colors[imgui.Col.ScrollbarGrabHovered]= imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[imgui.Col.ScrollbarGrabActive]= imgui.ImVec4(0.40, 0.40, 0.40, 1.00)

    colors[imgui.Col.CheckMark]          = accent
    colors[imgui.Col.SliderGrab]         = accent
    colors[imgui.Col.SliderGrabActive]   = accentActive

    colors[imgui.Col.Tab]                = imgui.ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[imgui.Col.TabHovered]         = accentHover
    colors[imgui.Col.TabActive]          = accentActive
    colors[imgui.Col.TabUnfocused]       = imgui.ImVec4(0.02, 0.02, 0.02, 1.00)
    colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.05, 0.05, 0.05, 1.00)

    style.WindowRounding    = 10.0
    style.ChildRounding     = 10.0
    style.FrameRounding     = 6.0
    style.PopupRounding     = 6.0
    style.ScrollbarRounding = 6.0
    style.GrabRounding      = 6.0
    style.TabRounding       = 6.0

    style.WindowPadding     = imgui.ImVec2(10, 10)
    style.FramePadding      = imgui.ImVec2(12, 6)
    style.ItemSpacing       = imgui.ImVec2(8, 6)
    style.WindowTitleAlign  = imgui.ImVec2(0.50, 0.50)
    style.WindowMinSize     = imgui.ImVec2(50.00, 50.00)

    style.WindowBorderSize  = 1.0
    style.FrameBorderSize   = 0.0
end

function ToggleButton(id, v, size)
    local ImVec2 = imgui.ImVec2
    local ImVec4 = imgui.ImVec4
    size = size or ImVec2(50, 24)

    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()

    local width = size.x
    local height = size.y
    local radius = height * 0.5

    local result = imgui.InvisibleButton(id, size)

    local t = v[0] and 1.0 or 0.0

    local bgColor
    if v[0] then
        bgColor = imgui.GetColorU32Vec4(ImVec4(0.20, 0.70, 0.20, 1.00))
    else
        bgColor = imgui.GetColorU32Vec4(ImVec4(0.50, 0.50, 0.50, 1.00))
    end

    draw_list:AddRectFilled(
        p,
        ImVec2(p.x + width, p.y + height),
        bgColor,
        radius
    )

    draw_list:AddCircleFilled(
        ImVec2(p.x + radius + t * (width - radius * 2), p.y + radius),
        radius - 2.0,
        imgui.GetColorU32Vec4(ImVec4(1.00, 1.00, 1.00, 1.00)), 16
    )

    return result
end

function onSendPacket(id, bs, priority, reliability, orderingChannel)
    if id == 220 then
        id = raknetBitStreamReadInt8(bs)
        local packettype = raknetBitStreamReadInt8(bs)
        if packettype == 18 then
            local strlen = raknetBitStreamReadInt16(bs)
            local str = raknetBitStreamReadString(bs, strlen)
            if str:find("mainMenu.selectScreen|2") then
                evalanon(setupJScode)
            end
        end
    end
end

function getChanges(callback)
    local function clearCEFlog()
        local file = io.open(getGameDirectory()..'\\cef\\!CEFLOG.txt', 'w')
        if file then
            file:write("")
            file:close()
        end
    end
    for line in io.lines(getGameDirectory()..'\\cef\\!CEFLOG.txt') do
        if line:find('%[.+%] "modloader: (.+):(.+):(.+):(.+)", source: .+') then
            local unixS, modname, active, priority = line:match('%[.+%] "modloader: (.+):(.+):(.+):(.+)", source: .+')
            local unix = tonumber(unixS)
            print(unix, unixS, modname, active, priority, checkedChanges[unix])
            if not checkedChanges[unix] then
                checkedChanges[unix] = true
                callback(modname, active == "true", tonumber(priority))
            end
        end
    end
    clearCEFlog()
end

function evalanon(code)
    evalcef(("(() => {%s})()"):format(code))
end

function evalcef(code, encoded)
    encoded = encoded or 0
    local bs = raknetNewBitStream();
    raknetBitStreamWriteInt8(bs, 17);
    raknetBitStreamWriteInt32(bs, 0);
    raknetBitStreamWriteInt16(bs, #code);
    raknetBitStreamWriteInt8(bs, encoded);
    raknetBitStreamWriteString(bs, code);
    raknetEmulPacketReceiveBitStream(220, bs);
    raknetDeleteBitStream(bs);
end

function tableToString(t,i)i=i or 0;local s={"{"}for k,v in pairs(t)do local p=string.rep("    ",i+1)v=type(v)=="table" and tableToString(v,i+1)or type(v)=="string" and("'"..v.."'")or tostring(v)table.insert(s,type(k)=="number" and(p..v..",")or(p..k.." = "..v..","))end table.insert(s,string.rep("    ",i).."}")return table.concat(s,"\n")end
function trim(s) return s:match("^%s*(.-)%s*$") end
function parse_ini(p)local r,c={},r for l in io.lines(p)do l=l:match("^%s*(.-)%s*$")if l~=""and not l:match("^[;#]")then l=l:gsub("%s*[;#].-$","")l=l:match("^%s*(.-)%s*$")if l~=""then local n=l:match("^%[(.-)%]$")if n then r[n]=r[n]or{}c=r[n]else local k,v=l:match("^([^=]+)=(.*)$")if k then k=k:match("^%s*(.-)%s*$")v=v:match("^%s*(.-)%s*$")if v=="true"then v=true elseif v=="false"then v=false elseif tonumber(v)then v=tonumber(v)end c[k]=v else c[#c+1]=l end end end end end return r end
function saveConfig(p,n,c)local f=assert(io.open(p,"w"))f:write("[Folder.Config]\nProfile = ",n,"\n\n")for _,s in ipairs({"Config","Priority","IgnoreFiles","IgnoreMods","IncludeMods","ExclusiveMods"})do local t=c[s]or{}f:write("[Profiles.",n,".",s,"]\n")local a={}for k,v in pairs(t)do a[#a+1]=k end;table.sort(a,function(x,y)return tostring(x)<tostring(y)end)for _,k in ipairs(a)do local v=t[k]if type(k)=="number"then f:write(tostring(v),"\n")else f:write(tostring(k)," = ",type(v)=="boolean"and(v and"true"or"false")or tostring(v),"\n")end end f:write("\n")end f:close()end
function saveCurrentConfig()local c={Config=config.Config or{},Priority={},IgnoreFiles=config.IgnoreFiles or{},IgnoreMods={},IncludeMods=config.IncludeMods or{},ExclusiveMods=config.ExclusiveMods or{}}for _,v in ipairs(mods)do if not v.active[0]then c.IgnoreMods[#c.IgnoreMods+1]=v.name end c.Priority[v.name]=v.priority[0]end saveConfig(getGameDirectory().."\\modloader\\modloader.ini","Default",c)config=c end
setupJScode = [[
const logChanges = (modname, active, priority) => {
	console.log(`modloader: ${Math.floor(Date.now() / 1000)}:${modname}:${active}:${priority}`);
};

if (!Array.isArray(window.mods)) {
	window.mods = [];
}

const menu_nav = document.querySelector(".main-menu-settings__navigation");
const custom_tab_id = "modloadertab";
const custom_content_id = "modloader-content";
let custom_tab = null;
let eventsInitialized = false;

const getMods = () => {
	return Array.isArray(window.mods) ? window.mods : [];
};

const isCustomTabOpened = () => {
	return !!(
		custom_tab &&
		custom_tab.classList.contains(
			"main-menu-settings__navigation-item--active",
		)
	);
};

const refreshCustomTabSettings = () => {
	if (!isCustomTabOpened()) return;
	createCustomTabSettings();
};

(() => {
	let internalMods = Array.isArray(window.mods) ? window.mods : [];

	Object.defineProperty(window, "mods", {
		configurable: true,
		enumerable: true,
		get() {
			return internalMods;
		},
		set(value) {
			internalMods = Array.isArray(value) ? value : [];
			refreshCustomTabSettings();
		},
	});
})();

window.refreshModsUI = () => {
	refreshCustomTabSettings();
};

const isTabExist = () => {
	return !!document.getElementById(custom_tab_id);
};

const setCustomTabActive = (active) => {
	if (active) {
		const tabs = document.querySelectorAll(
			".main-menu-settings__navigation-item",
		);
		tabs.forEach((el) => {
			if (
				el.classList.contains(
					"main-menu-settings__navigation-item--active",
				)
			) {
				el.classList.remove(
					"main-menu-settings__navigation-item--active",
				);
			}
		});
		custom_tab.classList.add("main-menu-settings__navigation-item--active");
	} else if (custom_tab) {
		custom_tab.classList.remove(
			"main-menu-settings__navigation-item--active",
		);
	}
};

const tabsCallback = (e) => {
	const isCustomTab = e.currentTarget.id === custom_tab_id;
	removeCustomTabSettings();

	if (isCustomTab) {
		setCustomTabActive(true);
		toggleOriginalContent(true);
		createCustomTabSettings();
	} else {
		setCustomTabActive(false);
		removeCustomTabSettings();
		toggleOriginalContent(false);
	}
};

const setCustomTabEvent = () => {
	if (eventsInitialized) return;
	eventsInitialized = true;

	const tabs = document.querySelectorAll(
		".main-menu-settings__navigation-item",
	);

	tabs.forEach((el, index) => {
		el.dataset.index = index;
		el.addEventListener("click", tabsCallback);
	});
};

const createCustomTab = () => {
	if (!isTabExist()) {
		custom_tab = document.createElement("div");
		custom_tab.className = "main-menu-settings__navigation-item";
		custom_tab.id = custom_tab_id;
		custom_tab.textContent = "MODLOADER";

		menu_nav.appendChild(custom_tab);
		setCustomTabEvent();
	}
};

function createConfigurationControl({
	value = 50,
	gradient = "linear-gradient(90deg, #CC3048 0%, #364B84 100%)",
	onChange = null,
} = {}) {
	let currentValue = Math.max(0, Math.min(100, value));

	const root = document.createElement("div");
	root.className = "main-menu-settings__configuration-control";

	const slider = document.createElement("div");
	slider.className = "main-menu-slider svelte-8m8tz7";
	slider.style.setProperty("--gradient", gradient);

	const valueEl = document.createElement("div");
	valueEl.className = "main-menu-slider__value svelte-8m8tz7";

	const progressBar = document.createElement("div");
	progressBar.className = "main-menu-slider__progress-bar svelte-8m8tz7";
	progressBar.style.width = "80%";

	const inner = document.createElement("div");
	inner.className = "main-menu-slider__inner svelte-8m8tz7";

	const active = document.createElement("div");
	active.className = "main-menu-slider__progress-active svelte-8m8tz7";

	const tracker = document.createElement("div");
	tracker.className = "main-menu-slider__tracker svelte-8m8tz7";

	active.appendChild(tracker);
	inner.appendChild(active);
	progressBar.appendChild(inner);
	slider.appendChild(valueEl);
	slider.appendChild(progressBar);
	root.appendChild(slider);

	function setValue(newValue, emit = true) {
		currentValue = Math.max(0, Math.min(100, Math.round(newValue)));

		valueEl.textContent = `${currentValue}`;
		active.style.setProperty("--progress", `${currentValue}%`);
		active.style.width = `${currentValue}%`;
		active.style.background = gradient;

		if (typeof onChange === "function" && emit) {
			onChange(currentValue, root);
		}
	}

	function updateFromPointer(clientX) {
		const rect = progressBar.getBoundingClientRect();
		const x = clientX - rect.left;
		const percent = (x / rect.width) * 100;
		setValue(percent);
	}

	let isDragging = false;

	function onPointerDown(e) {
		isDragging = true;
		slider.classList.add("is-dragging");
		updateFromPointer(e.clientX);

		if (progressBar.setPointerCapture) {
			progressBar.setPointerCapture(e.pointerId);
		}
	}

	function onPointerMove(e) {
		if (!isDragging) return;
		updateFromPointer(e.clientX);
	}

	function onPointerUp(e) {
		isDragging = false;
		slider.classList.remove("is-dragging");

		if (progressBar.releasePointerCapture) {
			try {
				progressBar.releasePointerCapture(e.pointerId);
			} catch {}
		}
	}

	progressBar.style.cursor = "pointer";
	tracker.style.cursor = "grab";

	progressBar.addEventListener("pointerdown", onPointerDown);
	progressBar.addEventListener("pointermove", onPointerMove);
	progressBar.addEventListener("pointerup", onPointerUp);
	progressBar.addEventListener("pointercancel", onPointerUp);
	progressBar.addEventListener("lostpointercapture", onPointerUp);

	setValue(currentValue, false);

	root.setValue = setValue;
	root.getValue = () => currentValue;

	return root;
}

function createSwitchControl({ value = false, onChange = null } = {}) {
	let currentValue = Boolean(value);

	const root = document.createElement("div");
	root.className = "main-menu-settings__configuration-control";
	root.style.width = "100%";
	root.style.minWidth = "0";
	root.style.maxWidth = "none";

	const switchWrapper = document.createElement("div");
	switchWrapper.className = "main-menu-switch";
	switchWrapper.style.width = "100%";
	switchWrapper.style.minWidth = "0";
	switchWrapper.style.maxWidth = "none";
	switchWrapper.style.cursor = "pointer";

	const stateOff = document.createElement("div");
	stateOff.className = "main-menu-switch__state";

	const stateOn = document.createElement("div");
	stateOn.className = "main-menu-switch__state";

	const textOff = document.createElement("div");
	textOff.className = "main-menu-switch__state-text";
	textOff.textContent = "ÂÛÊË";
	textOff.style.position = "relative";
	textOff.style.zIndex = "2";

	const textOn = document.createElement("div");
	textOn.className = "main-menu-switch__state-text";
	textOn.textContent = "ÂÊË";
	textOn.style.position = "relative";
	textOn.style.zIndex = "2";

	const bg = document.createElement("div");
	bg.className = "main-menu-switch__bg";
	bg.style.zIndex = "1";

	stateOff.appendChild(textOff);
	stateOn.appendChild(textOn);

	switchWrapper.appendChild(stateOff);
	switchWrapper.appendChild(stateOn);
	root.appendChild(switchWrapper);

	function render() {
		stateOff.classList.remove("main-menu-switch__state--active");
		stateOn.classList.remove("main-menu-switch__state--active");
		textOff.classList.remove("main-menu-switch__state-text--active");
		textOn.classList.remove("main-menu-switch__state-text--active");

		if (currentValue) {
			stateOn.classList.add("main-menu-switch__state--active");
			textOn.classList.add("main-menu-switch__state-text--active");

			if (bg.parentNode !== stateOn) {
				stateOn.appendChild(bg);
			}
		} else {
			stateOff.classList.add("main-menu-switch__state--active");
			textOff.classList.add("main-menu-switch__state-text--active");

			if (bg.parentNode !== stateOff) {
				stateOff.appendChild(bg);
			}
		}
	}

	function setValue(newValue, emit = true) {
		currentValue = Boolean(newValue);
		render();

		if (typeof onChange === "function" && emit) {
			onChange(currentValue, root);
		}
	}

	function toggle() {
		setValue(!currentValue);
	}

	stateOff.addEventListener("click", (e) => {
		e.stopPropagation();
		setValue(false);
	});

	stateOn.addEventListener("click", (e) => {
		e.stopPropagation();
		setValue(true);
	});

	switchWrapper.addEventListener("click", () => {
		toggle();
	});

	render();

	root.setValue = setValue;
	root.getValue = () => currentValue;
	root.toggle = toggle;

	return root;
}

const createSetting = (mod, index) => {
	const configuration = document.createElement("div");
	configuration.id = "item-0-" + index;
	configuration.classList.add("main-menu-settings__configuration");

	configuration.style.display = "grid";
	configuration.style.gridTemplateColumns = "repeat(3, minmax(0, 1fr))";
	configuration.style.width = "100%";

	const name = document.createElement("div");
	name.classList.add("main-menu-settings__configuration-name");
	name.textContent = mod.name;

	name.style.width = "100%";
	name.style.minWidth = "0";
	name.style.maxWidth = "none";

	const control = createSwitchControl({
		value: mod.active,
		onChange: (newValue) => {
			mod.active = newValue;
			logChanges(mod.name, mod.active, mod.priority);
		},
	});

	const prioritySlider = createConfigurationControl({
		value: mod.priority,
		onChange: (newValue) => {
			mod.priority = newValue;
			logChanges(mod.name, mod.active, mod.priority);
		},
	});

	prioritySlider.style.width = "100%";
	prioritySlider.style.minWidth = "0";
	prioritySlider.style.maxWidth = "none";
	prioritySlider.style.boxSizing = "border-box";

	configuration.appendChild(name);
	configuration.appendChild(control);
	configuration.appendChild(prioritySlider);

	return configuration;
};

const removeCustomTabSettings = () => {
	const customContent = document.getElementById(custom_content_id);
	if (customContent) customContent.remove();
};

const toggleOriginalContent = (hidden) => {
	const contents = document.querySelectorAll(".main-menu-settings__group");
	const subnav = document.querySelector(
		".main-menu-settings__sub-navigation",
	);

	contents.forEach((el) => {
		if (el.id !== custom_content_id) {
			el.style.display = hidden ? "none" : "";
		}
	});

	if (subnav) subnav.style.display = hidden ? "none" : "";
};

const createCustomTabSettings = () => {
	const parent = document.querySelector(
		".main-menu-settings__scroll-wrapper",
	);

	if (!parent) return;

	removeCustomTabSettings();

	const div0 = document.createElement("div");
	div0.className = "main-menu-settings__group";
	div0.id = custom_content_id;

	const header = document.createElement("div");
	header.className = "main-menu-settings__group-title";
	header.textContent = "ÌÎÄÛ";

	const content = document.createElement("div");
	content.className = "main-menu-settings__list";

	const mods = getMods();

	mods.forEach((mod, index) => {
		content.appendChild(createSetting(mod, index));
	});

	div0.appendChild(header);
	div0.appendChild(content);
	parent.appendChild(div0);
};

const tabs = document.querySelectorAll(".main-menu-settings__navigation-item");
tabs.forEach((el) => {
	if (el.textContent === "MODLOADER") {
		el.remove();
	}
});

createCustomTab();
]]