-- This file is part of SA MoonLoader package.
-- Licensed under the MIT License.
-- Copyright (c) 2016, BlastHack Team <blast.hk>

-- Names modified by KyRDa for LEA

local k = {
	VK_LBUTTON = 0x01,
	VK_RBUTTON = 0x02,
	VK_CANCEL = 0x03,
	VK_MBUTTON = 0x04,
	VK_XBUTTON1 = 0x05,
	VK_XBUTTON2 = 0x06,
	VK_BACK = 0x08,
	VK_TAB = 0x09,
	VK_CLEAR = 0x0C,
	VK_RETURN = 0x0D,
	VK_SHIFT = 0x10,
	VK_CONTROL = 0x11,
	VK_MENU = 0x12,
	VK_PAUSE = 0x13,
	VK_CAPITAL = 0x14,
	VK_KANA = 0x15,
	VK_JUNJA = 0x17,
	VK_FINAL = 0x18,
	VK_KANJI = 0x19,
	VK_ESCAPE = 0x1B,
	VK_CONVERT = 0x1C,
	VK_NONCONVERT = 0x1D,
	VK_ACCEPT = 0x1E,
	VK_MODECHANGE = 0x1F,
	VK_SPACE = 0x20,
	VK_PRIOR = 0x21,
	VK_NEXT = 0x22,
	VK_END = 0x23,
	VK_HOME = 0x24,
	VK_LEFT = 0x25,
	VK_UP = 0x26,
	VK_RIGHT = 0x27,
	VK_DOWN = 0x28,
	VK_SELECT = 0x29,
	VK_PRINT = 0x2A,
	VK_EXECUTE = 0x2B,
	VK_SNAPSHOT = 0x2C,
	VK_INSERT = 0x2D,
	VK_DELETE = 0x2E,
	VK_HELP = 0x2F,
	VK_0 = 0x30,
	VK_1 = 0x31,
	VK_2 = 0x32,
	VK_3 = 0x33,
	VK_4 = 0x34,
	VK_5 = 0x35,
	VK_6 = 0x36,
	VK_7 = 0x37,
	VK_8 = 0x38,
	VK_9 = 0x39,
	VK_A = 0x41,
	VK_B = 0x42,
	VK_C = 0x43,
	VK_D = 0x44,
	VK_E = 0x45,
	VK_F = 0x46,
	VK_G = 0x47,
	VK_H = 0x48,
	VK_I = 0x49,
	VK_J = 0x4A,
	VK_K = 0x4B,
	VK_L = 0x4C,
	VK_M = 0x4D,
	VK_N = 0x4E,
	VK_O = 0x4F,
	VK_P = 0x50,
	VK_Q = 0x51,
	VK_R = 0x52,
	VK_S = 0x53,
	VK_T = 0x54,
	VK_U = 0x55,
	VK_V = 0x56,
	VK_W = 0x57,
	VK_X = 0x58,
	VK_Y = 0x59,
	VK_Z = 0x5A,
	VK_LWIN = 0x5B,
	VK_RWIN = 0x5C,
	VK_APPS = 0x5D,
	VK_SLEEP = 0x5F,
	VK_NUMPAD0 = 0x60,
	VK_NUMPAD1 = 0x61,
	VK_NUMPAD2 = 0x62,
	VK_NUMPAD3 = 0x63,
	VK_NUMPAD4 = 0x64,
	VK_NUMPAD5 = 0x65,
	VK_NUMPAD6 = 0x66,
	VK_NUMPAD7 = 0x67,
	VK_NUMPAD8 = 0x68,
	VK_NUMPAD9 = 0x69,
	VK_MULTIPLY = 0x6A,
	VK_ADD = 0x6B,
	VK_SEPARATOR = 0x6C,
	VK_SUBTRACT = 0x6D,
	VK_DECIMAL = 0x6E,
	VK_DIVIDE = 0x6F,
	VK_F1 = 0x70,
	VK_F2 = 0x71,
	VK_F3 = 0x72,
	VK_F4 = 0x73,
	VK_F5 = 0x74,
	VK_F6 = 0x75,
	VK_F7 = 0x76,
	VK_F8 = 0x77,
	VK_F9 = 0x78,
	VK_F10 = 0x79,
	VK_F11 = 0x7A,
	VK_F12 = 0x7B,
	VK_F13 = 0x7C,
	VK_F14 = 0x7D,
	VK_F15 = 0x7E,
	VK_F16 = 0x7F,
	VK_F17 = 0x80,
	VK_F18 = 0x81,
	VK_F19 = 0x82,
	VK_F20 = 0x83,
	VK_F21 = 0x84,
	VK_F22 = 0x85,
	VK_F23 = 0x86,
	VK_F24 = 0x87,
	VK_NUMLOCK = 0x90,
	VK_SCROLL = 0x91,
	VK_OEM_FJ_JISHO = 0x92,
	VK_OEM_FJ_MASSHOU = 0x93,
	VK_OEM_FJ_TOUROKU = 0x94,
	VK_OEM_FJ_LOYA = 0x95,
	VK_OEM_FJ_ROYA = 0x96,
	VK_LSHIFT = 0xA0,
	VK_RSHIFT = 0xA1,
	VK_LCONTROL = 0xA2,
	VK_RCONTROL = 0xA3,
	VK_LMENU = 0xA4,
	VK_RMENU = 0xA5,
	VK_BROWSER_BACK = 0xA6,
	VK_BROWSER_FORWARD = 0xA7,
	VK_BROWSER_REFRESH = 0xA8,
	VK_BROWSER_STOP = 0xA9,
	VK_BROWSER_SEARCH = 0xAA,
	VK_BROWSER_FAVORITES = 0xAB,
	VK_BROWSER_HOME = 0xAC,
	VK_VOLUME_MUTE = 0xAD,
	VK_VOLUME_DOWN = 0xAE,
	VK_VOLUME_UP = 0xAF,
	VK_MEDIA_NEXT_TRACK = 0xB0,
	VK_MEDIA_PREV_TRACK = 0xB1,
	VK_MEDIA_STOP = 0xB2,
	VK_MEDIA_PLAY_PAUSE = 0xB3,
	VK_LAUNCH_MAIL = 0xB4,
	VK_LAUNCH_MEDIA_SELECT = 0xB5,
	VK_LAUNCH_APP1 = 0xB6,
	VK_LAUNCH_APP2 = 0xB7,
	VK_OEM_1 = 0xBA,
	VK_OEM_PLUS = 0xBB,
	VK_OEM_COMMA = 0xBC,
	VK_OEM_MINUS = 0xBD,
	VK_OEM_PERIOD = 0xBE,
	VK_OEM_2 = 0xBF,
	VK_OEM_3 = 0xC0,
	VK_ABNT_C1 = 0xC1,
	VK_ABNT_C2 = 0xC2,
	VK_OEM_4 = 0xDB,
	VK_OEM_5 = 0xDC,
	VK_OEM_6 = 0xDD,
	VK_OEM_7 = 0xDE,
	VK_OEM_8 = 0xDF,
	VK_OEM_AX = 0xE1,
	VK_OEM_102 = 0xE2,
	VK_ICO_HELP = 0xE3,
	VK_PROCESSKEY = 0xE5,
	VK_ICO_CLEAR = 0xE6,
	VK_PACKET = 0xE7,
	VK_OEM_RESET = 0xE9,
	VK_OEM_JUMP = 0xEA,
	VK_OEM_PA1 = 0xEB,
	VK_OEM_PA2 = 0xEC,
	VK_OEM_PA3 = 0xED,
	VK_OEM_WSCTRL = 0xEE,
	VK_OEM_CUSEL = 0xEF,
	VK_OEM_ATTN = 0xF0,
	VK_OEM_FINISH = 0xF1,
	VK_OEM_COPY = 0xF2,
	VK_OEM_AUTO = 0xF3,
	VK_OEM_ENLW = 0xF4,
	VK_OEM_BACKTAB = 0xF5,
	VK_ATTN = 0xF6,
	VK_CRSEL = 0xF7,
	VK_EXSEL = 0xF8,
	VK_EREOF = 0xF9,
	VK_PLAY = 0xFA,
	VK_ZOOM = 0xFB,
	VK_PA1 = 0xFD,
	VK_OEM_CLEAR = 0xFE,
}

