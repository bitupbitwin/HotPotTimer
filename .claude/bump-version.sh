#!/usr/bin/env bash
# 每次 git commit 前自动升级 pubspec.yaml 的版本号（patch +1，build +1）。
# 由 .claude/settings.json 的 PreToolUse 钩子调用。
set -euo pipefail

input=$(cat 2>/dev/null || true)

# 跳过 --amend（改写历史时不应再升版本）
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
case "$cmd" in
  *--amend*) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-/home/user/hotpot}" 2>/dev/null || exit 0
pubspec="pubspec.yaml"
[ -f "$pubspec" ] || exit 0

line=$(grep -E '^version: ' "$pubspec" | head -1)
ver=${line#version: }          # 1.0.0+1
name=${ver%%+*}                # 1.0.0
build=${ver#*+}                # 1
[ "$build" = "$ver" ] && build=0   # 没有 +build 时兜底

IFS='.' read -r maj min pat <<< "$name"
pat=$((pat + 1))
build=$((build + 1))
newver="$maj.$min.$pat+$build"

sed -i "s/^version: .*/version: $newver/" "$pubspec"
git add "$pubspec" 2>/dev/null || true

printf '{"systemMessage": "版本号已自动升级为 %s"}\n' "$newver"
