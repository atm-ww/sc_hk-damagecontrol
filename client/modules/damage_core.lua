-- 此模塊負責監聽玩家受傷事件並計算最終傷害，
-- 包含各系統獨立開關、受傷累積與腎上腺素系統、
-- 禁用爆頭傷害、防止一擊必殺、傷害來源獨立調整（含爆炸、車輛、近戰、掉落）、
-- 以及武器增強（配件與耐久度）功能。
-- 請將此文件存放於 client/modules/ 文件夾中

-- 在文件開頭添加 debugPrint 函數定義
local function debugPrint(message)
    print("[DamageControl Debug] " .. tostring(message))
end

-- 修改配置參數
local config = {
    systems = {
        damageAccumulation = false,      -- 關閉累積傷害系統 | Disable damage accumulation system
        disableHeadshot = false,         -- 關閉禁用爆頭 | Enable headshot damage
        preventOneHitKill = true,        -- 保持一擊必殺保護 | Keep one-hit kill protection
        explosiveAdjustment = false,     -- 關閉爆炸傷害調整 | Disable explosive damage adjustment
        vehicleDamageAdjustment = false, -- 關閉車輛傷害調整 | Disable vehicle damage adjustment
        meleeDamageAdjustment = false,   -- 關閉近戰傷害調整 | Disable melee damage adjustment
        fallDamageAdjustment = true,     -- 保持掉落傷害調整 | Keep fall damage adjustment
        weaponEnhancement = false,       -- 關閉武器增強系統 | Disable weapon enhancement system
    },
    debug = false,                       -- 關閉調試模式 | Disable debug mode
    fallDamageMultiplier = 1.0,         -- 正常掉落傷害 | Normal fall damage
    fallDamageBase = 5.0                -- 基礎掉落傷害係數 | Base fall damage coefficient
}

-- 累計傷害與腎上腺素系統變數
local cumulativeDamage = 0
local adrenalineActive = false
local adrenalineDuration = 10000  -- 腎上腺素持續時間（毫秒）
local adrenalineTimer = 0

-- 在文件開頭添加變數
local isDead = false
local lastDeathTime = 0
local DEATH_SCREENSHOT_COOLDOWN = 5000  -- 死亡截圖冷卻時間（毫秒）

-- 獲取 Discord Webhook URL
local webhookURL = GetConvar('discord_webhook', 'https://discord.com/api/webhooks/1345052670863609906/Miqpmqu_3Nw5NXAPYIZjj-V6d0_1Hnc4COrcyQsmh-bl3Bf1iThyeO6PTAIwThbf2KTa')

-- 模擬函數：獲取武器增強因子（可根據配件或耐久度調整）
local function getWeaponEnhancementFactor(weaponHash)
    return 1.0  -- 此示例固定返回 1.0，請根據實際情況替換
end

-- 更新腎上腺素狀態
local function updateAdrenaline(damage)
    if config.systems.damageAccumulation then
        cumulativeDamage = cumulativeDamage + damage
        if cumulativeDamage >= config.damageAccumulationThreshold and not adrenalineActive then
            adrenalineActive = true
            adrenalineTimer = GetGameTimer() + adrenalineDuration
            print("[DamageCore] 腎上腺素系統啟動！")
            -- 此處可添加額外效果，如通知玩家或提升移動速度
        end
    end
end

-- 檢查腎上腺素是否過期
local function checkAdrenalineStatus()
    if adrenalineActive and GetGameTimer() >= adrenalineTimer then
        adrenalineActive = false
        cumulativeDamage = 0
        print("[DamageCore] 腎上腺素效果結束。")
    end
end

