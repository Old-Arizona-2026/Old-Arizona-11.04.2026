--- Библиотека с полезными функциями для разработки скриптов
--- @module NMLibrary
--- @author NyashMyash99 (nyashmyash99.ru)
--- @license https://files.foxinbox.su/license/LICENSE

-- == Подключение зависимостей ==
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local effil = require 'effil'

local encoding = require 'encoding'
encoding.default = 'CP1251'


-- == Переменные ==
-- === Пакеты ===
--- ID внутриигровых пакетов.
local Packets = {
    --- Исполнение JS кода в интерфейсе Аризоны.
    CLIENT_EXECUTE_JAVASCRIPT = 17,
    --- Запрос на выполнение действия в интерфейсе Аризоны.
    SERVER_EXECUTE_EVENT = 18
}

local incomingPacketListeners = {}
local outgoingPacketListeners = {}

-- === Диалоги ===
--- ID диалогов Аризоны.
local Dialogues = {
    --- /mn
    MENU = 722,
    --- /stats
    MAIN_STATISTIC = 235,
    --- /donate
    DONATE = 222,
    --- /quest
    QUESTS = 25854,
    --- Подсказка / Отказаться
    QUEST = 7653,
    --- /lmenu
    LEADER_MENU = 1214,
    --- Игроки онлайн / Игроки оффлайн
    ORGANIZATION_MEMBERS_TYPE = 1009,
    --- /members
    ORGANIZATION_ONLINE_MEMBERS = 2015,
    ORGANIZATION_OFFLINE_MEMBERS = 567,
    --- /invite
    INVITE_RANK = 25636,
    --- /fmembers | Показать в виде списка / Показать на карте
    FAMILY_ONLINE_MEMBERS_TYPE = 25526,
    FAMILY_ONLINE_MEMBERS = 1488,
    FAMILY_OFFLINE_MEMBERS = 2931,
    --- /mn -> [14] Исправительные работы
    CORRECTIONAL_WORK = 0
}

local dialogListeners = {}
--- Диалоги, ожидающиеся скриптами.
local expectedDialogues = {}

-- === Команды ===
--- Типы OOC чатов, в которых работают команды.
local ChatTypes = {
    LOCAL = 1,
    FAMILY = 2,
    LEGAL_ORGANIZATION = 3,
    ILLEGAL_ORGANIZATION = 4
}

local commands = {}

-- === Прочее ===
local Colors = {
    ERROR = '{FF0000}',
    WARNING = '{FF4500}',
    SUCCESS = '{00FF00}'
}


-- == Директивы ==
local NMLibrary = {
    _VERSION = '1743281517',
    debug = {
        --- Отображать ли отладочные сообщения.
        global = false,
        PACKET = {
            --- Отображать ли пакет в виде набора байт.
            BYTES = false,
            --- Отображать ли данные входящих пакетов.
            INCOMING = false,
            --- Отображать ли данные исходящих пакетов.
            OUTGOING = false
        }
    },
    Packets = Packets,
    Dialogues = Dialogues,
    Colors = Colors,
    ChatTypes = ChatTypes
}


-- == Внутренние функции библиотеки ==
--- Отправляет дебаг сообщение в консоль, если включен режим отладки.
--- @param message string
--- @param debugMode boolean опциональный аргумент, позволяющий не зависеть от глобального состояния режима отладки (по стандарту значение из библиотеки)
local function sendDebug(message, debugMode)
    if debugMode == nil then debugMode = NMLibrary.debug.global end
    if not debugMode then return end
    print(tostring(message))
end


