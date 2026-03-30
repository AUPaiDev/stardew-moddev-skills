#!/bin/bash
# ============================================================
# 启动 Stardew Valley（通过 SMAPI）
# ============================================================
# 用法: ./launch-game.sh
# 功能: 在后台启动 SMAPI，释放终端用于日志监控
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/paths.env"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
elif [ -f "$SCRIPT_DIR/../config/paths.env.example" ]; then
    source "$SCRIPT_DIR/../config/paths.env.example"
else
    echo "✗ 找不到配置文件"
    exit 1
fi

echo "============================================"
echo "  启动 Stardew Valley (SMAPI)"
echo "============================================"

# 检查 SMAPI
if [ ! -f "$SMAPI_BIN" ]; then
    echo "✗ SMAPI 未安装: $SMAPI_BIN"
    echo "  请先运行: ./env-setup.sh"
    exit 1
fi

# 检查是否已经在运行
if pgrep -f "StardewModdingAPI" > /dev/null 2>&1; then
    echo "  ⚠ Stardew Valley (SMAPI) 已在运行"
    echo "  PID: $(pgrep -f 'StardewModdingAPI' | head -1)"
    echo ""
    echo "  如需重启，请先关闭游戏后重新运行此脚本"
    exit 0
fi

# 启动 SMAPI
echo "  启动中..."
cd "$STARDEW_HOME"

if [ "$OS_TYPE" = "Darwin" ]; then
    # macOS: 使用 open 或直接执行
    "$SMAPI_BIN" &
    GAME_PID=$!
elif [ "$OS_TYPE" = "Linux" ]; then
    "$SMAPI_BIN" &
    GAME_PID=$!
else
    # Windows (WSL)
    cmd.exe /c "$(wslpath -w "$SMAPI_BIN")" &
    GAME_PID=$!
fi

echo "  ✓ SMAPI 已启动 (PID: $GAME_PID)"
echo ""
echo "  下一步: ./monitor-log.sh 监控日志"
echo "============================================"
