-- ACE 權限整合模塊 | ACE Permission Integration Module
-- 用於管理員命令和權限控制 | For admin commands and permission control

-- 權限緩存系統 | Permission cache system
local permissionCache = {}
local cacheDuration = 300000  -- 緩存持續時間（毫秒）| Cache duration (ms)

-- 檢查管理員權限 | Check admin permission
local function isAdmin(source)
    -- 檢查緩存 | Check cache
    if permissionCache[source] and 
       (GetGameTimer() - permissionCache[source].timestamp) < cacheDuration then
        return permissionCache[source].hasPermission
    end

    -- 檢查 ACE 權限 | Check ACE permission
    local hasPermission = IsPlayerAceAllowed(source, "command.damagecontrol")
    
    -- 更新緩存 | Update cache
    permissionCache[source] = {
        hasPermission = hasPermission,
        timestamp = GetGameTimer()
    }
    
    return hasPermission
end

-- 此模塊整合了 ACE 權限系統，提供管理員對插件功能（如凍結玩家、請求截圖、查詢歷史記錄等）的訪問控制。
-- 同時實現了一個簡單的權限緩存機制，以減少對 IsPlayerAceAllowed 的頻繁調用。

local allowedPlayers = {}  -- 權限緩存表

-- 檢查玩家是否具有指定權限
function hasAcePermission(playerId, permission)
    if allowedPlayers[playerId] and allowedPlayers[playerId][permission] ~= nil then
        return allowedPlayers[playerId][permission]
    end

    local result = IsPlayerAceAllowed(playerId, permission)
    allowedPlayers[playerId] = allowedPlayers[playerId] or {}
    allowedPlayers[playerId][permission] = result
    return result
end

-- 事件：凍結玩家（僅限具有 "damagecontrol.freeze" 權限的管理員）
RegisterNetEvent("sc_hk_damagecontrol:freezePlayer")
AddEventHandler("sc_hk_damagecontrol:freezePlayer", function(targetPlayerId)
    local src = source
    if hasAcePermission(src, "damagecontrol.freeze") then
        TriggerClientEvent("sc_hk_damagecontrol:freeze", targetPlayerId)
        print("Player " .. src .. " 成功凍結了玩家 " .. targetPlayerId)
    else
        print("Player " .. src .. " 嘗試凍結玩家 " .. targetPlayerId .. " 但沒有足夠權限！")
        TriggerClientEvent("chat:addMessage", src, { args = { "系統", "你沒有權限執行此操作。" } })
    end
end)

-- 事件：請求截圖（僅限具有 "damagecontrol.screenshot" 權限的管理員）
RegisterNetEvent("sc_hk_damagecontrol:requestAdminScreenshot")
AddEventHandler("sc_hk_damagecontrol:requestAdminScreenshot", function(targetPlayerId)
    local src = source
    if hasAcePermission(src, "damagecontrol.screenshot") then
        TriggerClientEvent("sc_hk_damagecontrol:requestScreenshot", targetPlayerId)
        print("Player " .. src .. " 請求了玩家 " .. targetPlayerId .. " 的截圖")
    else
        print("Player " .. src .. " 嘗試請求截圖但沒有足夠權限！")
        TriggerClientEvent("chat:addMessage", src, { args = { "系統", "你沒有權限執行此操作。" } })
    end
end)

-- 事件：查詢玩家歷史記錄（僅限具有 "damagecontrol.history" 權限的管理員）
RegisterNetEvent("sc_hk_damagecontrol:queryPlayerHistory")
AddEventHandler("sc_hk_damagecontrol:queryPlayerHistory", function(targetPlayerId)
    local src = source
    if hasAcePermission(src, "damagecontrol.history") then
        TriggerEvent("sc_hk_damagecontrol:getHistory", targetPlayerId)
        print("Player " .. src .. " 查詢了玩家 " .. targetPlayerId .. " 的歷史記錄")
    else
        print("Player " .. src .. " 嘗試查詢歷史記錄但沒有足夠權限！")
        TriggerClientEvent("chat:addMessage", src, { args = { "系統", "你沒有權限執行此操作。" } })
    end
end)

-- 可選：清理權限緩存，用於在配置更新或權限變動後刷新緩存
function clearAceCache(playerId)
    if playerId then
        allowedPlayers[playerId] = nil
    else
        allowedPlayers = {}
    end
end

-- 命令：管理員可使用 /clearAceCache 命令手動清除自己的權限緩存
RegisterCommand("clearAceCache", function(source, args, rawCommand)
    local src = source
    if hasAcePermission(src, "damagecontrol.admin") then
        clearAceCache(src)
        TriggerClientEvent("chat:addMessage", src, { args = { "系統", "你的權限緩存已清除。" } })
    else
        TriggerClientEvent("chat:addMessage", src, { args = { "系統", "你沒有權限執行此操作。" } })
    end
end, false)

-- 根據需求，您可以在此添加更多 ACE 權限檢查與管理功能。