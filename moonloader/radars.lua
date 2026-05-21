require "lib.moonloader"

local coordsSF = {
    { x = -1709.4557,   y = 333.2805,    z = 6.9620 },
    { x = -1719.6724,    y = 347.6189,    z = 7.0407 },
    { x = -1812.3987000, y = 91.0405000, z = 15.1094000 },
    { x = -1800.5499000, y = 90.7194000, z = 15.1094000 },
    { x = -1804.8164000, y = -252.2680000, z = 18.9446000 },
    { x = -1804.4550000, y = -252.7252000, z = 18.9894000 },
    { x = -1793.8348000, y = -254.9751000, z = 19.2096000 },
    { x = -1767.9893000, y = -603.2786000, z = 16.3867000 },
    { x = -1755.2080000, y = -609.6403000, z = 16.2749000 },
    { x = -2241.0955000, y = -380.9905000, z = 51.0156000 },
    { x = -2262.2571000, y = -375.7691000, z = 51.0096000 },
    { x = -2218.8396000, y = -75.5640000, z = 35.3203000 },
    { x = -2216.7935000, y = -64.7859000, z = 35.3203000 },
    { x = -2000.8489000, y = 144.5799000, z = 27.6875000 },
    { x = -2011.8593000, y = 151.8967000, z = 27.6875000 },
    { x = -2058.9717000, y = 325.5002000, z = 35.1641000 },
    { x = -2064.8584000, y = 315.1559000, z = 35.1641000 },
    { x = -2257.6899000, y = 115.8047000, z = 35.3203000 },
    { x = -2332.7732000, y = 452.0369000, z = 33.7570000 },
    { x = -2344.5508000, y = 449.4137000, z = 33.2184000 },
    { x = -2548.7075000, y = 573.7562000, z = 14.6151000 },
    { x = -2552.2627000, y = 557.7953000, z = 14.6142000 },
    { x = -2378.6609000, y = 845.5104000, z = 39.8004000 },
    { x = -2394.2432000, y = 849.5705000, z = 40.5339000 },
    { x = -2378.0798000, y = 1368.4709000, z = 7.2627000 },
    { x = -2371.0825000, y = 1385.1185000, z = 7.2720000 },
    { x = -1828.9307000, y = 1366.5815000, z = 7.1875000 },
    { x = -1827.2815000, y = 1370.4214000, z = 7.1875000 },
    { x = -1599.5415000, y = 1179.5519000, z = 7.1875000 },
    { x = -1566.7769000, y = 774.4635000, z = 7.1875000 },
    { x = -1534.4736000, y = 777.0010000, z = 7.1875000 },
    { x = -1906.8271000, y = 680.8387000, z = 43.0008000 },
    { x = -1891.3911000, y = 674.2974000, z = 41.8186000 },
    { x = -2394.4656000, y = -64.6188000, z = 35.3203000 },
    { x = -2402.7515000, y = -75.6773000, z = 35.3203000 },
    { x = -2591.3701000, y = -205.0604000, z = 4.3359000 },
    { x = -2593.7678000, y = -215.6290000, z = 4.3359000 },
    { x = -2803.7490000, y = -177.9144000, z = 7.1875000 },
    { x = -2814.4014000, y = -172.5967000, z = 7.1875000 },
    { x = -2803.6599000, y = 274.5341000, z = 7.1797000 },
    { x = -2814.4922000, y = 276.5752000, z = 7.1797000 },
    { x = -2818.0364000, y = 597.6443000, z = 5.6364000 },
    { x = -2828.3682000, y = 603.5565000, z = 5.9959000 },
    { x = -2841.0195000, y = 985.0764000, z = 43.4568000 },
    { x = -2852.1978000, y = 981.2009000, z = 42.8822000 },
    { x = -2601.5254000, y = 865.5616000, z = 56.9772000 },
    { x = -2612.5332000, y = 859.4520000, z = 55.3052000 },
    { x = -1996.1864000, y = 890.8438000, z = 45.4453000 },
    { x = -1755.1542000, y = 910.5090000, z = 24.8906000 },
    { x = -1749.7418000, y = 939.7637000, z = 24.8906000 }
}

