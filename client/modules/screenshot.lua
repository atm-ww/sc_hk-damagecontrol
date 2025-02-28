-- 此模塊負責處理 Discord 快速操作按鈕觸發的截圖請求。
-- 當收到服務器端發出的 "sc_hk_damagecontrol:requestScreenshot" 事件時，
-- 此模塊將調用外部截圖插件捕獲截圖，然後將截圖數據上傳給服務器。

RegisterNetEvent("sc_hk_damagecontrol:requestScreenshot")
AddEventHandler("sc_hk_damagecontrol:requestScreenshot", function()
    print("[DamageControl] 收到截圖請求，開始捕獲截圖...")

    -- 調用外部截圖插件（例如 screenshot-basic），其回調函數將返回截圖數據
    TriggerEvent('screenshot:request', function(screenshotData)
        if screenshotData then
            print("[DamageControl] 截圖捕獲成功，正在上傳截圖數據到服務器...")
            TriggerServerEvent("sc_hk_damagecontrol:uploadScreenshot", screenshotData)
        else
            print("[DamageControl] 截圖捕獲失敗或未獲得截圖數據。")
        end
    end)
end)