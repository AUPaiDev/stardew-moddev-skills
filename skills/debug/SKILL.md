---
name: debug
description: >
  星露谷 Mod 调试指南。SMAPI 日志分析、常见错误排查、运行时调试技巧。

  USE WHEN (使用场景):
  - 调试、debug、报错、error、SMAPI 日志、log
  - 崩溃、crash、不工作、not working、排查问题
  - 编译错误、运行时错误、NPC 不显示
  - 资源加载失败、asset not found
---

# 调试与错误排查

## SMAPI 日志

### 日志位置

| 操作系统 | 路径 |
|----------|------|
| macOS | `~/Library/Application Support/Steam/steamapps/common/Stardew Valley/Contents/MacOS/ErrorLogs/SMAPI-latest.txt` |
| macOS（备选） | `~/.config/StardewValley/ErrorLogs/SMAPI-latest.txt` |
| Linux | `~/.config/StardewValley/ErrorLogs/SMAPI-latest.txt` |
| Windows | `%AppData%/StardewValley/ErrorLogs/SMAPI-latest.txt` |

### 实时监控日志

```bash
# 全部日志
${CLAUDE_PLUGIN_ROOT}/scripts/monitor-log.sh

# 仅错误和警告
${CLAUDE_PLUGIN_ROOT}/scripts/monitor-log.sh --errors-only
```

### 日志级别

| 级别 | 标记 | 说明 |
|------|------|------|
| TRACE | `[TRACE]` | 最详细的追踪信息 |
| DEBUG | `[DEBUG]` | 调试信息（默认不显示） |
| INFO | `[INFO]` | 一般运行信息 |
| WARN | `[WARN]` | 警告（需要关注） |
| ERROR | `[ERROR]` | 错误（功能受影响） |
| ALERT | `[ALERT]` | 严重错误（Mod 可能无法运行） |

### 在代码中输出调试日志

```csharp
// 推荐：开发时使用 Debug，发布前改为 Trace
Monitor.Log($"变量值: {someVar}", LogLevel.Debug);
Monitor.Log($"NPC位置: {npc.Position}", LogLevel.Trace);
Monitor.Log("发生了某个异常情况", LogLevel.Warn);
```

## 常见错误参考

详见 [references/common-errors.md](references/common-errors.md) 获取完整错误列表。

### 快速排查流程

```
编译失败？
├── Missing assembly reference → 检查 .csproj DLL 路径
├── Type or namespace not found → 检查 using 语句和 DLL 引用
└── TargetFramework error → 检查 .NET SDK 版本

运行时报错？
├── Could not load type → 检查 manifest.json EntryDll
├── NullReferenceException
│   ├── NPC 相关 → 检查 Context.IsWorldReady
│   └── Location 相关 → 检查 Game1.getLocationFromName 返回值
├── Asset not found → 检查 CopyToOutputDirectory 和资源路径
└── AssetLoadPriority conflict → 使用 High 而非 Exclusive

Mod 不生效？
├── SMAPI 日志无此 Mod → 检查 Mods 目录部署
├── "skipped" 标记 → 检查 manifest.json 格式
└── 事件没触发 → 确认事件注册在 Entry() 中
```

## 调试技巧

### 1. 使用 SMAPI 控制台

游戏运行时，SMAPI 控制台支持命令输入：
- 查看已加载 Mod 列表
- 查看当前游戏状态

### 2. 条件断点日志

```csharp
// 仅在特定条件下输出日志，避免刷屏
if (Game1.currentSeason == "spring" && Game1.dayOfMonth == 1)
{
    Monitor.Log("春天第一天的特殊逻辑触发", LogLevel.Info);
}
```

### 3. 验证资源加载

```csharp
// 在 OnAssetRequested 中确认资源请求
private void OnAssetRequested(object sender, AssetRequestedEventArgs e)
{
    Monitor.Log($"资源请求: {e.NameWithoutLocale}", LogLevel.Trace);

    if (e.NameWithoutLocale.IsEquivalentTo("Characters/MyNpc"))
    {
        Monitor.Log("加载自定义 MyNpc 精灵图", LogLevel.Debug);
        e.LoadFromModFile<Texture2D>("assets/Characters/MyNpc.png",
            AssetLoadPriority.High);
    }
}
```

### 4. NPC 生成调试

```csharp
// 检查 NPC 是否已存在
var existingNpc = location.getCharacterFromName("MyNpc");
Monitor.Log($"NPC存在: {existingNpc != null}, 位置: {location.Name}", LogLevel.Debug);

// 列出当前位置所有 NPC
foreach (var character in location.characters)
{
    Monitor.Log($"  NPC: {character.Name} @ {character.Position}", LogLevel.Trace);
}
```
