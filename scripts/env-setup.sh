#!/bin/bash
# ============================================================
# 星露谷物语 Mod 开发环境搭建
# ============================================================
# 用法: ./env-setup.sh
# 功能: 检查并安装 .NET SDK、验证 SMAPI、检查 DLL 引用
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/paths.env"

# 加载配置
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
elif [ -f "$SCRIPT_DIR/../config/paths.env.example" ]; then
    echo "⚠ 未找到 config/paths.env，使用 paths.env.example 默认配置"
    echo "  建议运行: cp config/paths.env.example config/paths.env 并编辑路径"
    source "$SCRIPT_DIR/../config/paths.env.example"
else
    echo "✗ 找不到配置文件，请先创建 config/paths.env"
    exit 1
fi

echo "============================================"
echo "  星露谷物语 Mod 开发环境检查"
echo "  操作系统: $OS_TYPE"
echo "============================================"
echo ""

PASS=0
FAIL=0

check_pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
check_fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
check_warn() { echo "  ⚠ $1"; }

# --- 1. .NET SDK ---
echo "【1/4】检查 .NET SDK..."
if command -v dotnet &>/dev/null; then
    DOTNET_VERSION=$(dotnet --version 2>/dev/null || echo "unknown")
    check_pass ".NET SDK 已安装: $DOTNET_VERSION"

    # 检查版本是否 >= 6.0
    MAJOR_VERSION=$(echo "$DOTNET_VERSION" | cut -d. -f1)
    if [ "$MAJOR_VERSION" -ge 6 ] 2>/dev/null; then
        check_pass ".NET 版本满足要求 (>= 6.0)"
    else
        check_warn ".NET 版本 $DOTNET_VERSION 可能过低，建议 >= 6.0"
    fi
else
    check_fail ".NET SDK 未安装"
    echo ""
    echo "  安装方法:"
    if [ "$OS_TYPE" = "Darwin" ]; then
        echo "    brew install dotnet-sdk"
    elif [ "$OS_TYPE" = "Linux" ]; then
        echo "    sudo apt-get install dotnet-sdk-9.0"
        echo "    或参考: https://dotnet.microsoft.com/download"
    fi
fi
echo ""

# --- 2. Stardew Valley ---
echo "【2/4】检查 Stardew Valley 安装..."
if [ -d "$STARDEW_HOME" ]; then
    check_pass "Stardew Valley 目录存在: $STARDEW_HOME"
else
    check_fail "Stardew Valley 目录不存在: $STARDEW_HOME"
    echo "  请确认游戏已通过 Steam 安装，或修改 config/paths.env 中的路径"
fi
echo ""

# --- 3. SMAPI ---
echo "【3/4】检查 SMAPI..."
if [ -f "$SMAPI_BIN" ]; then
    check_pass "SMAPI 已安装: $SMAPI_BIN"

    # macOS: 检查是否被 Gatekeeper 隔离
    if [ "$OS_TYPE" = "Darwin" ]; then
        if xattr "$SMAPI_BIN" 2>/dev/null | grep -q "com.apple.quarantine"; then
            check_warn "SMAPI 被 macOS Gatekeeper 隔离，正在移除..."
            xattr -cr "$STARDEW_HOME" 2>/dev/null && check_pass "隔离属性已移除" || check_fail "无法移除隔离属性，请手动运行: xattr -cr \"$STARDEW_HOME\""
        fi
    fi
else
    check_fail "SMAPI 未安装"
    echo "  安装方法:"
    echo "    1. 下载 SMAPI: https://smapi.io/"
    echo "    2. 解压后运行安装脚本"

    # 检查是否有本地安装器
    INSTALLER_DIR="$(dirname "$SCRIPT_DIR")/../SMAPI*installer*"
    for dir in $INSTALLER_DIR; do
        if [ -d "$dir" ]; then
            echo "    发现本地安装器: $dir"
            echo "    运行: open \"$dir/install on macOS.command\""
        fi
    done
fi
echo ""

# --- 4. DLL 引用 ---
echo "【4/4】检查关键 DLL 文件..."
DLLS=(
    "StardewModdingAPI.dll"
    "Stardew Valley.dll"
    "MonoGame.Framework.dll"
)

for dll in "${DLLS[@]}"; do
    if [ -f "$STARDEW_HOME/$dll" ]; then
        check_pass "$dll"
    else
        check_fail "$dll 不存在于 $STARDEW_HOME/"
    fi
done

# Mods 目录
if [ -d "$MODS_DIR" ]; then
    MOD_COUNT=$(ls -1d "$MODS_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')
    check_pass "Mods 目录存在，已安装 $MOD_COUNT 个 Mod"
else
    check_warn "Mods 目录不存在，将在首次安装 Mod 时创建"
fi
echo ""

# --- 汇总 ---
echo "============================================"
echo "  检查结果: ✓ $PASS 通过  ✗ $FAIL 失败"
echo "============================================"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "  环境就绪！可以开始 Mod 开发。"
    echo "  下一步: 使用 mod-create 技能创建新项目"
else
    echo ""
    echo "  请修复以上问题后重新运行此脚本。"
    exit 1
fi
