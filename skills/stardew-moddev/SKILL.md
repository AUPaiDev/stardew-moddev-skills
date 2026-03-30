---
name: stardew-moddev-skills
description: >
  星露谷物语 Mod 完整开发技能套件。涵盖环境搭建、Mod 创建、开发工作流、
  调试排查、Content Patcher 配置。基于 SMAPI 框架和 Content Patcher，
  参考 Pathoschild/SMAPI 和 Pathoschild/StardewMods 官方源码。

  USE WHEN (使用场景):
  - 星露谷 mod 开发
  - stardew valley mod
  - SMAPI mod
  - 编写 mod
  - mod 开发
  - 星露谷
  - stardew
---

# 星露谷物语 Mod 开发技能套件

## 概述

本技能套件为 Stardew Valley Mod 开发提供完整的工具链支持，基于以下官方源码：
- **SMAPI 核心**：[Pathoschild/SMAPI](https://github.com/Pathoschild/SMAPI)
- **Content Patcher**：[Pathoschild/StardewMods/ContentPatcher](https://github.com/Pathoschild/StardewMods/tree/develop/ContentPatcher)

## 子技能索引

| 技能 | 说明 | 触发关键词 |
|------|------|-----------|
| `skills/env-setup/SKILL.md` | 从零搭建开发环境 | 搭建环境、安装 SMAPI、.NET SDK |
| `skills/mod-create/SKILL.md` | 创建新 Mod 项目脚手架 | 创建新 mod、new mod、脚手架 |
| `skills/dev-workflow/SKILL.md` | 完整开发工作流（核心） | 编译、构建、部署、启动游戏、测试 |
| `skills/debug/SKILL.md` | 调试与错误排查 | 调试、报错、SMAPI 日志、崩溃 |
| `skills/content-patcher/SKILL.md` | Content Patcher 配置指南 | Content Patcher、替换贴图、content.json |

## ══════════════════════════════════════
## 强制规范（所有开发活动必须遵守）
## ══════════════════════════════════════

### 规范 1：Git Feature 分支工作流【强制执行】

**任何新功能开发前，必须执行以下步骤：**

1. 同步最新代码：
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git-sync.sh
```

2. 创建 feature 分支：
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/git-feature.sh <feature-name>
```

3. **禁止** 在 main/master 分支上直接开发
4. `build-deploy.sh` 脚本内置分支守卫，会拒绝在 main/master 上构建

### 规范 2：构建后必须自动部署+启动+监控【强制执行】

**Mod 编辑完成后，必须执行完整开发周期：**

```bash
# 一键执行完整流程
${CLAUDE_PLUGIN_ROOT}/scripts/dev-cycle.sh <mod-directory>
```

该命令会依次执行：
1. `build-deploy.sh` — 编译 + 自动部署 DLL 和素材到 Mods 目录
2. `launch-game.sh` — 自动启动带 SMAPI 的游戏
3. `monitor-log.sh` — 自动开始 SMAPI 日志实时监听

**禁止** 仅编译不测试。每次代码变更后必须运行完整周期以尽早发现问题。

## 快速开始

### 5 步从零到运行

```
步骤 1: 搭建环境        → ${CLAUDE_PLUGIN_ROOT}/scripts/env-setup.sh
步骤 2: 创建 feature 分支 → ${CLAUDE_PLUGIN_ROOT}/scripts/git-feature.sh my-feature
步骤 3: 创建 Mod 项目    → 参考 skills/mod-create/SKILL.md + sample/ 模板
步骤 4: 编写代码         → 参考 skills/dev-workflow/SKILL.md 中的 SMAPI API 参考
步骤 5: 构建测试         → ${CLAUDE_PLUGIN_ROOT}/scripts/dev-cycle.sh <mod-dir>
```

## 脚本索引

所有脚本位于 `${CLAUDE_PLUGIN_ROOT}/scripts/` 目录：

| 脚本 | 用途 |
|------|------|
| `scripts/env-setup.sh` | 检查并搭建开发环境 |
| `scripts/git-feature.sh` | 创建 feature 分支 |
| `scripts/git-sync.sh` | 同步 main 最新代码 |
| `scripts/build-deploy.sh` | 构建 + 部署（含分支守卫） |
| `scripts/launch-game.sh` | 启动 SMAPI 游戏 |
| `scripts/monitor-log.sh` | 实时日志监控 |
| `scripts/dev-cycle.sh` | 一键完整开发周期 |

## 模板索引

所有模板位于 `${CLAUDE_PLUGIN_ROOT}/sample/` 目录：

| 模板 | 说明 |
|------|------|
| `sample/ModEntry.cs.template` | Mod 入口代码 |
| `sample/manifest.json.template` | Mod 元数据 |
| `sample/ModName.csproj.template` | 项目文件（含自动部署） |
| `sample/content.json.template` | Content Patcher 配置 |
| `sample/nuget.config.template` | NuGet 源配置 |