-- == Хелперы ==
--- @param requiredLibraryVersions table таблица { [1] = минимальная поддерживаемая версия, [2] = максимальная поддерживаемая версия }
--- @param debugMode boolean опциональный аргумент, переносящий состояние режима отладки из скрипта в библиотеку (по стандарту значение из библиотеки)
--- @return boolean была ли библиотека успешно загружена
function NMLibrary.connectLibrary(requiredLibraryVersions, debugMode)
    if debugMode then
        NMLibrary.debug.global = debugMode
        sendDebug('[connectLibrary] Режим отладки включён.')
    end

    sendDebug('[connectLibrary] Поддерживаемые скриптом версии библиотеки: ' .. tostring(encodeJson(requiredLibraryVersions)) .. '.')
    local minRequiredVersion = requiredLibraryVersions[1]
    local maxRequiredVersion = requiredLibraryVersions[2]

    if tonumber(minRequiredVersion) > tonumber(NMLibrary._VERSION) then
        sendDebug('[connectLibrary]) Версия библиотеки не поддерживается: ' .. tostring(NMLibrary._VERSION) .. ' (установлена), ' .. tostring(minRequiredVersion) .. ' (мин. необходимая).')
        sendMessage(Colors.ERROR .. 'Скрипт требует более новой версии NMLibrary, проверь ресурс с обновлениями (BlastHack, Discord).')
        return false
    end

    if tonumber(maxRequiredVersion) < tonumber(NMLibrary._VERSION) then
        sendDebug('[connectLibrary] Версия библиотеки не поддерживается: ' .. tostring(NMLibrary._VERSION) .. ' (установлена), ' .. tostring(maxRequiredVersion) .. ' (макс. необходимая).')
        sendMessage(Colors.ERROR .. 'Скрипт требует более старой версии NMLibrary, обнови скрипт или свяжись с разработчиком, если не нашёл обновлений.')
        return false
    end

    return true
end


-- == Диалоги ==
--- Обрабатывает диалоги, если их ожидал какой-то скрипт.
function sampev.onShowDialog(id, _, title, _, _, text)
    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Диалог пытается отобразиться.')

    if not expectedDialogues[id] then
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Обработка не требуется.')
        return true
    end

    NMLibrary.releaseDialog(id)


    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Получаю слушателей диалога.')
    local listeners = dialogListeners[id]

    if not listeners then
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Слушателей не найдено.')
        return true
    end
    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Получено ' .. tostring(#listeners) .. ' слушателей.')


    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Подготавливаю заголовок диалога.')
    title = NMLibrary.trim(NMLibrary.stripColors(title))
    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Заголовок диалога подготовлен: ' .. tostring(title) .. '.')

    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Разделяю контент диалога по строчкам.')
    text = NMLibrary.split(text, '\n')
    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Контент диалога разделён: ' .. tostring(encodeJson(text)) .. '.')

    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Подготавливаю контент диалога.')
    for i, line in ipairs(text) do
        text[i] = NMLibrary.trim(NMLibrary.stripColors(line))
    end
    sendDebug('[onShowDialog] (' .. tostring(id) .. ') Контент диалога подготовлен: ' .. tostring(encodeJson(text)) .. '.')


    local isNeedToBeClosed = true
    local isNeedToBeDisplayed = false
    for i, listener in ipairs(listeners) do
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Обрабатываю ' .. tostring(i) .. ' слушатель.')
        local listenerClosingResponse, listenerDisplayResponse = listener(text, title, id)
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Слушатель #' .. tostring(i) .. ' обработан: ' .. tostring(listenerClosingResponse) .. ', ' .. tostring(listenerDisplayResponse) .. '.')

        -- Переносим отметку, что диалог не должен быть закрыт.
        if listenerClosingResponse == false then
            isNeedToBeClosed = false
        end

        -- Переносим отметку, что диалог должен быть отображен.
        if listenerDisplayResponse == true then
            isNeedToBeDisplayed = true
        end
    end

    -- Закрываем диалог, если это необходимо.
    if isNeedToBeClosed then
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Отправляю нажатие на кнопку закрытия диалога.')
        sampSendDialogResponse(id, 0, 0, nil)
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Нажатие на кнопку закрытия диалога отправлено.')
    else
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Диалог не нуждается в закрытии.')
    end

    if isNeedToBeDisplayed then
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Отмена отображения диалога не требуется.')
    else
        sendDebug('[onShowDialog] (' .. tostring(id) .. ') Отменяю отображение диалога.')
    end

    return isNeedToBeDisplayed
end

--- @param id number
--- @param listener function принимает текст диалога (string[]) и его заголовок (string), опционально возвращая должен ли диалог быть закрыт и должен ли диалог быть отображён (boolean, boolean) (по стандарту true, false)
function NMLibrary.subscribeToDialog(id, listener)
    if not dialogListeners[id] then
        sendDebug('[subscribeToDialog] (' .. tostring(id) .. ') Создаю пустой список слушателей.')
        dialogListeners[id] = {}
        sendDebug('[subscribeToDialog] (' .. tostring(id) .. ') Пустой список слушателей создан.')
    end

    sendDebug('[subscribeToDialog] (' .. tostring(id) .. ') Добавляю новый слушатель.')
    table.insert(dialogListeners[id], listener)
    sendDebug('[subscribeToDialog] (' .. tostring(id) .. ') Новый слушатель добавлен.')