local coordsLS = {
    { x = 1132.3461000, y = -1846.4156000, z = 13.5534000 },
    { x = 1455.9567000, y = -1866.6182000, z = 13.5391000 },
    { x = 1292.0820000, y = -1700.2194000, z = 13.5469000 },
    { x = 1043.2296000, y = -1678.6974000, z = 13.5469000 },
    { x = 1116.3920000, y = -1566.9351000, z = 13.5659000 },
    { x = 940.9734000, y = -1770.2719000, z = 13.8863000 },
    { x = 662.7390000, y = -1732.0753000, z = 13.7538000 },
    { x = 413.8613000, y = -1722.6289000, z = 9.0201000 },
    { x = 181.0846000, y = -1582.1029000, z = 13.5184000 },
    { x = 209.3109000, y = -1456.3380000, z = 13.0794000 },
    { x = 457.9342000, y = -1326.0377000, z = 15.3375000 },
    { x = 600.1030000, y = -1231.8510000, z = 18.1331000 },
    { x = 643.0587000, y = -1555.8546000, z = 15.4879000 },
    { x = 724.6300000, y = -1411.3286000, z = 13.5304000 },
    { x = 972.7253000, y = -1411.6089000, z = 13.3125000 },
    { x = 1362.6458000, y = -1430.0298000, z = 13.5391000 },
    { x = 1363.2571000, y = -1201.4026000, z = 18.5890000 },
    { x = 1449.1945000, y = -1268.1412000, z = 13.5469000 },
    { x = 1346.8409000, y = -924.3104000, z = 35.1100000 },
    { x = 1120.5996000, y = -940.2169000, z = 42.8857000 }
}

local coordsLV = {
    { x = 1434.3220, y = 2706.5977, z = 10.8203 },
    { x = 1994.4839, y = 2735.9944, z = 10.8203 },
    { x = 2380.3513, y = 2667.9468, z = 11.9408 },
    { x = 2840.6260, y = 2192.5808, z = 10.8203 },
    { x = 2333.3738, y = 2406.3357, z = 10.8203 },
    { x = 1338.0911, y = 2047.6628, z = 10.8203 },
    { x = 1013.6467, y = 2144.6375, z = 10.8203 },
    { x = 1081.2856, y = 1806.8075, z = 10.8203 },
    { x = 1659.5100, y = 2266.8213, z = 10.8203 },
    { x = 1840.6720, y = 2178.7815, z = 10.8230 },
    { x = 2117.3625, y = 2201.8577, z = 10.8203 },
    { x = 2335.8262, y = 2077.5239, z = 10.8203 },
    { x = 1678.5092, y = 1719.7289, z = 10.8203 },
    { x = 2036.3102, y = 1695.0011, z = 10.8203 },
    { x = 2180.3193, y = 1539.3308, z = 10.8203 },
    { x = 1888.7125, y = 1266.8763, z = 10.8203 },
    { x = 2533.9258, y = 1128.1353, z = 10.8203 },
    { x = 2264.5681, y = 1186.6605, z = 10.8203 },
    { x = 2221.1482, y = 979.3397, z = 10.8203 },
    { x = 2080.0564, y = 1114.8972, z = 10.8203 }
}

local blips = {}
local currentRadar = 0
local radars = false

function main()
    sampUnregisterChatCommand('radarssf')
    sampRegisterChatCommand('radarssf', function()
        pushRadars(coordsSF)
    end)
    
    sampUnregisterChatCommand('radarsls')
    sampRegisterChatCommand('radarsls', function()
        pushRadars(coordsLS)
    end)
    
    sampUnregisterChatCommand('radarslv')
    sampRegisterChatCommand('radarslv', function()
        pushRadars(coordsLV)
    end)
    
    while true do
        wait(0)
    end
    wait(-1)
end

function explode_color(color)
    local a = bit.band(bit.rshift(color, 24), 0xFF)
    local r = bit.band(bit.rshift(color, 16), 0xFF)
    local g = bit.band(bit.rshift(color, 8), 0xFF)
    local b = bit.band(color, 0xFF)
    return a, r, g, b
 end
 
function join_color(a, r, g, b)
    local color = b  -- b
    color = bit.bor(color, bit.lshift(g, 8))  -- g
    color = bit.bor(color, bit.lshift(r, 16)) -- r
    color = bit.bor(color, bit.lshift(a, 24)) -- a
    return color
 end
 
 function convertARGBToRGBA(color)
    local color = tonumber(color)
    local a, r, g, b = explode_color(color)
    return join_color(r, g, b, a)
end

function convertRGBAToARGB(color)
    local color = tonumber(color)
    local r, g, b, a = explode_color(color)
    return join_color(a, r, g, b)
end

function alpha255(color)
    local color = tonumber(color)
    local a, r, g, b = explode_color(color)
    return join_color(r, g, b, 255)
end

function pushRadars(coordsTable)
    if radars == false then
        radars = true
        print(radars)
        lua_thread.create(function()
            for _, coord in ipairs(coordsTable) do
                print(coord.x, coord.y, coord.z)
                local blip = addSpriteBlipForCoord(coord.x, coord.y, coord.z + 1.5, 56)
                if doesBlipExist(blip) then
                    table.insert(blips, blip)
                else
                    print('blip is not placed')
                end
            end
            wait(100)
            print('blips are placed')
        end)
    else
        radars = false
        removeBlips()
    end
end

function onScriptTerminate(s, quitGame) 
    if #blips ~= 0 then
        removeBlips()
    end
end

function removeBlips()
    for _, v in ipairs(blips) do
        removeBlip(v)
    end
    blips = {}
end