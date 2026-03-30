# Content Patcher 资源路径参考

参考来源：[Pathoschild/StardewMods/ContentPatcher](https://github.com/Pathoschild/StardewMods/tree/develop/ContentPatcher)

## 角色相关

| 资源路径 | 说明 | 文件格式 |
|----------|------|---------|
| `Characters/{NpcName}` | NPC 精灵图 | PNG, 16×32/帧, 4帧×4方向 |
| `Characters/Farmer/farmer_base` | 玩家基础精灵 | PNG |
| `Characters/Farmer/farmer_girl_base` | 女性玩家基础精灵 | PNG |
| `Portraits/{NpcName}` | NPC 肖像 | PNG, 64×64/表情 |
| `Portraits/Farmer` | 玩家肖像 | PNG |

### 精灵图规格

```
┌────────────────────────────────┐
│  帧1  │  帧2  │  帧3  │  帧4  │  ← 朝下 (方向 2)
│ 16×32 │ 16×32 │ 16×32 │ 16×32 │
├────────────────────────────────┤
│  帧1  │  帧2  │  帧3  │  帧4  │  ← 朝右 (方向 1)
├────────────────────────────────┤
│  帧1  │  帧2  │  帧3  │  帧4  │  ← 朝上 (方向 0)
├────────────────────────────────┤
│  帧1  │  帧2  │  帧3  │  帧4  │  ← 朝左 (方向 3)
└────────────────────────────────┘
总尺寸: 64 × 128 像素（最小）
```

### 肖像规格

```
┌──────┬──────┬──────┬──────┐
│表情1 │表情2 │表情3 │表情4 │
│64×64 │64×64 │64×64 │64×64 │
├──────┼──────┼──────┼──────┤
│表情5 │表情6 │表情7 │表情8 │
│64×64 │64×64 │64×64 │64×64 │
└──────┴──────┴──────┴──────┘
标准尺寸: 256 × 256 像素（4×4 网格, 最多16种表情）
```

## 对话相关

| 资源路径 | 说明 | 文件格式 |
|----------|------|---------|
| `Dialogue/{NpcName}` | NPC 基础对话 | JSON 键值对 |
| `Characters/Dialogue/{NpcName}` | NPC 对话（完整路径） | JSON 键值对 |
| `Data/EngagementDialogue` | 订婚对话 | JSON |
| `Strings/StringsFromCSFiles` | 游戏内置字符串 | JSON |

### 对话键名约定

| 键名格式 | 说明 | 示例 |
|----------|------|------|
| `Mon` | 星期一对话 | `"Mon": "今天是星期一。"` |
| `Tue` | 星期二对话 | |
| `spring_1` | 春季第1天 | `"spring_1": "春天到了！"` |
| `summer` | 夏季通用 | |
| `rainy` | 下雨天 | |

### 对话语法

| 语法 | 说明 |
|------|------|
| `#$b#` | 换行（对话翻页） |
| `$h` | 高兴表情 |
| `$s` | 悲伤表情 |
| `$u` | 惊讶表情 |
| `$a` | 生气表情 |
| `$l` | 爱心表情 |
| `$q` | 选项对话开始 |
| `$r` | 选项回复 |
| `@` | 玩家名字 |
| `%adj` | 随机形容词 |
| `%noun` | 随机名词 |

## 数据表相关

| 资源路径 | 说明 |
|----------|------|
| `Data/NPCDispositions` | NPC 性格、位置、生日等基础数据 |
| `Data/NPCGiftTastes` | NPC 送礼偏好 |
| `Data/ObjectInformation` | 物品信息 |
| `Data/CraftingRecipes` | 制作配方 |
| `Data/CookingRecipes` | 烹饪配方 |
| `Data/Shops` | 商店数据 |
| `Data/Events/{LocationName}` | 事件脚本 |
| `Data/Festivals/{FestivalName}` | 节日数据 |

## 地图相关

| 资源路径 | 说明 |
|----------|------|
| `Maps/Town` | 小镇地图 |
| `Maps/Farm` | 农场地图 |
| `Maps/FarmHouse` | 农舍地图 |
| `Maps/Beach` | 海滩地图 |
| `Maps/Mountain` | 山区地图 |
| `Maps/Forest` | 森林地图 |
| `Maps/Mine` | 矿洞地图 |
| `Maps/{CustomLocation}` | 自定义地点地图 |

### 地图文件格式

- 使用 Tiled Map Editor 编辑
- 文件格式：`.tmx`（Tiled XML）
- 图块集：`.png`
- 每个图块：16 × 16 像素

## NPC 日程相关

| 资源路径 | 说明 |
|----------|------|
| `Characters/schedules/{NpcName}` | NPC 每日日程 |

### 日程格式

```
时间 地点名 X坐标 Y坐标 朝向 [动作]
```

示例：
```
"spring": "600 FarmHouse 5 5 2/1000 Town 40 20 2/1800 FarmHouse 5 5 0"
```

表示：6:00 在 FarmHouse(5,5) 朝下 → 10:00 到 Town(40,20) 朝下 → 18:00 回 FarmHouse(5,5) 朝上
