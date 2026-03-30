#!/bin/bash
# ============================================================
# SMAPI 日志实时监控
# ============================================================
# 用法: ./monitor-log.sh [--errors-only]
# 功能: 实时显示 SMAPI 日志，支持仅显示错误和警告
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

ERRORS_ONLY=false
if [ "${1:-}" = "--errors-only" ]; then
    ERRORS_ONLY=true
fi

echo "============================================"
echo "  SMAPI 日志监控"
if [ "$ERRORS_ONLY" = true ]; then
    echo "  模式: 仅显示错误和警告"
fi
echo "  按 Ctrl+C 停止监控"
echo "============================================"
echo ""

# 查找日志文件
SMAPI_LOG=$(find_smapi_log)

# 等待日志文件出现（最长等待 30 秒）
if [ ! -f "$SMAPI_LOG" ]; then
    echo "  等待 SMAPI 日志文件创建..."
    WAIT_COUNT=0
    while [ ! -f "$SMAPI_LOG" ] && [ $WAIT_COUNT -lt 30 ]; do
        sleep 1
        WAIT_COUNT=$((WAIT_COUNT + 1))

        # 重新查找（可能在另一个位置创建）
        SMAPI_LOG=$(find_smapi_log)
    done

    if [ ! -f "$SMAPI_LOG" ]; then
        echo "  ✗ 超时：未找到 SMAPI 日志文件"
        echo "  尝试过的路径:"
        for candidate in "${SMAPI_LOG_CANDIDATES[@]}"; do
            echo "    - $candidate"
        done
        echo ""
        echo "  请确认 SMAPI 正在运行（./launch-game.sh）"
        exit 1
    fi
fi

echo "  日志文件: $SMAPI_LOG"
echo "  ---"
echo ""

# 实时监控日志
if [ "$ERRORS_ONLY" = true ]; then
    tail -f "$SMAPI_LOG" | grep --line-buffered -E "\[ERROR\]|\[WARN\]|\[ALERT\]"
else
    tail -f "$SMAPI_LOG"
fi
