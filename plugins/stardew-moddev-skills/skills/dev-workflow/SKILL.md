---
name: dev-workflow
description: >
  星露谷 Mod 开发完整工作流。Git 分支管理、编译构建、自动部署、
  启动游戏、SMAPI 日志实时监控。包含 SMAPI 事件系统、数据持久化、
  NPC 创建等核心 API 参考。

  USE WHEN (使用场景):
  - 编译 mod、构建部署、build deploy、启动游戏、launch game
  - 开发流程、运行 mod、test mod、测试、发布
  - SMAPI 事件、API 参考、事件系统
  - NPC 创建、对话系统、数据持久化
---

# 开发工作流（核心技能）

## ══════════════════════════════════════
## 【强制执行】规范 1：Git Feature 分支
## ══════════════════════════════════════

**每次开发新功能前，必须：**

```bash
# 1. 同步远程最新代码
${CLAUDE_PLUGIN_ROOT}/scripts/git-sync.sh

# 2. 创建新 feature 分支
${CLAUDE_PLUGIN_ROOT}/scripts/git-feature.sh <feature-name>
```

- 禁止在 main/master 分支直接开发
- `build-deploy.sh` 内置分支守卫，会拒绝在 main/master 上构建
- 分支命名格式：`feature/<feature-name>`

## ══════════════════════════════════════
## 【强制执行】规范 2：构建后完整流程
## ══════════════════════════════════════

**Mod 代码修改后，必须执行完整开发周期：**

```bash
# 一键执行：构建 → 部署 → 启动游戏 → 监控日志
${CLAUDE_PLUGIN_ROOT}/scripts/dev-cycle.sh <mod-directory>
```

或分步执行：
```bash
# 步骤 1: 构建 + 部署（DLL + 素材自动复制到 Mods 目录）
${CLAUDE_PLUGIN_ROOT}/scripts/build-deploy.sh <mod-directory> Release

# 步骤 2: 启动带 SMAPI 的游戏
${CLAUDE_PLUGIN_ROOT}/scripts/launch-game.sh

# 步骤 3: 实时监控 SMAPI 日志
${CLAUDE_PLUGIN_ROOT}/scripts/monitor-log.sh              # 全部日志
${CLAUDE_PLUGIN_ROOT}/scripts/monitor-log.sh --errors-only # 仅错误和警告
```

**禁止**仅编译不测试。每次变更后必须运行完整周期。

---

## SMAPI 核心 API 参考

