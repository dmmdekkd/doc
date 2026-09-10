#!/usr/bin/env bash
# =============================================================================
# jumpbyte-bot Skill 一键安装脚本
# 将项目的 SKILL.md（权威源 .trae/skills/jumpbyte-bot/）复制到各 IDE / AI Agent
# 的 skills 目录，让 AI 能立即理解本项目的架构、协议、算法与文档维护方式。
#
# 用法：
#   ./scripts/install-skill.sh              # 自动检测并安装到当前环境（默认全装到可识别的 IDE）
#   ./scripts/install-skill.sh --all        # 安装到全部支持的目标
#   ./scripts/install-skill.sh --ide=trae   # 只安装指定 IDE（逗号可多个）
#   ./scripts/install-skill.sh --list       # 列出支持的目标
#   ./scripts/install-skill.sh --ide=trae --force
#
# 支持目标：trae, cursor, claude, cline, continue, github-copilot
# =============================================================================
set -euo pipefail

SKILL_NAME="jumpbyte-bot"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"          # 仓库根（ccmd/ 上级）
SRC="$ROOT/.trae/skills/$SKILL_NAME/SKILL.md"

# 各 IDE / Agent 的目标目录（相对于仓库根 ROOT）
declare -A TARGETS=(
  [trae]=".trae/skills/$SKILL_NAME"
  [cursor]=".cursor/skills/$SKILL_NAME"
  [claude]=".claude/skills/$SKILL_NAME"
  [cline]=".cline/skills/$SKILL_NAME"
  [continue]=".continue/skills/$SKILL_NAME"
  [github-copilot]=".github/skills/$SKILL_NAME"
)
ORDER=(trae cursor claude cline continue github-copilot)

MODE="auto"
FORCE=0

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

[[ $# -gt 0 ]] && [[ "$1" == "-h" || "$1" == "--help" ]] && usage

for arg in "$@"; do
  case "$arg" in
    --all) MODE="all" ;;
    --list) MODE="list" ;;
    --force) FORCE=1 ;;
    --ide=*) MODE="ide"; IDE_ARGS="${arg#*=}" ;;
    *) echo "[warn] 忽略未知参数: $arg" ;;
  esac
done

if [[ ! -f "$SRC" ]]; then
  echo "[error] 找不到 Skill 权威源: $SRC"
  exit 1
fi

if [[ "$MODE" = "list" ]]; then
  echo "支持的目标："
  for k in "${ORDER[@]}"; do
    printf "  %-18s → %s\n" "$k" "${TARGETS[$k]}"
  done
  echo "权威源: $SRC"
  exit 0
fi

# 组装要安装的目标列表
selected=()
if [[ "$MODE" = "ide" ]]; then
  for k in ${IDE_ARGS//,/ }; do
    [[ -n "$k" && -n "${TARGETS[$k]:-}" ]] && selected+=("$k") || echo "[warn] 未知目标: $k"
  done
elif [[ "$MODE" = "all" ]]; then
  selected=("${ORDER[@]}")
else
  # auto：尽量自动探测当前环境（HOME 下的 Trae/Cursor 全局 skills 也认）
  auto=()
  for k in "${ORDER[@]}"; do
    # 仓库内的技能目录存在（说明对应 IDE 在用本仓库）→ 纳入
    [[ "${TARGETS[$k]}" = .trae/* ]] && auto+=("$k") && continue
    if [[ -d "$ROOT/${TARGETS[$k]}" ]]; then auto+=("$k"); fi
  done
  # 全局 skills 目录探测（不在仓库内，复制到用户全局，供所有项目复用）
  for g in "$HOME/.trae/skills" "$HOME/.cursor/skills" "$HOME/.claude/skills"; do
    [[ -d "$g" ]] && auto+=("$(basename "$g")")
  done
  selected=("${auto[@]:-trae}")
  # 去重
  selected=($(echo "${selected[@]}" | tr ' ' '\n' | sort -u))
fi

[[ ${#selected[@]} -eq 0 ]] && { echo "[error] 未选择任何目标，使用 --all 或 --ide=xxx"; exit 1; }

installed=0
for k in "${selected[@]}"; do
  rel="${TARGETS[$k]}"
  # 全局目录处理
  if [[ "$k" = *trae && -d "$HOME/.trae/skills" && "$rel" != .trae/* ]]; then
    dst="$HOME/.trae/skills/$SKILL_NAME"
  elif [[ "$k" = *cursor && -d "$HOME/.cursor/skills" ]]; then
    dst="$HOME/.cursor/skills/$SKILL_NAME"
  elif [[ "$k" = *claude && -d "$HOME/.claude/skills" ]]; then
    dst="$HOME/.claude/skills/$SKILL_NAME"
  else
    dst="$ROOT/$rel"
  fi
  # 目标与权威源相同（如 trae 仓库内目录即权威源）→ 跳过
  if [[ "$dst/SKILL.md" -ef "$SRC" ]]; then
    echo "[ok]   $k 权威源已就位（$dst/SKILL.md），无需复制"
    installed=$((installed+1))
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  mkdir -p "$dst"
  if [[ -f "$dst/SKILL.md" && "$FORCE" -eq 0 ]] && ! diff -q "$SRC" "$dst/SKILL.md" >/dev/null 2>&1; then
    echo "[skip] $k 已存在且与源不同，使用 --force 覆盖: $dst"
    continue
  fi
  cp -f "$SRC" "$dst/SKILL.md"
  echo "[ok]   $k ← $dst/SKILL.md"
  installed=$((installed+1))
done

echo "完成，共安装 $installed 个目标。"
echo "提示：修改权威源 .trae/skills/$SKILL_NAME/SKILL.md 后，重新运行本脚本即可同步到各 IDE。"