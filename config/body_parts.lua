-- 身體部位配置文件 | Body Parts Configuration File
-- 定義不同身體部位的傷害倍率 | Define damage multipliers for different body parts

return {
    head = {
        name = "頭部",
        multiplier = 2.0,  -- 頭部受擊傷害加成，暴擊傷害通常針對此部位
        critical = true        -- 是否可暴擊 | Can critical hit
    },
    neck = {
        name = "頸部",
        multiplier = 1.5,  -- 頸部傷害較高，但不如頭部致命
    },
    torso = {
        name = "軀幹",
        multiplier = 1.0,  -- 正常傷害倍率
        critical = false       -- 不可暴擊 | Cannot critical hit
    },
    stomach = {
        name = "腹部",
        multiplier = 1.2,  -- 腹部受到的傷害略高
    },
    left_arm = {
        name = "左臂",
        multiplier = 0.8,  -- 手臂防護較好，傷害較低
        critical = false       -- 不可暴擊 | Cannot critical hit
    },
    right_arm = {
        name = "右臂",
        multiplier = 0.8,
        critical = false       -- 不可暴擊 | Cannot critical hit
    },
    left_leg = {
        name = "左腿",
        multiplier = 0.8,  -- 腿部受擊傷害降低，以維持移動能力
        critical = false       -- 不可暴擊 | Cannot critical hit
    },
    right_leg = {
        name = "右腿",
        multiplier = 0.8,
        critical = false       -- 不可暴擊 | Cannot critical hit
    },
    left_shoulder = {
        name = "左肩",
        multiplier = 0.9,  -- 肩部稍微降低傷害
    },
    right_shoulder = {
        name = "右肩",
        multiplier = 0.9,
    },
    left_hand = {
        name = "左手",
        multiplier = 0.7,  -- 手部傷害較低，通常不影響致命性
    },
    right_hand = {
        name = "右手",
        multiplier = 0.7,
    },
    left_foot = {
        name = "左腳",
        multiplier = 0.7,  -- 腳部受擊時傷害降低，保持基本行走功能
    },
    right_foot = {
        name = "右腳",
        multiplier = 0.7,
    },
}