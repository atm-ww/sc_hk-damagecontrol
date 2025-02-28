-- 玩家歷史記錄追蹤模塊 | Player History Tracking Module
-- 用於記錄玩家互動和傷害歷史 | For recording player interactions and damage history

-- 歷史記錄存儲 | History storage
local playerHistory = {}
local maxHistoryEntries = 100  -- 每個玩家的最大記錄數 | Maximum records per player

-- 添加歷史記錄 | Add history entry
local function addHistoryEntry(playerId, data)
    -- 初始化玩家歷史記錄 | Initialize player history
    if not playerHistory[playerId] then
        playerHistory[playerId] = {}
    end
    
    -- 添加時間戳 | Add timestamp
    data.timestamp = os.time()
    
    -- 添加新記錄 | Add new record
    table.insert(playerHistory[playerId], data)
    
    -- 限制記錄數量 | Limit record count
    if #playerHistory[playerId] > maxHistoryEntries then
        table.remove(playerHistory[playerId], 1)
    end
end

-- 記錄玩家互動歷史的函數
local function recordPlayerInteraction(playerId, interaction)
    if not playerHistory[playerId] then
        playerHistory[playerId] = {}
    end
    table.insert(playerHistory[playerId], {
        timestamp = os.time(),
        interaction = interaction
    })
    print(("記錄玩家 %s 的互動: %s"):format(tostring(playerId), tostring(interaction)))
end

-- 監聽事件：記錄互動
RegisterNetEvent("sc_hk_damagecontrol:recordInteraction")
AddEventHandler("sc_hk_damagecontrol:recordInteraction", function(data)
    -- 預期 data 包含 playerId 與 interaction（可以是文字描述或表格）
    if data and data.playerId and data.interaction then
        recordPlayerInteraction(data.playerId, data.interaction)
    else
        print("接收到無效的 recordInteraction 數據。")
    end
end)

-- 監聽事件：查詢玩家歷史記錄
RegisterNetEvent("sc_hk_damagecontrol:getHistory")
AddEventHandler("sc_hk_damagecontrol:getHistory", function(playerId)
    local src = source
    local history = playerHistory[playerId] or {}
    TriggerClientEvent("sc_hk_damagecontrol:sendHistory", src, history)
end)

-- 可選：管理命令，用於清除特定玩家的歷史記錄（僅供管理員使用）
RegisterCommand("clearHistory", function(source, args, rawCommand)
    local targetPlayerId = tonumber(args[1])
    if targetPlayerId then
        playerHistory[targetPlayerId] = {}
        TriggerClientEvent("chat:addMessage", source, { args = { "History Tracker", "已清除玩家 " .. targetPlayerId .. " 的歷史記錄。" } })
        print("清除玩家 " .. targetPlayerId .. " 的歷史記錄。")
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "History Tracker", "請提供有效的玩家 ID。" } })
    end
end, true)