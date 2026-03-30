---
name: content-patcher
description: >
  Content Patcher 完整使用指南。JSON 配置格式、资源替换/编辑/加载、
  动态令牌、资源路径规范。参考 Pathoschild/StardewMods 官方源码。

  USE WHEN (使用场景):
  - Content Patcher、替换贴图、replace sprite、精灵图
  - 肖像、portrait、对话、dialogue、content.json、资源加载、asset
  - 动态令牌、dynamic token、条件替换
  - 地图编辑、map edit
---

# Content Patcher 配置指南

参考来源：[Pathoschild/StardewMods/ContentPatcher](https://github.com/Pathoschild/StardewMods/tree/develop/ContentPatcher)

## 概述

Content Patcher 允许通过 JSON 配置文件修改游戏资源，无需编写 C# 代码。它是 SMAPI 生态中最常用的资源替换框架。

**适用场景**：
- 替换/编辑角色精灵图和肖像
- 修改对话文本
- 编辑地图
- 修改游戏数据（物品、NPC 行为等）

## content.json 基本格式

```json
{
  "Format": "1.30.0",
  "Changes": [
    {
      "LogName": "操作描述（用于日志）",
      "Action": "Load",
      "Target": "资源路径",
      "FromFile": "assets/本地文件路径"
    }
  ]
}
```

参考模板：`${CLAUDE_PLUGIN_ROOT}/sample/content.json.template`

## manifest.json 依赖声明

使用 Content Patcher 的 Mod 需要在 manifest.json 中声明依赖：

```json
{
  "Dependencies": [
    {
      "UniqueId": "Pathoschild.ContentPatcher",
      "IsRequired": false
    }
  ]
}
```

- `IsRequired: true`：Mod 必须安装 Content Patcher 才能运行
- `IsRequired: false`：Content Patcher 为可选功能（推荐）

## Action 类型

### Load（完全替换）

完全替换目标资源为自定义文件：

```json
{
  "Action": "Load",
  "Target": "Characters/MyNpc",
  "FromFile": "assets/Characters/MyNpc.png"
}
```

**适用场景**：自定义 NPC 精灵图、肖像、玩家外观

### Edit（部分编辑）

编辑现有资源的部分内容：

```json
{
  "Action": "Edit",
  "Target": "Portraits/MyNpc",
  "FromFile": "assets/Portraits/MyNpc_overlay.png",
  "ToArea": { "X": 0, "Y": 0, "Width": 64, "Height": 64 }
}
```

**适用场景**：修改 NPC 的某个表情、编辑地图的某个区域

### EditData（编辑数据字典）

编辑游戏数据条目：

```json
{
  "Action": "EditData",
  "Target": "Data/NPCDispositions",
  "Entries": {
    "MyNpc": "adult/neutral/outgoing/positive/male/not-datable/null/Town/spring 1//MyNpcHouse 5 5/MyNpc"
  }
}
```

**适用场景**：添加 NPC 到游戏数据、修改物品属性、编辑商店库存

### EditMap（编辑地图）

编辑游戏地图：

```json
{
  "Action": "EditMap",
  "Target": "Maps/Town",
  "FromFile": "assets/Maps/Town_patch.tmx",
  "ToArea": { "X": 10, "Y": 20, "Width": 5, "Height": 5 }
}
```

## 动态令牌（Dynamic Tokens）

Content Patcher 支持条件逻辑，根据游戏状态动态应用修改。

### 内置令牌

| 令牌 | 说明 | 可能值 |
|------|------|--------|
| `{{Season}}` | 当前季节 | spring, summer, fall, winter |
| `{{Weather}}` | 当前天气 | Sun, Rain, Storm, Snow, Wind |
| `{{Day}}` | 当前日期 | 1-28 |
| `{{DayOfWeek}}` | 星期 | Monday-Sunday |
| `{{Time}}` | 当前时间 | 600-2600 |
| `{{Year}}` | 当前年份 | 1+ |
| `{{HasMod}}` | 是否安装了某 Mod | true/false |
| `{{FarmType}}` | 农场类型 | Standard, Riverland, Forest, Hilltop, Wilderness, FourCorners |
| `{{PlayerName}}` | 玩家名 | 任意字符串 |
| `{{HasProfession}}` | 是否有某职业 | true/false |
| `{{Hearts:NpcName}}` | 与 NPC 好感度 | 0-14 |

### 条件示例

```json
{
  "Action": "Load",
  "Target": "Characters/MyNpc",
  "FromFile": "assets/Characters/MyNpc_{{Season}}.png",
  "When": {
    "Season": "spring, summer"
  }
}
```

### 多条件组合

```json
{
  "Action": "EditData",
  "Target": "Characters/Dialogue/MyNpc",
  "Entries": {
    "Mon": "今天是雨天呢..."
  },
  "When": {
    "Weather": "Rain",
    "Hearts:MyNpc": "{{Range: 6, 14}}"
  }
}
```

## 资源路径规范

详见 [references/asset-paths.md](references/asset-paths.md) 获取完整路径表。

### 常用路径速查

| 路径 | 说明 |
|------|------|
| `Characters/{NpcName}` | NPC 精灵图 |
| `Portraits/{NpcName}` | NPC 肖像 |
| `Characters/Farmer/farmer_base` | 玩家基础精灵 |
| `Portraits/Farmer` | 玩家肖像 |
| `Dialogue/{NpcName}` | NPC 对话 |
| `Characters/schedules/{NpcName}` | NPC 日程 |
| `Data/NPCDispositions` | NPC 基本属性 |
| `Maps/{MapName}` | 游戏地图 |

## Content Patcher vs C# AssetRequested

| 特性 | Content Patcher (JSON) | C# AssetRequested |
|------|----------------------|-------------------|
| 门槛 | 低（纯 JSON） | 高（需要 C#） |
| 静态资源替换 | 最佳选择 | 可以但不必要 |
| 动态/条件资源 | 支持（When 条件） | 完全灵活 |
| 运行时生成纹理 | 不支持 | 支持 |
| 复杂逻辑 | 有限 | 无限制 |
| 推荐场景 | 精灵图/肖像/对话替换 | 动态纹理合成、复杂条件 |

**建议**：优先使用 Content Patcher（更简单、更安全），仅在需要运行时动态生成资源时使用 C# AssetRequested。

## 调试 Content Patcher

### 查看已应用的修改

在 SMAPI 控制台输入：
```
patch summary
```

### 查看特定资源的修改来源

```
patch summary "Characters/MyNpc"
```

### 强制刷新资源

```
patch reload
```
