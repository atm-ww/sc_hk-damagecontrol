-- 插件基本信息 | Plugin Basic Information
fx_version 'cerulean'
game 'gta5'

author 'ℝ𝔸𝔽𝔸𝔼𝕃𝕄𝔸𝕋ℍ𝔼𝕆𝕌'
description '基礎傷害控制與監控系統 | Basic Damage Control and Monitoring System'
version '1.0.0'

lua54 'yes'  -- 使用 Lua 5.4 | Use Lua 5.4

-- 共享腳本 | Shared Scripts
shared_scripts {
    'config/weapons.lua',      -- 武器配置 | Weapon configuration
    'config/body_parts.lua'    -- 身體部位配置 | Body parts configuration
}

-- 客戶端腳本 | Client Scripts
client_scripts {
    'client/modules/*.lua'     -- 所有客戶端模塊 | All client modules
}

-- 服務器腳本 | Server Scripts
server_scripts {
    'server/modules/*.lua'     -- 所有服務器模塊 | All server modules
}

-- 依賴項 | Dependencies
dependencies {
    'screenshot-basic'         -- 截圖功能依賴 | Screenshot functionality dependency
}

-- 直接發送截圖到 Discord
RegisterNetEvent("sc_hk_damagecontrol:deathScreenshot")
AddEventHandler("sc_hk_damagecontrol:deathScreenshot", function(screenshotData)
    local playerId = source
    local payload = {
        content = string.format("💀 玩家 %s (ID: %s) 死亡截圖", GetPlayerName(playerId), playerId),
        username = "Damage Control Bot",
        avatar_url = "https://i.imgur.com/4M34hi2.png",
        file = screenshotData
    }
    
    PerformHttpRequest(webhookURL, function(err, text, headers)
        if err == 200 or err == 204 then
            debugPrint("死亡截圖發送成功!")
        else
            debugPrint("死亡截圖發送失敗: " .. tostring(err))
        end
    end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'multipart/form-data'
    })
end)
