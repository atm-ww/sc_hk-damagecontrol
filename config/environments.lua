-- 環境影響配置文件 | Environment Effects Configuration File
-- 定義環境因素對傷害的影響 | Define how environmental factors affect damage

return {
    -- 時間相關
    day = {
        name = "白天",
        damageModifier = 1.0, -- 正常傷害倍率
    },
    night = {
        name = "夜晚",
        damageModifier = 1.1, -- 夜晚因視線不良，傷害倍率略微提高
    },

    -- 天氣相關
    clear = {
        name = "晴朗",
        damageModifier = 1.0,
    },
    cloudy = {
        name = "多雲",
        damageModifier = 1.0,
    },
    rain = {
        name = "雨天",
        damageModifier = 0.9, -- 雨天降低傷害（例如因為動作不便）
    },
    storm = {
        name = "暴風雨",
        damageModifier = 0.8, -- 暴風雨環境下傷害大幅降低
    },
    fog = {
        name = "大霧",
        damageModifier = 1.05, -- 大霧中可能因視野受限而略微提高傷害
    },
    snow = {
        name = "下雪",
        damageModifier = 0.95, -- 下雪天氣略微降低傷害
    },

    -- 特殊區域
    safeZone = {
        name = "安全區",
        damageModifier = 0.0, -- 安全區內不允許造成傷害
    },
    gangTerritory = {
        name = "幫派地盤",
        damageModifier = 1.2, -- 幫派地盤內由於高戒備可能提高傷害
    },
    restrictedArea = {
        name = "限制區域",
        damageModifier = 0.7, -- 限制區域內因防禦措施而降低傷害
    },

    weather = {
        rain = {
            multiplier = 0.9,  -- 雨天傷害倍率 | Rain damage multiplier
            effect = "slip"    -- 特殊效果：滑倒 | Special effect: slip
        },
        snow = {
            multiplier = 0.8,  -- 雪天傷害倍率 | Snow damage multiplier
            effect = "freeze"  -- 特殊效果：凍傷 | Special effect: freeze
        }
    },
    time = {
        night = {
            multiplier = 1.2,  -- 夜間傷害倍率 | Night damage multiplier
            effect = "stealth" -- 特殊效果：隱匿 | Special effect: stealth
        }
    },
    zones = {
        water = {
            multiplier = 1.5,  -- 水中傷害倍率 | Water damage multiplier
            effect = "drown"   -- 特殊效果：溺水 | Special effect: drown
        }
    }
}