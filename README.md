# stardew-moddev-skills

星露谷物语 Mod 开发 Claude Code 插件。

基于 [Pathoschild/SMAPI](https://github.com/Pathoschild/SMAPI) 和 [Pathoschild/StardewMods/ContentPatcher](https://github.com/Pathoschild/StardewMods/tree/develop/ContentPatcher) 官方源码构建。

## 安装

### 通过 Claude Code 插件管理器安装（推荐）

在 Claude Code 中运行：

```
/plugins manage
```

选择 "Add a plugin"，输入仓库地址：

```
git@github.com:AUPaiDev/stardew-moddev-skills.git
```

### 安装后配置

```bash
# 复制路径配置文件并编辑
cp ${CLAUDE_PLUGIN_ROOT}/config/paths.env.example ${CLAUDE_PLUGIN_ROOT}/config/paths.env
# 编辑 paths.env 设置你的 Stardew Valley 安装路径
```

## 技能列表

| 技能 | 说明 |
|------|------|
| `skills/stardew-moddev/` | 主入口：总览、强制规范、快速开始 |
| `skills/env-setup/` | 从零搭建开发环境 |
| `skills/mod-create/` | 创建新 Mod 项目脚手架 |
| `skills/dev-workflow/` | 完整开发工作流（核心） |
| `skills/debug/` | 调试与错误排查 |
| `skills/content-patcher/` | Content Patcher 配置指南 |

## 快速开始

```bash
# 1. 检查开发环境
${CLAUDE_PLUGIN_ROOT}/scripts/env-setup.sh

# 2. 创建 feature 分支（强制）
${CLAUDE_PLUGIN_ROOT}/scripts/git-feature.sh my-new-feature

# 3. 创建 Mod 项目（参考 mod-create 技能）
# 4. 编写代码（参考 dev-workflow 技能）

# 5. 一键构建 → 部署 → 启动 → 监控（强制）
${CLAUDE_PLUGIN_ROOT}/scripts/dev-cycle.sh <mod-directory>
```

## 强制规范

1. **Git Feature 分支**：新功能开发必须在 `feature/*` 分支上进行，禁止直接在 main/master 开发
2. **完整开发周期**：代码修改后必须执行构建→部署→启动游戏→日志监控的完整流程

## 目录结构

```
stardew-moddev-skills/
├── .claude-plugin/
│   └── plugin.json              # Claude Code 插件清单
├── skills/                      # 技能文件
│   ├── stardew-moddev/SKILL.md  # 主技能入口
│   ├── env-setup/SKILL.md       # 环境搭建
│   ├── mod-create/SKILL.md      # 创建 Mod
│   ├── dev-workflow/SKILL.md    # 开发工作流
│   ├── debug/                   # 调试指南
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── common-errors.md
│   └── content-patcher/         # Content Patcher
│       ├── SKILL.md
│       └── references/
│           └── asset-paths.md
├── scripts/                     # 自动化脚本
├── sample/                      # 模板文件
└── config/
    └── paths.env.example        # 路径配置示例
```
