---
name: env-setup
description: >
  星露谷物语 Mod 开发环境从零搭建。配置 .NET SDK、SMAPI、DLL 引用、NuGet。

  USE WHEN (使用场景):
  - 搭建环境、安装 SMAPI、配置开发环境、新电脑配置
  - .NET SDK、environment setup、setup stardew
  - 开发环境、初始化环境
---

# 环境搭建指南

## 前置条件

| 组件 | 最低版本 | 说明 |
|------|---------|------|
| .NET SDK | 6.0+（推荐 9.0） | C# 编译环境 |
| Stardew Valley | 1.6+ | 通过 Steam 安装 |
| SMAPI | 4.0.0+ | Stardew Modding API |

## 一键环境检查

运行自动检查脚本：

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/env-setup.sh
```

该脚本会自动检测：.NET SDK、Stardew Valley 安装、SMAPI、关键 DLL 文件。

## 手动安装步骤

### 1. 安装 .NET SDK

**macOS**:
```bash
brew install dotnet-sdk
```

**Linux**:
```bash
sudo apt-get install dotnet-sdk-9.0
```

验证：
```bash
dotnet --version
# 应输出 9.0.x 或更高
```

### 2. 安装 SMAPI

1. 从 [smapi.io](https://smapi.io/) 下载最新版
2. 解压并运行安装脚本
3. macOS 用户可能需要移除隔离属性：
```bash
xattr -cr "$HOME/Library/Application Support/Steam/steamapps/common/Stardew Valley/Contents/MacOS"
```

### 3. 验证 DLL 引用

Mod 开发需要引用以下 DLL，它们位于 Stardew Valley 安装目录：

| DLL 文件 | 说明 |
|----------|------|
| `StardewModdingAPI.dll` | SMAPI 核心 API（Mod 入口、事件系统、辅助方法） |
| `Stardew Valley.dll` | 游戏本体（Game1、NPC、GameLocation 等） |
| `MonoGame.Framework.dll` | 图形框架（Texture2D、Vector2、SpriteBatch） |

**macOS 路径**:
```
~/Library/Application Support/Steam/steamapps/common/Stardew Valley/Contents/MacOS/
```

**Linux 路径**:
```
~/.steam/steam/steamapps/common/Stardew Valley/
```

### 4. NuGet 配置

创建 `nuget.config`（参考 `${CLAUDE_PLUGIN_ROOT}/sample/nuget.config.template`）：

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
</configuration>
```

### 5. 验证环境

```bash
# 创建临时测试项目
mkdir test-mod && cd test-mod
dotnet new classlib
# 如果成功，说明 .NET 环境正常
rm -rf test-mod
```

## 常见问题

### Q: macOS 上 SMAPI 启动报错 "damaged and can't be opened"
**A**: 运行 `xattr -cr` 命令移除隔离属性（见步骤 2）

### Q: DLL 引用找不到
**A**: 检查 .csproj 中的 `HintPath` 是否使用 `$(HOME)` 前缀，确保路径正确

### Q: dotnet build 报 TargetFramework 错误
**A**: 确保安装的 .NET SDK 版本 >= 项目 TargetFramework（如 net9.0 需要 SDK 9.0+）
