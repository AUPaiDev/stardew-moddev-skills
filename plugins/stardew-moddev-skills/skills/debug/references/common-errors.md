# 常见错误与解决方案

## 编译时错误

### ERR-01: Missing assembly reference

**错误信息**:
```
error CS0246: The type or namespace name 'StardewModdingAPI' could not be found
```

**原因**: .csproj 中 DLL 引用路径不正确

**解决方案**:
1. 检查 .csproj 中的 `<HintPath>` 是否指向正确的 Stardew Valley 安装目录
2. 确保使用 `$(HOME)` 前缀（macOS/Linux）：
```xml
<HintPath>$(HOME)/Library/Application Support/Steam/steamapps/common/Stardew Valley/Contents/MacOS/StardewModdingAPI.dll</HintPath>
```
3. 确认 DLL 文件实际存在于该路径

### ERR-02: TargetFramework 不匹配

**错误信息**:
```
error NETSDK1045: The current .NET SDK does not support targeting .NET 9.0
```

**原因**: 安装的 .NET SDK 版本低于项目要求

**解决方案**:
```bash
# 检查当前 SDK 版本
dotnet --version

# macOS 升级
brew upgrade dotnet-sdk

# 或修改 .csproj 中的 TargetFramework 为已安装版本
```

### ERR-03: Newtonsoft.Json 找不到

**错误信息**:
```
error CS0246: The type or namespace name 'Newtonsoft' could not be found
```

**解决方案**:
```bash
dotnet add package Newtonsoft.Json
```

或在 .csproj 中添加：
```xml
<PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
```

---

## 运行时错误

### ERR-10: Could not load type from assembly

**SMAPI 日志**:
```
[SMAPI] Skipped MyMod 1.0.0 because its DLL 'MyMod.dll' doesn't have entry class 'MyMod.ModEntry'
```

**原因**: manifest.json 中 EntryDll 与实际类不匹配

**解决方案**:
1. 确认 manifest.json 中 `EntryDll` 的值与 .csproj 输出的 DLL 名一致
2. 确认 ModEntry 类的命名空间和类名正确
3. 确认 ModEntry 继承了 `StardewModdingAPI.Mod`

### ERR-11: NullReferenceException (NPC 相关)

**SMAPI 日志**:
```
[ERROR] MyMod: NullReferenceException at OnDayStarted
```

**常见原因与解决**:

| 原因 | 解决方案 |
|------|---------|
| 世界未加载完成 | 添加 `if (!Context.IsWorldReady) return;` |
| GameLocation 为 null | 检查 `Game1.getLocationFromName()` 返回值 |
| NPC 不在当前位置 | 使用 `location.getCharacterFromName()` 前先检查 null |
| 对话对象为 null | 确保 NPC 的 Dialogue 文件已正确加载 |

```csharp
// 正确做法
private void OnDayStarted(object sender, DayStartedEventArgs e)
{
    if (!Context.IsWorldReady) return;  // 必须检查

    var location = Game1.getLocationFromName("FarmHouse");
    if (location == null)               // 必须检查
    {
        Monitor.Log("FarmHouse 不可用", LogLevel.Warn);
        return;
    }

    var npc = location.getCharacterFromName("MyNpc");
    if (npc != null)                    // 必须检查
    {
        // 安全操作 NPC
    }
}
```

### ERR-12: Asset not found

**SMAPI 日志**:
```
[ERROR] MyMod: Can't load asset 'assets/Characters/MyNpc.png'
```

**排查步骤**:
1. 确认文件存在于 Mod 项目的正确路径
2. 检查 .csproj 中是否配置了资源复制：
```xml
<None Update="assets/**">
    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
</None>
```
3. 检查部署目录（Mods/ModName/assets/）中文件是否存在
4. 确认 `LoadFromModFile` 的路径是相对于 Mod 根目录的

### ERR-13: AssetLoadPriority 冲突

**SMAPI 日志**:
```
[WARN] Multiple mods want to load asset 'Characters/MyNpc'
```

**解决方案**:
- 使用 `AssetLoadPriority.High` 而不是 `AssetLoadPriority.Exclusive`
- `Exclusive` 会导致与其他 Mod 冲突
- 如果确实需要独占加载，确保没有其他 Mod 修改同一资源

### ERR-14: Mod 加载但不生效

**排查步骤**:
1. 检查 SMAPI 日志是否显示 Mod 已加载（搜索 Mod 名）
2. 如果显示 "skipped"：检查 manifest.json 格式是否正确（JSON 语法、必需字段）
3. 如果已加载但功能不生效：
   - 确认事件处理器在 `Entry()` 方法中注册
   - 检查事件处理器中是否有 `Context.IsWorldReady` 等守卫条件阻止执行
   - 添加 `Monitor.Log()` 追踪执行流程

---

## 部署问题

### ERR-20: DLL 未部署到 Mods 目录

**原因**: .csproj 缺少 CopyToMods target

**解决方案**: 参考 [sample/ModName.csproj.template](../../sample/ModName.csproj.template) 中的 `CopyToMods` target

### ERR-21: 旧版本 DLL 残留

**现象**: 修改代码后行为未变化

**解决方案**:
```bash
# 清理构建缓存
dotnet clean
dotnet build -c Release

# 或手动删除部署目录
rm -rf "$MODS_DIR/ModName"
dotnet build -c Release
```

### ERR-22: manifest.json 格式错误

**SMAPI 日志**:
```
[SMAPI] Skipped MyMod because its manifest.json is invalid
```

**常见格式问题**:
- JSON 尾部逗号（最后一个字段后不能有逗号）
- 缺少必需字段（Name、Author、Version、UniqueId、EntryDll、MinimumApiVersion）
- Version 格式错误（必须是 `x.y.z` 格式）
