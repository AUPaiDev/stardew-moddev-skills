# stardew-moddev-skills

星露谷物语 Mod 开发 Claude Code 插件。

基于 [Pathoschild/SMAPI](https://github.com/Pathoschild/SMAPI) 和 [Pathoschild/StardewMods/ContentPatcher](https://github.com/Pathoschild/StardewMods/tree/develop/ContentPatcher) 官方源码构建。

## 安装

### 步骤 1：添加 marketplace

```bash
claude plugins marketplace add git@github.com:AUPaiDev/stardew-moddev-skills.git
```

### 步骤 2：安装插件

```bash
claude plugins install stardew-moddev-skills@stardew-moddev
```

### 步骤 3：配置路径

```bash
# 复制路径配置文件并编辑
cp ${CLAUDE_PLUGIN_ROOT}/config/paths.env.example ${CLAUDE_PLUGIN_ROOT}/config/paths.env
# 编辑 paths.env 设置你的 Stardew Valley 安装路径
```

## 技能列表

| 技能 | 说明 |
|------|------|
| `stardew-moddev` | 主入口：总览、强制规范、快速开始 |
| `env-setup` | 从零搭建开发环境 |
| `mod-create` | 创建新 Mod 项目脚手架 |
| `dev-workflow` | 完整开发工作流（核心） |
| `debug` | 调试与错误排查 |
| `content-patcher` | Content Patcher 配置指南 |

## 强制规范

1. **Git Feature 分支**：新功能开发必须在 `feature/*` 分支上进行，禁止直接在 main/master 开发
2. **完整开发周期**：代码修改后必须执行构建→部署→启动游戏→日志监控的完整流程

## 目录结构

```
stardew-moddev-skills/
├── .claude-plugin/
│   └── marketplace.json             # Marketplace 清单
├── plugins/
│   └── stardew-moddev-skills/       # 插件目录
│       ├── .claude-plugin/
│       │   └── plugin.json          # 插件清单
│       ├── skills/                  # 技能文件
│       │   ├── stardew-moddev/
│       │   ├── env-setup/
│       │   ├── mod-create/
│       │   ├── dev-workflow/
│       │   ├── debug/
│       │   └── content-patcher/
│       ├── scripts/                 # 自动化脚本
│       ├── sample/                  # 模板文件
│       └── config/                  # 配置文件
└── README.md
```
