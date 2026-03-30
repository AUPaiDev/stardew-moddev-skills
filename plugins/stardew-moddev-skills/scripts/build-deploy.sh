#!/bin/bash
# ============================================================
# 星露谷物语 Mod 构建部署
# ============================================================
# 用法: ./build-deploy.sh <mod-directory> [Release|Debug]
# 功能: 检查 git 分支 → 编译 → 部署到 Mods 目录
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/paths.env"

# 加载配置
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
elif [ -f "$SCRIPT_DIR/../config/paths.env.example" ]; then
    source "$SCRIPT_DIR/../config/paths.env.example"
else
    echo "✗ 找不到配置文件"
    exit 1
fi

# 参数解析
MOD_DIR="${1:?用法: ./build-deploy.sh <mod-directory> [Release|Debug]}"
BUILD_CONFIG="${2:-Release}"

# 解析 mod 目录（支持相对路径和绝对路径）
if [ ! -d "$MOD_DIR" ]; then
    # 尝试在项目根目录查找
    PARENT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
    if [ -d "$PARENT_DIR/$MOD_DIR" ]; then
        MOD_DIR="$PARENT_DIR/$MOD_DIR"
    else
        echo "✗ Mod 目录不存在: $MOD_DIR"
        exit 1
    fi
fi
MOD_DIR="$(cd "$MOD_DIR" && pwd)"

# 查找 .csproj 文件
CSPROJ=$(find "$MOD_DIR" -maxdepth 1 -name "*.csproj" | head -1)
if [ -z "$CSPROJ" ]; then
    echo "✗ 未找到 .csproj 文件: $MOD_DIR"
    exit 1
fi

MOD_NAME=$(basename "$CSPROJ" .csproj)

echo "============================================"
echo "  构建部署: $MOD_NAME"
echo "  配置: $BUILD_CONFIG"
echo "============================================"
echo ""

# ============================================
# 【强制执行】Git 分支守卫
# ============================================
echo "【1/3】检查 Git 分支..."

# 找到最近的 git 仓库根目录
GIT_ROOT="$MOD_DIR"
while [ "$GIT_ROOT" != "/" ]; do
    if [ -d "$GIT_ROOT/.git" ]; then
        break
    fi
    GIT_ROOT="$(dirname "$GIT_ROOT")"
done

if [ -d "$GIT_ROOT/.git" ]; then
    CURRENT_BRANCH=$(cd "$GIT_ROOT" && git branch --show-current 2>/dev/null || echo "unknown")

    if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
        echo ""
        echo "  ╔══════════════════════════════════════════════╗"
        echo "  ║  ✗ 禁止在 $CURRENT_BRANCH 分支上构建！            ║"
        echo "  ║                                              ║"
        echo "  ║  请先创建 feature 分支:                       ║"
        echo "  ║  ./scripts/git-feature.sh <feature-name>     ║"
        echo "  ╚══════════════════════════════════════════════╝"
        echo ""
        exit 1
    fi

    echo "  ✓ 当前分支: $CURRENT_BRANCH"
else
    echo "  ⚠ 未检测到 Git 仓库（建议初始化 git）"
fi
echo ""

# ============================================
# 构建
# ============================================
echo "【2/3】编译 $MOD_NAME..."
cd "$MOD_DIR"

if dotnet build -c "$BUILD_CONFIG" 2>&1; then
    echo ""
    echo "  ✓ 编译成功"
else
    echo ""
    echo "  ✗ 编译失败，请检查错误信息"
    exit 1
fi
echo ""

# ============================================
# 验证部署
# ============================================
echo "【3/3】验证部署..."

DEPLOY_DIR="$MODS_DIR/$MOD_NAME"
if [ -d "$DEPLOY_DIR" ]; then
    echo "  部署目录: $DEPLOY_DIR"
    echo "  已部署文件:"

    # 列出部署的文件
    find "$DEPLOY_DIR" -type f | while read -r file; do
        SIZE=$(ls -lh "$file" | awk '{print $5}')
        REL_PATH="${file#$DEPLOY_DIR/}"
        echo "    $SIZE  $REL_PATH"
    done

    # 检查 DLL 是否存在
    if [ -f "$DEPLOY_DIR/$MOD_NAME.dll" ]; then
        echo ""
        echo "  ✓ $MOD_NAME.dll 已部署"
    else
        echo ""
        echo "  ⚠ $MOD_NAME.dll 未找到，请检查 .csproj 中的 CopyToMods target"
    fi

    # 检查 manifest.json
    if [ -f "$DEPLOY_DIR/manifest.json" ]; then
        echo "  ✓ manifest.json 已部署"
    else
        echo "  ⚠ manifest.json 未找到"
    fi
else
    echo "  ⚠ 部署目录不存在: $DEPLOY_DIR"
    echo "  请检查 .csproj 中是否配置了 CopyToMods target"
fi

echo ""
echo "============================================"
echo "  构建部署完成！"
echo "  下一步: ./launch-game.sh 启动游戏"
echo "============================================"