end

--- Начинает ожидание диалога, при следующем появлении он будет обработан и не показан игроку (по стандарту).
--- @param id number
function NMLibrary.expectDialog(id)
    sendDebug('[expectDialog] Отмечаю диалог "' .. tostring(id) .. '" как ожидаемый.')
    expectedDialogues[id] = true
    sendDebug('[expectDialog] Ожидаю диалог "' .. tostring(id) .. '": ' .. tostring(NMLibrary.tableSize(expectedDialogues)) .. ' диалогов ожидается.')
end

--- Прекращает ожидание диалога.
--- @param id number
function NMLibrary.releaseDialog(id)
    sendDebug('[releaseDialog] Прекращаю ожидание диалога "' .. tostring(id) .. '".')
    expectedDialogues[id] = nil
    sendDebug('[releaseDialog] Ожидание диалога "' .. tostring(id) .. '" завершено: ' .. tostring(NMLibrary.tableSize(expectedDialogues)) .. ' диалогов ожидается.')
end


-- == Команды ==
--- Регистрирует чат-команду.
--- @param syntax string regex команды с группами, которые будут переданы в обработчик в качестве аргументов
--- @param chatType number тип чата, в котором работает команда (см. ChatTypes)
--- @param handler function принимает группы из commandRegex (...string), опционально возвращая успешность выполнения команды (boolean) (по стандарту true)
--- @param cooldown number опциональный аргумент, указывающий задержку между использованием команды (по стандарту -1)
--- @param notifyErrors boolean опциональный аргумент, указывающий необходимость информирования исполнителя об ошибке (например из-за кулдауна) (по стандарту false)
function NMLibrary.registerCommand(
    syntax,
    chatType,
    handler,
    cooldown,
    notifyErrors
)
    local command = {
        syntax = syntax,
        chatType = chatType,
        cooldown = cooldown or -1,
        notifyErrors = notifyErrors or false
    }

    sendDebug('[registerCommand] Добавляю новую команду: ' .. encodeJson(command) .. '.')

    command.handler = handler
    table.insert(commands, command)

    sendDebug('[registerCommand] Новая команда добавлена: зарегистрировано ' .. tostring(#commands) .. ' шт.')
end

function NMLibrary.processCommand(text)
    for _, command in ipairs(commands) do
        local sender, senderId, senderRank, message, answerCommand

        if command.chatType == ChatTypes.LOCAL then
            local player, playerId, localMessage = text:match('%(%( (.-)%[(%d+)]: (.+) %)%)')
            if not player or not playerId or not localMessage then
                goto nextCommand
            end

            sender = player
            senderId = playerId
            message = localMessage
            answerCommand = '/b'
        end

        if command.chatType == ChatTypes.LEGAL_ORGANIZATION then
            local playerRank, player, playerId, organizationMessage = text:match('%[R] (.+) (.-)%[(%d+)]: %(%( (.+) %)%)')
            if not player or not playerRank or not playerId or not organizationMessage then
                goto nextCommand
            end

            sender = player
            senderId = playerId
            senderRank = playerRank
            message = organizationMessage
            answerCommand = '/rb'
        end

        if command.chatType == ChatTypes.ILLEGAL_ORGANIZATION then
            local playerRank, player, playerId, organizationMessage = text:match('%[F] (.+) (.-)%[(%d+)]: %(%( (.+) %)%)')
            if not player or not playerRank or not playerId or not organizationMessage then
                goto nextCommand
            end

            sender = player
            senderId = playerId
            senderRank = playerRank
            message = organizationMessage
            answerCommand = '/fb'
        end

        -- Пытаемся вытащить из сообщения аргументы команды.
        local arguments = table.pack(message:match(command.syntax))
        if #arguments == 0 then
            goto nextCommand
        end

        if command.cooldownUntil ~= nil and command.cooldownUntil > os.time() then
            if not command.notifyErrors then
                goto nextCommand
            end

            sampSendChat(tostring(answerCommand) .. ' Повторно использовать команду можно будет примерно через ' .. tostring(math.ceil((command.cooldownUntil - os.time()) / 60)) .. ' мин.')
            goto nextCommand
        end

        local isSuccess = command.handler(sender, senderId, senderRank, table.unpack(arguments))
        -- Если было возвращено любое значение, кроме false - команда выполнилась успешно, значит добавляем задержку, если это необходимо.
        if isSuccess ~= false and command.cooldown ~= -1 then
            command.cooldownUntil = os.time() + command.cooldown
        end

        ::nextCommand::
    end
end

--- Отслеживает команды чата.
function sampev.onServerMessage(_, text)
    text = NMLibrary.stripColors(text)
    NMLibrary.processCommand(text)
    return true
end


-- == CEF ==
--- Имитирует получение запроса на выполнение JavaScript кода в интерфейсе Аризоны.
--- @param code string
function NMLibrary.executeJavaScript(code)
    sendDebug('[executeJavaScript] Отправляю JavaScript код: ' .. tostring(code) .. '.')

    local stream = raknetNewBitStream()

    -- Заполняем ID пакета.
    raknetBitStreamWriteInt8(stream, Packets.CLIENT_EXECUTE_JAVASCRIPT)
    -- Заполняем какое-то непонятное число.
    raknetBitStreamWriteInt32(stream, 0)
    -- Заполняем длину отправляемого кода.
    raknetBitStreamWriteInt16(stream, #code)
    -- Заполняем флаг кодировки.
    raknetBitStreamWriteInt8(stream, 0)
    -- Заполняем код.
    raknetBitStreamWriteString(stream, code)

    -- Имитируем получение CEF пакета.
    raknetEmulPacketReceiveBitStream(220, stream)

    -- Подчищает стрим.
    raknetDeleteBitStream(stream)

    sendDebug('[executeJavaScript] JavaScript код отправлен.')
end

--- Имитирует получение запроса на выполнение события в интерфейсе Аризоны.
--- @param event string
--- @param arguments string
function NMLibrary.executeClientEvent(event, arguments)
    NMLibrary.executeJavaScript(('window.executeEvent(\'%s\', \'[%s]\');'):format(event, arguments))
end

--- Отправляет запрос на выполнение действия в интерфейсе Аризоны.
--- @param event string
--- @param arguments string
function NMLibrary.executeServerEvent(event, arguments)
    local action = tostring(event) .. '|' .. tostring(arguments)
    sendDebug('[executeServerEvent] Отправляю действие: ' .. tostring(action) .. '.')

    local stream = raknetNewBitStream()

    -- Заполняем системный ID пакета.
    raknetBitStreamWriteInt8(stream, 220)
    -- Заполняем ID пакета.
    raknetBitStreamWriteInt8(stream, 18)
    -- Заполняем длину выполняемого действия.
    raknetBitStreamWriteInt16(stream, #action)
    -- Заполняем действие.
    raknetBitStreamWriteString(stream, action)
    -- Заполняем какое-то непонятное число.
    raknetBitStreamWriteInt32(stream, 0)

    -- Отправляет пакет на сервер.
    raknetSendBitStream(stream);

    -- Подчищает стрим.
    raknetDeleteBitStream(stream);

    sendDebug('[executeServerEvent] Действие отправлено: ' .. tostring(action) .. '.')
end

--- Подписывается на входящий CEF пакет.
--- @param packetID number
--- @param listener function
function NMLibrary.subscribeToIncomingPacket(packetID, listener)
    if not incomingPacketListeners[packetID] then
        sendDebug('[subscribeToIncomingPacket] (' .. tostring(packetID) .. ') Создаю пустой список слушателей.')
        incomingPacketListeners[packetID] = {}
        sendDebug('[subscribeToIncomingPacket] (' .. tostring(packetID) .. ') Пустой список слушателей создан.')
    end

    sendDebug('[subscribeToIncomingPacket] (' .. tostring(packetID) .. ') Добавляю новый слушатель.')
    table.insert(incomingPacketListeners[packetID], listener)
    sendDebug('[subscribeToIncomingPacket] (' .. tostring(packetID) .. ') Новый слушатель добавлен.')
end

--- Подписывается на исходящий CEF пакет.
--- @param packetID number
--- @param listener function
function NMLibrary.subscribeToOutgoingPacket(packetID, listener)
    if not outgoingPacketListeners[packetID] then
        sendDebug('[subscribeToOutgoingPacket] (' .. tostring(packetID) .. ') Создаю пустой список слушателей.')
        outgoingPacketListeners[packetID] = {}
        sendDebug('[subscribeToOutgoingPacket] (' .. tostring(packetID) .. ') Пустой список слушателей создан.')
    end

    sendDebug('[subscribeToOutgoingPacket] (' .. tostring(packetID) .. ') Добавляю новый слушатель.')
    table.insert(outgoingPacketListeners[packetID], listener)
    sendDebug('[subscribeToOutgoingPacket] (' .. tostring(packetID) .. ') Новый слушатель добавлен.')
end

--- Преобразовывает CEF пакет в удобный для использования формат.
--- @param packetID number
--- @param stream table
--- @param type string incoming/outgoing
function NMLibrary.processPacket(packetID, stream, type)
    if packetID == Packets.CLIENT_EXECUTE_JAVASCRIPT then
        -- Пропускаем первые 4 непонятных байта.
        raknetBitStreamIgnoreBits(stream, 32)

        -- Читаем длину полученного кода.
        local codeLength = raknetBitStreamReadInt16(stream)
        if codeLength == 0 then return nil end

        -- Получаем флаг кодировки.
        local isEncoded = raknetBitStreamReadInt8(stream)
        if isEncoded == 1 then
            codeLength = codeLength + 1
        end

        -- Читаем код.
        local code = raknetBitStreamReadString(stream, codeLength)

        -- Получаем из кода необходимую информацию.
        local event, arguments = code:match("window%.executeEvent%('(.+)', ['`]%[(.+)]['`]%)")

        sendDebug('[processPacket] Обработан пакет ' .. tostring(NMLibrary.findKey(Packets, packetID)) .. ' (' .. tostring(event) .. '): ' .. tostring(arguments) .. '.', NMLibrary.debug.PACKET[type])
        return event, arguments
    end

    if packetID == Packets.SERVER_EXECUTE_EVENT then
        -- Читаем длину отправляемого действия.
        local actionLength = raknetBitStreamReadInt32(stream)
        if actionLength == 0 then return nil end

        -- Читаем действие.
        local action = raknetBitStreamReadString(stream, actionLength)

        -- Получаем из действия необходимую информацию.
        local event, arguments = action:match("(.-)|(.*)")

        sendDebug('[processPacket] Обработан пакет ' .. tostring(NMLibrary.findKey(Packets, packetID)) .. ' (' .. tostring(event) .. '): ' .. tostring(arguments) .. '.', NMLibrary.debug.PACKET[type])
        return event, arguments
    end

    return nil
end

--- Слушает CEF пакеты.
addEventHandler('onReceivePacket', function(id, stream)
    if id ~= 220 then return end

    local bytes = {}
    -- Читаем байты для их последующего вывода.
    for _ = 1, raknetBitStreamGetNumberOfBytesUsed(stream) do
        table.insert(bytes, raknetBitStreamReadInt8(stream))
    end
    sendDebug('[onReceivePacket] Получен пакет: ' .. table.concat(bytes, ', ') .. '.', NMLibrary.debug.PACKET.INCOMING and NMLibrary.debug.PACKET.BYTES)

    -- Сбрасываем указатель чтения.
    raknetBitStreamResetReadPointer(stream)
    -- Пропускаем системный ID пакета.
    raknetBitStreamIgnoreBits(stream, 8)

    local packetID = raknetBitStreamReadInt8(stream)
    local listeners = incomingPacketListeners[packetID]
    if not listeners then return end

    -- Преобразуем пакет в удобную для использования форму.
    local packetData = table.pack(NMLibrary.processPacket(packetID, stream, 'incoming'))

    for _, listener in ipairs(listeners) do
        listener(table.unpack(packetData))
    end
end)

addEventHandler('onSendPacket', function(id, stream)
    if id ~= 220 then return end

    local bytes = {}
    -- Читаем байты для их последующего вывода.
    for _ = 1, raknetBitStreamGetNumberOfBytesUsed(stream) do
        table.insert(bytes, raknetBitStreamReadInt8(stream))
    end
    sendDebug('[onSendPacket] Отправлен пакет: ' .. tostring(table.concat(bytes, ', ')) .. '.', NMLibrary.debug.PACKET.OUTGOING and NMLibrary.debug.PACKET.BYTES)

    -- Сбрасываем указатель чтения.
    raknetBitStreamResetReadPointer(stream)
    -- Пропускаем системный ID пакета.
    raknetBitStreamIgnoreBits(stream, 8)

    local packetID = raknetBitStreamReadInt8(stream)
    local listeners = outgoingPacketListeners[packetID]
    if not listeners then return end

    -- Преобразуем пакет в удобную для использования форму.
    local packetData = table.pack(NMLibrary.processPacket(packetID, stream, 'outgoing'))

    for _, listener in ipairs(listeners) do
        listener(table.unpack(packetData))
    end
end)


-- == Запросы ==
--- @param scriptVersion number
--- @param scriptInformationUrl string
--- @param callback function принимает таблицу { isSuccess: boolean, isUpdateFound?: boolean, serverScriptVersion?: number, error?: string }
function NMLibrary.checkUpdates(scriptVersion, scriptInformationUrl, callback)
    sendDebug('[checkUpdates] Отправляю запрос на получение информации об обновлениях: ' .. tostring(scriptInformationUrl) .. '.')
    NMLibrary.getRequest(scriptInformationUrl, function (statusCode, data, error)
        sendDebug('[checkUpdates] Получен ответ на запрос: ' .. tostring(scriptInformationUrl) .. '.')

        if error then
            sendDebug('[checkUpdates] Что-то пошло не так при получении информации об обновлениях: ' .. tostring(error) .. ' (' .. tostring(scriptInformationUrl) .. ').')
            return callback({
                isSuccess = false,
                error = 'Что-то пошло не так при получении информации об обновлениях.'
            })
        end

        if statusCode ~= 200 then
            sendDebug('[checkUpdates] Что-то пошло не так при получении информации об обновлениях: ' .. tostring(statusCode) .. ' код ответа (' .. tostring(scriptInformationUrl) .. ').')
            return callback({
                isSuccess = false,
                error = 'Что-то пошло не так при получении информации об обновлениях.'
            })
        end

        sendDebug('[checkUpdates] Полученная информация: ' .. tostring(encodeJson(data)) .. ' (' .. tostring(scriptInformationUrl) .. ').')
        local serverScriptVersion = data['version']

        -- Если версия скрипта актуальная - пропускаем дальнейшую обработку.
        if tonumber(serverScriptVersion) <= tonumber(scriptVersion) then
            sendDebug('[checkUpdates] Версия скрипта актуальна: ' .. tostring(serverScriptVersion) .. ' (на сервере), ' ..  tostring(scriptVersion) .. ' (установлена) (' .. tostring(scriptInformationUrl) .. ').')
            return callback({
                isSuccess = true,
                isUpdateFound = false
            })
        end

        sendDebug('[checkUpdates] Найдена новая версия скрипта: ' .. tostring(serverScriptVersion) .. ' (' .. tostring(scriptInformationUrl) .. ').')
        callback({
            isSuccess = true,
            isUpdateFound = false,
            serverScriptVersion = tonumber(serverScriptVersion)
        })
    end)
end

--- @param url string
--- @param callback function принимает код ответа (number/nil), данные ответа (any/nil), ошибку (string/nil)
function NMLibrary.getRequest(url, callback)
    NMLibrary.request('GET', url, nil, nil, callback)
end

--- @param url string
--- @param data table
--- @param callback function принимает код ответа (number/nil), данные ответа (any/nil), ошибку (string/nil)
function NMLibrary.postRequest(url, data, headers, callback)
    NMLibrary.request('POST', url, data, headers, callback)
end

--- @param method string
--- @param url string
--- @param data table данные для не GET запросов
--- @param headers table дополнительные заголовки для не GET запросов
--- @param callback function принимает код ответа (number/nil), данные ответа (any/nil), ошибку (string/nil)
function NMLibrary.request(method, url, data, headers, callback)
    -- Формируем дополнительные поля запроса, если это необходимо.
    local requestArguments = { headers = headers }

    if method ~= 'GET' then
        requestArguments.headers['Content-Type'] = 'application/json'
        requestArguments.data = encodeJson(data)
    end

    local thread = effil.thread(
        function (method, url, requestArguments)
            -- Загружаем библиотеку, так как здесь невозможно работать с глобальными переменными.
            local requests = require 'requests'

            -- Вызываем функцию, отлавливая ошибки.
            local success, response = pcall(requests.request, method, url, requestArguments)

            -- Возвращаем ответа как результат выполнения потока.
            if success then
                -- Подчищаем функции, которые вызывают ошибки.
                response.json, response.xml = nil, nil
                return true, response
            else
                return false, response
            end
        end
    )(method, url, requestArguments)

    -- Создаём MoonLoader поток чтобы проверять поток с запросом,
    -- ибо мы не можем вызвать оттуда callback.
    lua_thread.create(function()
        while true do
            local status, exception = thread:status()

            -- Если что-то произошло с потоком - отправляет ошибку.
            if exception then
                return callback(nil, nil, exception)
            end

            -- Если поток завершил работу - обрабатываем ответ.
            if status == 'completed' or status == 'canceled' then
                local success, response = thread:get()

                if success then
                    return callback(response.status_code, decodeJson(response.text) or response.text, nil)
                else
                    return callback(nil, nil, response)
                end
            end

            wait(10)
        end
    end)
end


-- == Конфигурация ==
--- @param configDirPath string
--- @param configFilePath string
--- @param defaultConfig table
--- @return table таблицу { isSuccess: boolean, error?: string, config?: table }
function NMLibrary.reloadConfiguration(configDirPath, configFilePath, defaultConfig)
    NMLibrary.createConfigDirectory(configDirPath)

    sendDebug('[reloadConfiguration] Загружаю конфигурацию: ' .. tostring(configFilePath) .. '.')
    local config = inicfg.load(defaultConfig, configFilePath)
    sendDebug('[reloadConfiguration] Данные из файла конфигурации: ' .. tostring(encodeJson(config)) .. ' (' .. tostring(configFilePath) .. ').')

    if config == nil then
        sendDebug('[reloadConfiguration] Что-то пошло не так при загрузке конфигурации: ' .. tostring(configFilePath) .. '.')
        return {
            isSuccess = false,
            error = 'Что-то пошло не так при загрузке конфигурации.'
        }
    end

    local saveConfigurationResult = NMLibrary.saveConfiguration(configDirPath, configFilePath, config)
    if not saveConfigurationResult or not saveConfigurationResult.isSuccess then
        return {
            isSuccess = false,
            error = (saveConfigurationResult or { error = 'Что-то пошло не так при сохранении конфигурации.' }).error
        }
    end

    sendDebug('[reloadConfiguration] Конфигурация загружена: ' .. tostring(encodeJson(config)) .. ' (' .. tostring(configFilePath) .. ').')
    return {
        isSuccess = true,
        config = config
    }
end

--- @param configFilePath string
--- @param configFilePath string
--- @param config table
--- @return table таблицу { isSuccess: boolean, error?: string }
function NMLibrary.saveConfiguration(configDirPath, configFilePath, config)
    NMLibrary.createConfigDirectory(configDirPath)

    sendDebug('[saveConfiguration] Сохраняю конфигурацию: ' .. tostring(configFilePath) .. ' (' .. tostring(encodeJson(config)) .. ').')
    if not doesFileExist(configFilePath) then
        sendDebug('[saveConfiguration] Создаю пустой файл: ' .. tostring(configFilePath) .. '.')
        local file = io.open(configFilePath, 'w')

        if not file then
            sendDebug('[saveConfiguration] Что-то пошло не так при создании пустого файла: ' .. tostring(configFilePath) .. '.')
            return {
                isSuccess = false,
                error = 'Что-то пошло нет ак при создании пустого файла для конфигурации.'
            }
        end

        sendDebug('[saveConfiguration] Инициализирую пустой файл: ' .. tostring(configFilePath) .. '.')
        file:write('')

        sendDebug('[saveConfiguration] Закрываю пустой файл: ' .. tostring(configFilePath) .. '.')
        file:close()

        sendDebug('[saveConfiguration] Пустой файл создан: ' .. tostring(configFilePath) .. '.')
    end

    if not inicfg.save(config, configFilePath) then
        sendDebug('[saveConfiguration] Что-то пошло не так при сохранении конфигурации: ' .. tostring(configFilePath) .. ' (' .. tostring(encodeJson(config)) .. ').')
        return {
            isSuccess = false,
            error = 'Что-то пошло не так при сохранении конфигурации.'
        }
    end

    sendDebug('[saveConfiguration] Конфигурация сохранена: ' .. tostring(configFilePath) .. ' (' .. tostring(encodeJson(config)) .. ').')
    return { isSuccess = true }
end

--- @param configDirPath string
function NMLibrary.createConfigDirectory(configDirPath)
    sendDebug('[createConfigDirectory] Создаю папку: ' .. tostring(configDirPath) .. '.')
    createDirectory(configDirPath)
    sendDebug('[createConfigDirectory] Папка создана: ' .. tostring(configDirPath) .. '.')
end


-- == SAMP ==
--- @author https://www.blast.hk/members/140618/
--- @param maxDistance number
--- @return any,number car, id
function NMLibrary.getClosestCar(maxDistance)
    local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)

    local minDistance = 9999
    local carId = -1
    local carHandle

    for _, car in ipairs(getAllVehicles()) do
        local success, id = sampGetVehicleIdByCarHandle(car)
        if not success then goto nextCar end

        local carX, carY, carZ = getCarCoordinates(car)
        local distance = math.sqrt((carX - playerX) ^ 2 + (carY - playerY) ^ 2 + (carZ - playerZ) ^ 2)

        if distance < minDistance then
            minDistance = distance
            carId = id
            carHandle = car
        end

        ::nextCar::
    end

    if minDistance > maxDistance then
        return nil, -1
    end

    return carHandle, carId
end

--- Удаляет SAMP цвета из текста.
--- @param text string
function NMLibrary.stripColors(text)
    return select(1, text:gsub('{%x+}', ''))
end

function NMLibrary.getPlayerID()
    local _, playerID = sampGetPlayerIdByCharHandle(PLAYER_PED)
    return playerID
end

function NMLibrary.getPlayerUsername()
    return sampGetPlayerNickname(NMLibrary.getPlayerID())
end

--- Получает ID персонажа, на которого целится игрок.
--- @return number ID или -1
function NMLibrary.getTargetID()
    local success, targetPed = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if not success then return -1 end

    local _, targetID = sampGetPlayerIdByCharHandle(targetPed)
    return targetID
end


-- == Строки ==
--- Получает длину строки, в том числе с русскими символами.
--- @param text string
--- @author chapo <https://www.blast.hk/members/112329>
function NMLibrary.len(text)
    return text:gsub('[\128-\191]', ''):len()
end

--- Проверяет, начинается ли строка с определённой подстроки.
--- @param text string
--- @param prefix string
function NMLibrary.startsWith(text, prefix)
    text = string.sub(text, 1, #prefix)
    return text == prefix
end

--- Разбивает строку по разделителю.
--- @param text string
--- @param delimiter string
function NMLibrary.split(text, delimiter)
    local result = {}

    for match in (text .. delimiter):gmatch('(.-)' .. delimiter) do
        table.insert(result, match)
    end

    return result
end

--- Удаляет пробелы в начале и в конце текста.
--- @param text string
function NMLibrary.trim(text)
    return select(1, text:gsub('^%s*(.-)%s*$', '%1'))
end

--- Сокращает строку, обрезая её и добавляя "..", если она слишком длинная.
--- @param text string
--- @param maxLength number
function NMLibrary.overlap(text, maxLength)
    if #text <= maxLength then
        return text
    end

    -- Получаем первые {maxLength} символов и добавляем "..".
    return text:sub(1, maxLength) .. '..'
end

--- Преобразует число в читаемый денежный формат.
--- @param amount number
function NMLibrary.toMoneyFormat(amount)
    return NMLibrary.trim(
        tostring(amount)
            :reverse()
            :gsub('%d%d%d', '%1 ')
            :reverse()
    )
end


-- == Таблицы ==
--- @param tab table
--- @return table,table таблицы { [index] = key } и { [key] = true }
function NMLibrary.tableKeys(tab)
    local keys = {}
    local key2Bool = {}

    if not tab then
        return keys, key2Bool
    end

    for key, _ in pairs(tab) do
        table.insert(keys, key)
        key2Bool[key] = true
    end

    return keys, key2Bool
end

--- @param tab table
--- @return table таблицу { [index] = value }
function NMLibrary.tableValues(tab)
    local values = {}

    for _, value in pairs(tab) do
        tab.insert(values, value)
    end

    return values
end

--- Ищёт ключ в таблице по значению.
--- @param tab table
--- @return any ключ или nil
function NMLibrary.findKey(tab, targetValue)
    for key, value in pairs(tab) do
        if value == targetValue then
            return key
        end
    end

    return nil
end

--- Ищет индекс значения в таблице.
--- @param tab table
--- @return number индекс или nil
function NMLibrary.findIndex(tab, targetValue)
    for i, value in ipairs(tab) do
        if value == targetValue then
            return i
        end
    end

    return nil
end

--- Получает количество записей в таблице.
--- @param tab table
function NMLibrary.tableSize(tab)
    local size = 0

    for _ in pairs(tab) do size = size + 1 end

    return size
end


-- == Дополнение стандартного языка ==
--- @param dangerousCode function
--- @param exceptionHandler function
function NMLibrary.try(dangerousCode, exceptionHandler)
    local success, exception = pcall(dangerousCode)
    if success then return end

    exceptionHandler(exception)
end

--- Позволяет писать на русском в интерфейсах.
NMLibrary.ru = encoding.UTF8


return NMLibrary