以下 API 来源于 [Pathoschild/SMAPI](https://github.com/Pathoschild/SMAPI) 官方实现。

### Mod 入口生命周期

```csharp
public class ModEntry : Mod
{
    public override void Entry(IModHelper helper)
    {
        // Mod 加载时调用（仅一次）
        // 在此注册事件、初始化数据
    }
}
```

**关键对象**：
| 对象 | 类型 | 说明 |
|------|------|------|
| `this.Helper` | `IModHelper` | 提供事件、数据、内容等 API |
| `this.Monitor` | `IMonitor` | 日志输出 |
| `this.ModManifest` | `IManifest` | Mod 元数据（名称、版本等） |

### 事件系统（Events）

SMAPI 通过 `helper.Events` 提供事件订阅。事件处理器通过 `+=` 注册。

#### GameLoop 事件（游戏循环）

| 事件 | 触发时机 | 常见用途 |
|------|---------|---------|
| `GameLaunched` | 游戏启动完成 | 初始化与其他 Mod 的集成 |
| `SaveLoaded` | 存档加载完成 | 加载持久化数据、初始化状态 |
| `Saving` | 存档保存前 | 保存持久化数据 |
| `Saved` | 存档保存后 | 确认保存完成 |
| `DayStarted` | 每日开始 | 每日逻辑（NPC 生成、消息、检查） |
| `DayEnding` | 每日结束 | 每日清理 |
| `TimeChanged` | 时间变化（每10分钟游戏时间） | 定时触发事件 |
| `UpdateTicked` | 每帧更新（约60fps） | 实时逻辑（谨慎使用，影响性能） |
| `ReturnedToTitle` | 返回标题画面 | 清理状态 |

```csharp
// 注册示例
helper.Events.GameLoop.DayStarted += OnDayStarted;

private void OnDayStarted(object sender, DayStartedEventArgs e)
{
    if (!Context.IsWorldReady) return;  // 【重要】始终检查
    // 每日逻辑...
}
```

#### Input 事件（玩家输入）

| 事件 | 触发时机 | 常见用途 |
|------|---------|---------|
| `ButtonPressed` | 任意按键按下 | 自定义快捷键、NPC 交互 |
| `ButtonReleased` | 按键释放 | 按住操作 |
| `CursorMoved` | 鼠标移动 | 悬停效果 |

```csharp
helper.Events.Input.ButtonPressed += OnButtonPressed;

private void OnButtonPressed(object sender, ButtonPressedEventArgs e)
{
    if (!Context.IsWorldReady) return;

    if (e.Button == SButton.F5) { /* 自定义操作 */ }
    if (e.Button.IsActionButton()) { /* 动作键（右键/X） */ }
}
```

#### Content 事件（资源管理）

| 事件 | 触发时机 | 常见用途 |
|------|---------|---------|
| `AssetRequested` | 游戏请求加载资源 | 替换/编辑精灵图、肖像、对话 |
| `AssetReady` | 资源加载完成 | 后处理 |
| `AssetsInvalidated` | 资源缓存失效 | 刷新自定义资源 |

```csharp
helper.Events.Content.AssetRequested += OnAssetRequested;

private void OnAssetRequested(object sender, AssetRequestedEventArgs e)
{
    // 加载自定义精灵图
    if (e.NameWithoutLocale.IsEquivalentTo("Characters/MyNpc"))
    {
        e.LoadFromModFile<Texture2D>("assets/Characters/MyNpc.png",
            AssetLoadPriority.High);
    }

    // 编辑现有数据
    if (e.NameWithoutLocale.IsEquivalentTo("Data/NPCDispositions"))
    {
        e.Edit(asset =>
        {
            var data = asset.AsDictionary<string, string>();
            data.Data["MyNpc"] = "disposition_data_here";
        });
    }
}
```

#### Player 事件（玩家状态）

| 事件 | 触发时机 |
|------|---------|
| `InventoryChanged` | 背包物品变化 |
| `LevelChanged` | 技能升级 |
| `Warped` | 玩家切换地图 |

#### World 事件（游戏世界）

| 事件 | 触发时机 |
|------|---------|
| `ObjectListChanged` | 地图上物体变化 |
| `NpcListChanged` | NPC 列表变化 |
| `LocationListChanged` | 可用地点变化 |

### 数据持久化（Data API）

SMAPI 提供与存档绑定的数据持久化：

```csharp
// 定义数据结构
private class MyModData
{
    public int Level { get; set; } = 0;
    public Dictionary<string, int> Progress { get; set; } = new();
}

// 读取数据（存档加载后）
var data = helper.Data.ReadSaveData<MyModData>("MyMod.SaveData");

// 写入数据（保存前）
helper.Data.WriteSaveData("MyMod.SaveData", data);
```

### NPC 创建模式

```csharp
// 创建 NPC
var sprite = new AnimatedSprite(
    "Characters/NpcName",   // 精灵图资源路径
    0,                       // 起始帧
    16,                      // 帧宽
    32                       // 帧高
);

Vector2 tile = new Vector2(5, 5);
NPC npc = new NPC(sprite, tile * 64f, 2, "NpcName");

// 添加到地图
GameLocation location = Game1.getLocationFromName("FarmHouse");
location.addCharacter(npc);

// 设置对话
npc.CurrentDialogue.Push(new Dialogue(npc, null, "对话内容"));
```

### HUD 消息

```csharp
// 类型: 1=成就, 2=任务, 3=错误, 4=体力, 5=生命
Game1.addHUDMessage(new HUDMessage("消息内容", 2));
```

### 实用上下文检查

```csharp
Context.IsWorldReady    // 世界是否加载完成（大部分操作必须检查）
Context.IsPlayerFree    // 玩家是否可以自由行动
Context.IsMainPlayer    // 是否是主机玩家（多人游戏）
Context.CanPlayerMove   // 玩家是否可以移动
```

### Reflection API（反射访问私有成员）

用于访问游戏内部未公开的方法和字段：

```csharp
// 获取私有字段
var field = helper.Reflection.GetField<int>(Game1.player, "privatefield");
int value = field.GetValue();

// 调用私有方法
var method = helper.Reflection.GetMethod(someObject, "privateMethod");
method.Invoke(arg1, arg2);
```

**注意**：反射 API 应谨慎使用，游戏更新可能破坏私有成员的兼容性。

### 日志 API

```csharp
Monitor.Log("普通信息", LogLevel.Info);
Monitor.Log("调试信息", LogLevel.Debug);    // 仅在 SMAPI verbose 模式显示
Monitor.Log("警告信息", LogLevel.Warn);
Monitor.Log("错误信息", LogLevel.Error);
Monitor.Log("追踪信息", LogLevel.Trace);     // 详细追踪
```
