# sc_hk-damagecontrol

## 中文說明

### 概述
**sc_hk-damagecontrol** 是一個專為 FiveM 伺服器設計的進階傷害控制與監控系統。此插件提供全面的傷害管理、死亡記錄以及 Discord 整合功能。

### 主要功能
1. **傷害控制系統**
   - 自定義傷害計算與調整
   - 防止一擊必殺機制
   - 可禁用爆頭傷害
   - 獨立調整各類傷害（爆炸、車輛、近戰、掉落）
   - 武器傷害強化系統

2. **進階監控功能**
   - 死亡現場自動截圖
   - Discord 即時通知
   - 詳細的傷害報告
   - 玩家互動歷史記錄

3. **管理員工具**
   - ACE 權限整合
   - 管理員指令系統
   - 即時監控與干預功能

### 安裝步驟
1. 下載並解壓到資源目錄
```bash
cd resources
git clone https://github.com/your-repo/sc_hk-damagecontrol.git
```

2. 安裝依賴項
   - 確保已安裝 `screenshot-basic` 資源

3. 配置文件設置
```cfg
# 在 server.cfg 中添加：
set discord_webhook "YOUR_WEBHOOK_URL"
ensure screenshot-basic
ensure sc_hk-damagecontrol
```

### 使用說明
- 管理員命令：
  - `/clearHistory <玩家ID>` - 清除指定玩家的歷史記錄
  - `/testdamage` - 測試傷害系統

- Discord 通知功能會自動發送：
  - 玩家受傷報告
  - 死亡事件（含現場截圖）
  - 系統啟動狀態

### 支援與反饋
- Discord: 
- 作者: ℝ𝔸𝔽𝔸𝔼𝕃𝕄𝔸𝕋ℍ𝔼𝕆𝕌

---

## English Description

### Overview
**sc_hk-damagecontrol** is an advanced damage control and monitoring system designed for FiveM servers. This plugin provides comprehensive damage management, death logging, and Discord integration.

### Key Features
1. **Damage Control System**
   - Custom damage calculation and adjustment
   - Anti one-shot kill mechanism
   - Optional headshot damage disable
   - Independent damage type adjustment (explosive, vehicle, melee, fall)
   - Weapon damage enhancement system

2. **Advanced Monitoring**
   - Automatic death scene screenshots
   - Real-time Discord notifications
   - Detailed damage reports
   - Player interaction history

3. **Admin Tools**
   - ACE permission integration
   - Admin command system
   - Real-time monitoring and intervention

### Installation
1. Download and extract to resources directory
```bash
cd resources
git clone https://github.com/your-repo/sc_hk-damagecontrol.git
```

2. Install Dependencies
   - Ensure `screenshot-basic` resource is installed

3. Configuration Setup
```cfg
# Add to server.cfg:
set discord_webhook "YOUR_WEBHOOK_URL"
ensure screenshot-basic
ensure sc_hk-damagecontrol
```

### Usage Guide
- Admin Commands:
  - `/clearHistory <playerID>` - Clear specified player's history
  - `/testdamage` - Test damage system

- Discord notifications automatically send:
  - Player damage reports
  - Death events (with scene screenshots)
  - System startup status

### Support & Feedback
- Discord: 
- Author: ℝ𝔸𝔽𝔸𝔼𝕃𝕄𝔸𝕋ℍ𝔼𝕆𝕌

### License
This plugin is open source. You are free to use and modify it, but please retain the original author information.

### Version History
v1.0.0
- Initial release
- Basic damage control implementation
- Discord integration
- Death screenshot feature
