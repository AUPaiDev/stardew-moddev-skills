#!/bin/bash
# ============================================================
# 星露谷 Mod 完整开发周期（一键执行）
# ============================================================
# 用法: ./dev-cycle.sh <mod-directory>
# 功能: 构建部署 → 启动游戏 → 监控日志
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MOD_DIR="${1:?用法: ./dev-cycle.sh <mod-directory>}"

echo "╔══════════════════════════════════════════════╗"
echo "║     星露谷 Mod 开发周期 - 一键执行           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# === 步骤 1: 构建部署 ===
echo "━━━ 步骤 1/3: 构建部署 ━━━"
if ! "$SCRIPT_DIR/build-deploy.sh" "$MOD_DIR" Release; then
    echo ""
    echo "✗ 构建失败，终止开发周期"
    exit 1
fi
echo ""

# === 步骤 2: 启动游戏 ===
echo "━━━ 步骤 2/3: 启动游戏 ━━━"
"$SCRIPT_DIR/launch-game.sh"
echo ""

# === 步骤 3: 等待并监控日志 ===
echo "━━━ 步骤 3/3: 等待 SMAPI 启动... ━━━"
sleep 3

echo "━━━ 开始日志监控 ━━━"
"$SCRIPT_DIR/monitor-log.sh"
