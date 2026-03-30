---
name: mod-create
description: >
  创建新的星露谷物语 SMAPI Mod 项目脚手架。生成标准目录结构和配置文件。
  包含 manifest.json、.csproj、ModEntry.cs 等模板。

  USE WHEN (使用场景):
  - 创建新 mod、新建项目、create mod、new mod
  - 脚手架、scaffold、初始化项目
  - 新模组、新插件
---

# 创建新 Mod 项目

## ══════════════════════════════════════
## 【强制执行】开发前必须创建 Feature 分支
## ══════════════════════════════════════

```bash
# 步骤 1: 同步最新代码
${CLAUDE_PLUGIN_ROOT}/scripts/git-sync.sh

# 步骤 2: 创建 feature 分支
${CLAUDE_PLUGIN_ROOT}/scripts/git-feature.sh <feature-name>
# 例如: ${CLAUDE_PLUGIN_ROOT}/scripts/git-feature.sh add-new-npc
```

**在 main/master 分支上的任何开发操作都将被 build-deploy.sh 拒绝。**

## 项目目录命名约定

```
mod-{name}/         # 例如: mod-sushilegend, mod-autohello
```

## 创建步骤

### 1. 创建目录结构

```
mod-{name}/
├── ModEntry.cs          # Mod 入口
├── {Name}.csproj        # 项目文件
├── manifest.json        # SMAPI 元数据
├── nuget.config         # NuGet 配置
├── assets/              # 资源文件
│   ├── Characters/      # NPC 精灵图（16x32 每帧）
│   ├── Portraits/       # NPC 肖像（64x64 每表情）
│   └── Dialogue/        # 对话 JSON 文件
└── content.json         # Content Patcher 配置（可选）
```

### 2. 从模板生成文件

模板文件位于 `${CLAUDE_PLUGIN_ROOT}/sample/` 目录，使用时替换占位符：

#### manifest.json

参考 `${CLAUDE_PLUGIN_ROOT}/sample/manifest.json.template`

占位符替换规则：
| 占位符 | 说明 | 示例 |
|--------|------|------|
| `{{MOD_NAME}}` | Mod 技术名称（与 DLL 名一致） | `SuShiLegend` |
| `{{MOD_DISPLAY_NAME}}` | 显示名称 | `苏轼传说` |
| `{{MOD_DESCRIPTION}}` | Mod 描述 | `将苏轼引入星露谷的故事模组` |
| `{{AUTHOR}}` | 作者名 | `tauwoo` |

**UniqueId 命名规范**: `作者名.Mod名`，例如 `tauwoo.SuShiLegend`

#### .csproj 项目文件

参考 `${CLAUDE_PLUGIN_ROOT}/sample/ModName.csproj.template`

关键配置说明：
- `TargetFramework`: `net9.0`（与 .NET SDK 版本匹配）
- DLL 引用使用 `$(HOME)` 前缀确保跨用户兼容
- `CopyToMods` target 在每次构建后自动部署到 Stardew Valley Mods 目录
- `{{MOD_NAME}}` 需替换为实际 Mod 名

#### ModEntry.cs

参考 `${CLAUDE_PLUGIN_ROOT}/sample/ModEntry.cs.template`

包含以下常用模式：
- SMAPI 事件注册（GameLoop、Input、Content）
- NPC 生成方法
- 对话系统
- HUD 消息
- 数据持久化

### 3. Content Patcher 配置（可选）

如果 Mod 需要替换或编辑游戏资源（精灵图、肖像、对话等），需要：

1. 在 `manifest.json` 的 Dependencies 中添加 Content Patcher（已在模板中配置为可选依赖）
2. 创建 `content.json`，参考 `${CLAUDE_PLUGIN_ROOT}/sample/content.json.template`
3. 详细配置见 `skills/content-patcher/SKILL.md`

### 4. 验证项目

```bash
cd mod-{name}
dotnet build
```

如果编译成功，说明项目配置正确。

### 5. 运行测试

```bash
# 使用一键开发周期脚本
${CLAUDE_PLUGIN_ROOT}/scripts/dev-cycle.sh mod-{name}
```

## 资源文件规格

### 角色精灵图（Characters/）

- 格式：PNG
- 每帧尺寸：16 × 32 像素
- 布局：4 帧/行 × 4 方向（上、右、下、左）
- 最小尺寸：64 × 128 像素（4帧 × 4方向，无动画）
- 带行走动画：64 × 128 像素（标准 4 帧行走）

### 肖像图（Portraits/）

- 格式：PNG
- 每个表情：64 × 64 像素
- 布局：多个表情横向排列
- 标准尺寸：256 × 256 像素（4×4 表情网格）

### 对话文件（Dialogue/）

- 格式：JSON
- 键值对：`"对话键": "对话内容"`
- 支持 Stardew Valley 对话语法（换行符 `#$b#`、表情 `$h` 等）
