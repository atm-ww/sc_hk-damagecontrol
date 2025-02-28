-- Discord Webhooks 模塊：用於將玩家傷害報告發送到 Discord
-- Discord Webhooks Module: For sending player damage reports to Discord

local webhookURL = GetConvar('discord_webhook', 'YOUR_WEBHOOK_URL')

-- 添加調試函數 | Add debug function
local function debugPrint(message)
    print("[DamageControl Debug] " .. tostring(message))
end

-- 改進的數字格式化函數 | Improved number formatting function
local function formatNumber(number)
    if type(number) ~= "number" then
        return "0"
    end
    -- 如果是小數，保留一位小數 | If decimal, keep one decimal place
    if math.floor(number) ~= number then
        return string.format("%.1f", number)
    end
    -- 如果是整數，直接轉換 | If integer, convert directly
    return tostring(math.floor(number))
end

-- 簡化的發送 Discord 消息函數
function sendDiscordMessage(data)
    if not webhookURL then
        debugPrint("錯誤：未設置 Discord Webhook URL")
        return
    end

    if not data then
        debugPrint("錯誤：未提供數據")
        return
    end

    -- 清理和格式化數據
    local position = data.position or {x = 0, y = 0, z = 0}
    local damage = tonumber(data.damage) or 0
    local health = tonumber(data.currentHealth) or 0

    -- 創建簡單的消息內容
    local content = string.format(
        "🎯 玩家傷害報告\n" ..
        "玩家: %s (ID: %s)\n" ..
        "傷害: %s | 生命值: %s\n" ..
        "位置: X:%s Y:%s Z:%s",
        tostring(data.playerName),
        tostring(data.playerId),
        formatNumber(damage),
        formatNumber(health),
        formatNumber(position.x),
        formatNumber(position.y),
        formatNumber(position.z)
    )

    -- 構建簡單的 payload
    local payload = {
        content = content,
        username = "Damage Control Bot",
        avatar_url = "https://i.imgur.com/4M34hi2.png"
    }

    -- 轉換為 JSON
    local jsonPayload = json.encode(payload)
    debugPrint("準備發送的消息內容: " .. content)

    -- 發送請求
    PerformHttpRequest(webhookURL, function(err, text, headers)
        if err == 200 or err == 204 then  -- Discord 有時會返回 204
            debugPrint("Discord 消息發送成功!")
        else
            debugPrint("Discord 發送失敗. 錯誤代碼: " .. tostring(err))
            if text then
                debugPrint("錯誤詳情: " .. tostring(text))
            end
        end
    end, 'POST', jsonPayload, {['Content-Type'] = 'application/json'})
end

-- 改進的測試命令
RegisterCommand('testdamage', function(source, args, rawCommand)
    local player = source
    debugPrint("測試命令被觸發，來源: " .. tostring(player))
    
    if player > 0 then
        local testData = {
            playerId = player,
            playerName = GetPlayerName(player),
            damage = 50.0,
            damageColor = "yellow",
            currentHealth = 100,
            position = {x = 0, y = 0, z = 0}
        }
        
        debugPrint("正在使用測試數據發送 Discord 消息...")
        sendDiscordMessage(testData)
    else
        debugPrint("命令必須由玩家觸發")
    end
end, false)

-- 監聽玩家受傷事件
RegisterNetEvent("sc_hk_damagecontrol:playerDamaged")
AddEventHandler("sc_hk_damagecontrol:playerDamaged", function(data)
    debugPrint("收到玩家受傷事件")
    sendDiscordMessage(data)
end)

-- 在資源啟動時進行測試
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    debugPrint('Discord Webhook 模組已啟動')
    
    -- 發送簡單的啟動測試消息
    local payload = {
        content = "🟢 傷害控制系統已啟動 - " .. os.date("%Y-%m-%d %H:%M:%S"),
        username = "Damage Control Bot"
    }
    
    PerformHttpRequest(webhookURL, function(err, text, headers)
        if err == 200 or err == 204 then
            debugPrint("啟動測試消息發送成功")
        else
            debugPrint("啟動測試消息發送失敗: " .. tostring(err))
        end
    end, 'POST', json.encode(payload), {['Content-Type'] = 'application/json'})
end)

-- 改進的死亡消息處理函數
RegisterNetEvent("sc_hk_damagecontrol:playerDeath")
AddEventHandler("sc_hk_damagecontrol:playerDeath", function(data)
    local playerId = source
    local playerName = GetPlayerName(playerId)
    
    -- 構建死亡消息
    local content = string.format(
        "💀 玩家死亡報告\n" ..
        "玩家: %s (ID: %s)\n" ..
        "位置: X:%.2f Y:%.2f Z:%.2f\n" ..
        "時間: %s",
        playerName,
        tostring(playerId),
        data.position.x,
        data.position.y,
        data.position.z,
        os.date("%Y-%m-%d %H:%M:%S")
    )

    -- 構建 payload
    local payload = {
        content = content,
        username = "Damage Control Bot",
        avatar_url = "https://i.imgur.com/4M34hi2.png"
    }

    -- 如果有截圖URL，添加到 embed
    if data.screenshotUrl then
        payload.embeds = {
            {
                title = "死亡現場截圖",
                image = {
                    url = data.screenshotUrl
                },
                color = 15158332  -- 紅色
            }
        }
    end

    -- 發送到 Discord
    PerformHttpRequest(webhookURL, function(err, text, headers)
        if err == 200 or err == 204 then
            debugPrint("死亡消息發送成功!")
        else
            debugPrint("死亡消息發送失敗. 錯誤代碼: " .. tostring(err))
            if text then
                debugPrint("錯誤詳情: " .. tostring(text))
            end
        end
    end, 'POST', json.encode(payload), {['Content-Type'] = 'application/json'})
end)