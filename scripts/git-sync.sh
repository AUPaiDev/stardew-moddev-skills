#!/bin/bash
# ============================================================
# Git 同步 main 分支最新代码
# ============================================================
# 用法: ./git-sync.sh
# 功能: 拉取 main 最新代码并合并到当前分支
# ============================================================
set -euo pipefail

echo "============================================"
echo "  同步 main 分支最新代码"
echo "============================================"
echo ""

# 查找 git 仓库
GIT_ROOT="$(pwd)"
while [ "$GIT_ROOT" != "/" ]; do
    if [ -d "$GIT_ROOT/.git" ]; then
        break
    fi
    GIT_ROOT="$(dirname "$GIT_ROOT")"
done

if [ ! -d "$GIT_ROOT/.git" ]; then
    echo "✗ 未找到 Git 仓库"
    exit 1
fi

cd "$GIT_ROOT"
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# 确定主分支名
MAIN_BRANCH="main"
if git branch --list master | grep -q "master"; then
    if ! git branch --list main | grep -q "main"; then
        MAIN_BRANCH="master"
    fi
fi

echo "  当前分支: $CURRENT_BRANCH"
echo "  主分支: $MAIN_BRANCH"
echo ""

# 检查是否有远程仓库
if ! git remote -v 2>/dev/null | grep -q "origin"; then
    echo "  ⚠ 没有远程仓库，跳过同步"
    exit 0
fi

# 暂存当前工作
STASH_CREATED=false
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    echo "【1/4】暂存当前更改..."
    git stash push -m "auto-stash before sync"
    STASH_CREATED=true
    echo "  ✓ 已暂存"
else
    echo "【1/4】工作区干净，无需暂存"
fi

# 拉取远程最新
echo "【2/4】拉取远程最新代码..."
git fetch origin

# 更新 main
echo "【3/4】更新 $MAIN_BRANCH..."
git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"
echo "  ✓ $MAIN_BRANCH 已更新"

# 回到工作分支并合并
echo "【4/4】合并到 $CURRENT_BRANCH..."
git checkout "$CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]; then
    if git merge "$MAIN_BRANCH" --no-edit 2>/dev/null; then
        echo "  ✓ 已将 $MAIN_BRANCH 合并到 $CURRENT_BRANCH"
    else
        echo "  ⚠ 合并时有冲突，请手动解决后提交"
    fi
fi

# 恢复暂存
if [ "$STASH_CREATED" = true ]; then
    git stash pop 2>/dev/null && echo "  ✓ 已恢复暂存的更改" || echo "  ⚠ 恢复暂存时有冲突，请手动解决"
fi

echo ""
echo "============================================"
echo "  ✓ 同步完成"
echo "============================================"