-- 主傷害處理函數
local function onPlayerDamaged(attacker, weaponHash, damage, isCritical, bodyPart, damageSource)
    -- 參數說明：
    -- attacker: 傷害來源（攻擊者或 nil）
    -- weaponHash: 武器哈希
    -- damage: 原始傷害值
    -- isCritical: 是否暴擊
    -- bodyPart: 命中身體部位（例如 "head", "torso", "legs" 等）
    -- damageSource: 傷害來源分類（例如 "explosive", "vehicle", "melee", "fall"）

    checkAdrenalineStatus()
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)
    local position = GetEntityCoords(playerPed)

    -- 禁用爆頭傷害（若 bodyPart 為 "head"）
    if config.systems.disableHeadshot and bodyPart == "head" then
        print("[DamageCore] 爆頭傷害被禁用。")
        -- 此處可進一步處理，如設置 headMultiplier 為 1.0
    end

    -- 防止一擊必殺：若傷害大於等於當前生命值，調整為保留 1 點血量
    if config.systems.preventOneHitKill and damage >= currentHealth then
        damage = currentHealth - 1
        print(string.format("[DamageCore] 防止一擊必殺，調整傷害為 %d", damage))
    end

    -- 根據傷害來源做獨立調整
    if damageSource == "explosive" and config.systems.explosiveAdjustment then
        damage = damage * config.explosiveMultiplier
    elseif damageSource == "vehicle" and config.systems.vehicleDamageAdjustment then
        damage = damage * config.vehicleMultiplier
    elseif damageSource == "melee" and config.systems.meleeDamageAdjustment then
        damage = damage * config.meleeMultiplier
    end

    -- 應用武器增強效果
    if config.systems.weaponEnhancement then
        local enhancementFactor = getWeaponEnhancementFactor(weaponHash)
        damage = damage * enhancementFactor
    end

    -- 若腎上腺素激活則降低傷害
    if adrenalineActive then
        damage = damage * (1 - config.adrenalineBonus)
        print(string.format("[DamageCore] 腎上腺素激活：傷害降低至 %.2f", damage))
    end

    updateAdrenaline(damage)

    -- 根據最終傷害設定視覺分級
    local damageColor = ""
    if damage < 50 then
        damageColor = "green"
    elseif damage >= 50 and damage <= 100 then
        damageColor = "yellow"
    else
        damageColor = "red"
    end

    -- 根據武器類型決定圖示（可擴充至完整 weapons.lua 配置）
    local weaponEmoji = "🔫"
    if weaponHash == GetHashKey("weapon_unarmed") then
        weaponEmoji = "👊"
    elseif weaponHash == GetHashKey("weapon_knife") then
        weaponEmoji = "🔪"
    elseif weaponHash == GetHashKey("weapon_grenade") then
        weaponEmoji = "💥"
    end

    -- 組裝傷害數據
    local damageData = {
        playerId = GetPlayerServerId(PlayerId()),
        playerName = GetPlayerName(PlayerId()),
        damage = damage,
        damageColor = damageColor,
        weaponEmoji = weaponEmoji,
        isCritical = isCritical or false,
        currentHealth = currentHealth,
        position = { x = position.x, y = position.y, z = position.z },
        bodyPart = bodyPart or "unknown",
        damageSource = damageSource or "unknown",
        adrenalineActive = adrenalineActive,
        cumulativeDamage = cumulativeDamage
    }

    -- 將傷害數據傳送至服務器端（例如用於 Discord 通知）
    TriggerServerEvent("sc_hk_damagecontrol:playerDamaged", damageData)
end

-- 監聽遊戲內傷害事件（此處以 CEventNetworkEntityDamage 為例）
AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == "CEventNetworkEntityDamage" then
        local attacker    = args[1]                -- 傷害來源
        local weaponHash  = args[2]                -- 武器哈希
        local rawDamage   = args[3]                -- 原始傷害
        local isCritical  = args[4] or false         -- 是否暴擊
        local bodyPart    = args[5] or "torso"       -- 命中部位
        local damageSource = args[6] or "melee"      -- 傷害來源分類（預設為 melee）
        onPlayerDamaged(attacker, weaponHash, rawDamage, isCritical, bodyPart, damageSource)
    end
end)

----------------------------------------------------------
-- 掉落傷害檢測
-- 由於 GTA V 可能不會自動觸發掉落傷害事件，
-- 此處建立一個監控線程，根據玩家下落高度差計算掉落傷害，
-- 並手動調用 onPlayerDamaged，傳入 damageSource 為 "fall"。

-- 掉落傷害相關變數
local isFalling = false
local fallStartHeight = 0.0
local lastFallCheck = 0
local FALL_CHECK_INTERVAL = 50  -- 降低檢查間隔到 50ms
local MIN_FALL_DISTANCE = 2.0   -- 降低最小掉落距離閾值

-- 改進掉落傷害計算
local function calculateFallDamage(fallDistance)
    -- 優化基礎傷害計算公式
    local baseDamage = (fallDistance - MIN_FALL_DISTANCE) * config.fallDamageBase
    local finalDamage = baseDamage * config.fallDamageMultiplier
    
    -- 只在調試模式下輸出詳細信息
    if config.debug then
        print(string.format("[DamageCore] 掉落傷害：距離=%.1f米, 傷害=%.1f", fallDistance, finalDamage))
    end
    
    return finalDamage
