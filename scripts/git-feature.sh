#!/bin/bash
# ============================================================
# Git Feature 分支创建
# ============================================================
# 用法: ./git-feature.sh <feature-name>
# 功能: 拉取最新 main → 创建 feature 分支
# 【强制执行】开发前必须使用此脚本创建分支
# ============================================================
set -euo pipefail

FEATURE_NAME="${1:?用法: ./git-feature.sh <feature-name>}"

echo "============================================"
echo "  创建 Feature 分支: feature/$FEATURE_NAME"
echo "============================================"
echo ""

# 检查 git 是否已初始化
if [ ! -d ".git" ]; then
    # 向上查找 git 仓库
    GIT_ROOT="$(pwd)"
    FOUND_GIT=false
    while [ "$GIT_ROOT" != "/" ]; do
        if [ -d "$GIT_ROOT/.git" ]; then
            FOUND_GIT=true
            break
        fi
        GIT_ROOT="$(dirname "$GIT_ROOT")"
    done

    if [ "$FOUND_GIT" = false ]; then
        echo "  ⚠ 未检测到 Git 仓库"
        echo "  正在初始化..."
        git init
        git add .
        git commit -m "初始提交"
        echo "  ✓ Git 仓库已初始化"
        echo ""
    else
        cd "$GIT_ROOT"
        echo "  Git 仓库根目录: $GIT_ROOT"
    fi
fi

# 检查是否有远程仓库
HAS_REMOTE=false
if git remote -v 2>/dev/null | grep -q "origin"; then
    HAS_REMOTE=true
fi

# 获取最新代码
echo "【1/3】同步最新代码..."
if [ "$HAS_REMOTE" = true ]; then
    git fetch origin 2>/dev/null || echo "  ⚠ 无法连接远程仓库，使用本地代码"
fi

# 确定主分支名
MAIN_BRANCH="main"
if git branch --list master | grep -q "master"; then
    if ! git branch --list main | grep -q "main"; then
        MAIN_BRANCH="master"
    fi
fi

# 切换到主分支并拉取
echo "【2/3】更新 $MAIN_BRANCH 分支..."
# 保存当前工作
STASH_CREATED=false
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    git stash push -m "auto-stash before feature branch creation"
    STASH_CREATED=true
    echo "  ✓ 已暂存未提交的更改"
fi

git checkout "$MAIN_BRANCH" 2>/dev/null || {
    echo "  ⚠ 无法切换到 $MAIN_BRANCH，可能当前就在该分支"
}

if [ "$HAS_REMOTE" = true ]; then
    git pull origin "$MAIN_BRANCH" 2>/dev/null || echo "  ⚠ 拉取失败，使用本地 $MAIN_BRANCH"
fi

# 创建 feature 分支
echo "【3/3】创建分支..."
BRANCH_NAME="feature/$FEATURE_NAME"

if git branch --list "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
    echo "  ⚠ 分支 $BRANCH_NAME 已存在，切换到该分支"
    git checkout "$BRANCH_NAME"
else
    git checkout -b "$BRANCH_NAME"
    echo "  ✓ 已创建并切换到: $BRANCH_NAME"
fi

# 恢复暂存
if [ "$STASH_CREATED" = true ]; then
    git stash pop 2>/dev/null && echo "  ✓ 已恢复暂存的更改" || echo "  ⚠ 恢复暂存时有冲突，请手动解决"
fi

echo ""
echo "============================================"
echo "  ✓ Feature 分支就绪: $BRANCH_NAME"
echo "  现在可以开始开发了！"
echo "============================================"