k.version = 0

k.key_names = {
	[k.VK_LBUTTON] = 'LMB',
	[k.VK_RBUTTON] = 'RMB',
	[k.VK_MBUTTON] = 'MMB',
	[k.VK_XBUTTON1] = 'XMB1',
	[k.VK_XBUTTON2] = 'XMB2',

	-- Управление
	[k.VK_CANCEL] = 'Break',
	[k.VK_BACK] = 'Bsp',
	[k.VK_TAB] = 'Tab',
	[k.VK_CLEAR] = 'Clr',
	[k.VK_RETURN] = 'Enter',
	[k.VK_SHIFT] = 'Shift',
	[k.VK_CONTROL] = 'Ctrl',
	[k.VK_MENU] = 'Alt',
	[k.VK_PAUSE] = 'Pause',
	[k.VK_CAPITAL] = 'Caps',

	-- Японская клавиатура
	[k.VK_KANA] = 'Kana',
	[k.VK_JUNJA] = 'Junja',
	[k.VK_FINAL] = 'Final',
	[k.VK_KANJI] = 'Kanji',
	[k.VK_CONVERT] = 'Conv',
	[k.VK_NONCONVERT] = 'NConv',
	[k.VK_ACCEPT] = 'Accpt',
	[k.VK_MODECHANGE] = 'Mode',

	-- Навигация
	[k.VK_ESCAPE] = 'Esc',
	[k.VK_SPACE] = 'Space',
	[k.VK_PRIOR] = 'PgUp',
	[k.VK_NEXT] = 'PgDn',
	[k.VK_END] = 'End',
	[k.VK_HOME] = 'Home',
	[k.VK_LEFT] = 'Left',
	[k.VK_UP] = 'Up',
	[k.VK_RIGHT] = 'Right',
	[k.VK_DOWN] = 'Down',
	[k.VK_SELECT] = 'Sel',
	[k.VK_PRINT] = 'Print',
	[k.VK_EXECUTE] = 'Exec',
	[k.VK_SNAPSHOT] = 'PrtScr',
	[k.VK_INSERT] = 'Ins',
	[k.VK_DELETE] = 'Del',
	[k.VK_HELP] = 'Help',

	-- Цифры
	[k.VK_0] = '0',
	[k.VK_1] = '1',
	[k.VK_2] = '2',
	[k.VK_3] = '3',
	[k.VK_4] = '4',
	[k.VK_5] = '5',
	[k.VK_6] = '6',
	[k.VK_7] = '7',
	[k.VK_8] = '8',
	[k.VK_9] = '9',

	-- Буквы
	[k.VK_A] = 'A',
	[k.VK_B] = 'B',
	[k.VK_C] = 'C',
	[k.VK_D] = 'D',
	[k.VK_E] = 'E',
	[k.VK_F] = 'F',
	[k.VK_G] = 'G',
	[k.VK_H] = 'H',
	[k.VK_I] = 'I',
	[k.VK_J] = 'J',
	[k.VK_K] = 'K',
	[k.VK_L] = 'L',
	[k.VK_M] = 'M',
	[k.VK_N] = 'N',
	[k.VK_O] = 'O',
	[k.VK_P] = 'P',
	[k.VK_Q] = 'Q',
	[k.VK_R] = 'R',
	[k.VK_S] = 'S',
	[k.VK_T] = 'T',
	[k.VK_U] = 'U',
	[k.VK_V] = 'V',
	[k.VK_W] = 'W',
	[k.VK_X] = 'X',
	[k.VK_Y] = 'Y',
	[k.VK_Z] = 'Z',

	-- Win и контекстное меню
	[k.VK_LWIN] = 'LWin',
	[k.VK_RWIN] = 'RWin',
	[k.VK_APPS] = 'Menu',

	-- Спящий режим
	[k.VK_SLEEP] = 'Sleep',

	-- NumPad
	[k.VK_NUMPAD0] = 'N0',
	[k.VK_NUMPAD1] = 'N1',
	[k.VK_NUMPAD2] = 'N2',
	[k.VK_NUMPAD3] = 'N3',
	[k.VK_NUMPAD4] = 'N4',
	[k.VK_NUMPAD5] = 'N5',
	[k.VK_NUMPAD6] = 'N6',
	[k.VK_NUMPAD7] = 'N7',
	[k.VK_NUMPAD8] = 'N8',
	[k.VK_NUMPAD9] = 'N9',
	[k.VK_MULTIPLY] = 'N*',
	[k.VK_ADD] = 'N+',
	[k.VK_SEPARATOR] = 'Sep',
	[k.VK_SUBTRACT] = 'N-',
	[k.VK_DECIMAL] = 'N.',
	[k.VK_DIVIDE] = 'N/',

	-- F-клавиши
	[k.VK_F1] = 'F1',
	[k.VK_F2] = 'F2',
	[k.VK_F3] = 'F3',
	[k.VK_F4] = 'F4',
	[k.VK_F5] = 'F5',
	[k.VK_F6] = 'F6',
	[k.VK_F7] = 'F7',
	[k.VK_F8] = 'F8',
	[k.VK_F9] = 'F9',
	[k.VK_F10] = 'F10',
	[k.VK_F11] = 'F11',
	[k.VK_F12] = 'F12',
	[k.VK_F13] = 'F13',
	[k.VK_F14] = 'F14',
	[k.VK_F15] = 'F15',
	[k.VK_F16] = 'F16',
	[k.VK_F17] = 'F17',
	[k.VK_F18] = 'F18',
	[k.VK_F19] = 'F19',
	[k.VK_F20] = 'F20',
	[k.VK_F21] = 'F21',
	[k.VK_F22] = 'F22',
	[k.VK_F23] = 'F23',
	[k.VK_F24] = 'F24',

	-- Модификаторы
	[k.VK_NUMLOCK] = 'NumLk',
	[k.VK_SCROLL] = 'ScrLk',
	[k.VK_LSHIFT] = 'LShift',
	[k.VK_RSHIFT] = 'RShift',
	[k.VK_LCONTROL] = 'LCtrl',
	[k.VK_RCONTROL] = 'RCtrl',
	[k.VK_LMENU] = 'LAlt',
	[k.VK_RMENU] = 'RAlt',

	-- Браузер
	[k.VK_BROWSER_BACK] = 'BrBack',
	[k.VK_BROWSER_FORWARD] = 'BrFwd',
	[k.VK_BROWSER_REFRESH] = 'BrRfsh',
	[k.VK_BROWSER_STOP] = 'BrStop',
	[k.VK_BROWSER_SEARCH] = 'BrSrch',
	[k.VK_BROWSER_FAVORITES] = 'BrFav',
	[k.VK_BROWSER_HOME] = 'BrHome',

	-- Медиа
	[k.VK_VOLUME_MUTE] = 'Mute',
	[k.VK_VOLUME_DOWN] = 'Vol-',
	[k.VK_VOLUME_UP] = 'Vol+',
	[k.VK_MEDIA_NEXT_TRACK] = 'Next',
	[k.VK_MEDIA_PREV_TRACK] = 'Prev',
	[k.VK_MEDIA_STOP] = 'Stop',
	[k.VK_MEDIA_PLAY_PAUSE] = 'Play/Pause',

	-- Программы
	[k.VK_LAUNCH_MAIL] = 'Mail',
	[k.VK_LAUNCH_MEDIA_SELECT] = 'Media',
	[k.VK_LAUNCH_APP1] = 'App1',
	[k.VK_LAUNCH_APP2] = 'App2',

	-- OEM
	[k.VK_OEM_1] = ';:',
	[k.VK_OEM_PLUS] = '=+',
	[k.VK_OEM_COMMA] = ',<',
	[k.VK_OEM_MINUS] = '-_',
	[k.VK_OEM_PERIOD] = '.>',
	[k.VK_OEM_2] = '/?',
	[k.VK_OEM_3] = '`~',
	[k.VK_ABNT_C1] = 'Abnt1',
	[k.VK_ABNT_C2] = 'Abnt2',
	[k.VK_OEM_4] = '[k.{',
	[k.VK_OEM_5] = '\\|',
	[k.VK_OEM_6] = ']',
	[k.VK_OEM_7] = "'", '"',
	[k.VK_OEM_8] = '!§',
	[k.VK_OEM_AX] = 'Ax',
	[k.VK_OEM_102] = '><',

	-- Специальные
	[k.VK_ICO_HELP] = 'IHelp',
	[k.VK_PROCESSKEY] = 'Proc',
	[k.VK_ICO_CLEAR] = 'IClear',
	[k.VK_PACKET] = 'Packet',

	-- OEM расширения
	[k.VK_OEM_RESET] = 'Reset',
	[k.VK_OEM_JUMP] = 'Jump',
	[k.VK_OEM_PA1] = 'PA1',
	[k.VK_OEM_PA2] = 'PA2',
	[k.VK_OEM_PA3] = 'PA3',
	[k.VK_OEM_WSCTRL] = 'WsCtrl',
	[k.VK_OEM_CUSEL] = 'CuSel',
	[k.VK_OEM_ATTN] = 'OAttn',
	[k.VK_OEM_FINISH] = 'Finish',
	[k.VK_OEM_COPY] = 'Copy',
	[k.VK_OEM_AUTO] = 'Auto',
	[k.VK_OEM_ENLW] = 'Enlw',
	[k.VK_OEM_BACKTAB] = 'BTab',

	-- Управляющие
	[k.VK_ATTN] = 'Attn',
	[k.VK_CRSEL] = 'CrSel',
	[k.VK_EXSEL] = 'ExSel',
	[k.VK_EREOF] = 'ErEof',
	[k.VK_PLAY] = 'Play',
	[k.VK_ZOOM] = 'Zoom',
	[k.VK_PA1] = 'PA1',
	[k.VK_OEM_CLEAR] = 'OClear'
}

function k.id_to_name(vkey)
	local name = k.key_names[vkey]
	if type(name) == 'table' then
		return name[1]
	end
	return name
end

function k.name_to_id(keyname)
	for id, v in pairs(k.key_names) do
		if keyname == v then
			return id
		end
	end
end

return k