end

-- 優化的掉落檢測線程
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local currentTime = GetGameTimer()
        
        -- 只在必要時進行檢查
        if not IsPedInAnyVehicle(playerPed, true) then
            if IsPedFalling(playerPed) then
                if not isFalling then
                    isFalling = true
                    fallStartHeight = GetEntityCoords(playerPed).z
                end
            else
                if isFalling then
                    isFalling = false
                    local currentPos = GetEntityCoords(playerPed)
                    local fallDistance = fallStartHeight - currentPos.z
                    
                    -- 立即處理掉落傷害
                    if fallDistance > MIN_FALL_DISTANCE and 
                       (currentTime - lastFallCheck) > FALL_CHECK_INTERVAL then
                        
                        lastFallCheck = currentTime
                        local damage = calculateFallDamage(fallDistance)
                        
                        -- 立即應用傷害
                        if config.systems.fallDamageAdjustment and damage > 0 then
                            local currentHealth = GetEntityHealth(playerPed)
                            local newHealth = math.max(0, currentHealth - damage)
                            SetEntityHealth(playerPed, newHealth)
                            
                            -- 異步發送事件
                            Citizen.CreateThread(function()
                                TriggerServerEvent("sc_hk_damagecontrol:playerDamaged", {
                                    playerId = GetPlayerServerId(PlayerId()),
                                    playerName = GetPlayerName(PlayerId()),
                                    damage = damage,
                                    damageColor = "red",
                                    weaponEmoji = "👊",
                                    currentHealth = newHealth,
                                    position = currentPos,
                                    damageSource = "fall"
                                })
                            end)
                        end
                    end
                end
            end
        end
        
        -- 動態調整等待時間
        if isFalling then
            Citizen.Wait(FALL_CHECK_INTERVAL)  -- 掉落時更頻繁檢查
        else
            Citizen.Wait(100)  -- 正常時可以稍微放寬檢查間隔
        end
    end
end)

-- 添加錯誤處理
local function handleError(err)
    print('[DamageControl] 錯誤: ' .. tostring(err))
end

-- 包裝主要功能在 pcall 中
Citizen.CreateThread(function()
    local status, err = pcall(function()
        -- 主要邏輯
        while true do
            Citizen.Wait(1000)
            if isInitialized then
                local ped = PlayerPedId()
                -- 您的代碼...
            end
        end
    end)
    
    if not status then
        handleError(err)
    end
end)

-- 改進的死亡檢測函數
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        local currentTime = GetGameTimer()
        
        if IsEntityDead(ped) then
            if not isDead and (currentTime - lastDeathTime) > DEATH_SCREENSHOT_COOLDOWN then
                isDead = true
                lastDeathTime = currentTime
                
                -- 等待一小段時間以確保死亡動畫播放
                Citizen.Wait(1000)
                
                -- 獲取當前坐標
                local coords = GetEntityCoords(ped)
                
                -- 請求截圖
                debugPrint("正在請求死亡截圖...")
                exports['screenshot-basic']:requestScreenshotUpload(webhookURL, 'files[]', {
                    encoding = 'jpg',
                    quality = 0.95
                }, function(data)
                    debugPrint("收到截圖回應: " .. tostring(data))
                    local resp = json.decode(data)
                    if resp and resp.attachments and resp.attachments[1] and resp.attachments[1].url then
                        -- 發送死亡事件和截圖URL
                        TriggerServerEvent("sc_hk_damagecontrol:playerDeath", {
                            position = coords,
                            timestamp = currentTime,
                            screenshotUrl = resp.attachments[1].url
                        })
                        debugPrint("截圖上傳成功: " .. resp.attachments[1].url)
                    else
                        debugPrint("截圖上傳失敗")
                        -- 仍然發送死亡事件，但沒有截圖
                        TriggerServerEvent("sc_hk_damagecontrol:playerDeath", {
                            position = coords,
                            timestamp = currentTime
                        })
                    end
                end)
            end
        else
            isDead = false
        end
    end
end)

-- 1. 玩家數據同步
RegisterNetEvent('playerSync')
AddEventHandler('playerSync', function(data)
    -- 同步邏輯
end)

-- 2. 自動備份系統
function autoBackup()
    -- 備份邏輯
end

-- 3. 管理員日誌系統
function logAdminAction(admin, action, target)
    -- 日誌記錄邏輯
end