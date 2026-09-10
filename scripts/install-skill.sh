#!/usr/bin/env bash
# =============================================================================
# jumpbyte-bot Skill 一键安装脚本
# 将 SKILL.md（项目 AI 知识包）安装到各 IDE / AI Agent 的 skills 目录，
# 让 AI 打开项目即可理解架构、协议、算法与文档维护方式。
#
# 支持两种运行模式：
#   [本地模式] 已克隆仓库：
#     ./scripts/install-skill.sh --all
#   [远程一键模式] 无需克隆仓库（Linux / macOS / Windows Git-Bash / WSL）：
#     curl -fsSL https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.sh | bash -s -- --all
#     bash <(curl -fsSL https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.sh) --all
#
#   Windows 原生 PowerShell 请用 install-skill.ps1（同目录 / 同远程 URL）：
#     irm https://raw.githubusercontent.com/dmmdekkd/doc/main/scripts/install-skill.ps1 | iex
#
# 用法：
#   install-skill.sh                # 自动检测并安装
#   install-skill.sh --all          # 安装到全部支持的目标
#   install-skill.sh --ide=trae,cursor,claude   # 只安装指定 IDE（逗号分隔）
#   install-skill.sh --list         # 列出支持的目标与安装位置
#   install-skill.sh --force        # 强制覆盖已存在的副本
#
# 支持目标：trae, cursor, claude, cline, continue, github-copilot
# 环境变量：SKILL_RAW_URL 覆盖远程 SKILL.md 下载地址（国内可指向镜像/加速源）
# =============================================================================
set -euo pipefail

SKILL_NAME="jumpbyte-bot"
REPO="dmmdekkd/doc"
BRANCH="main"
DEFAULT_RAW_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/.trae/skills/$SKILL_NAME/SKILL.md"
RAW_URL="${SKILL_RAW_URL:-$DEFAULT_RAW_URL}"

MODE="auto"
FORCE=0

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
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

# ---------------------------------------------------------------------------
# 0. 定位权威源：优先本地仓库，否则远程下载（远程一键模式）
# ---------------------------------------------------------------------------
LOCAL_MODE=0
SRC=""
ROOT=""

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  CAND="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd || true)"
  if [[ -n "$CAND" && -f "$CAND/.trae/skills/$SKILL_NAME/SKILL.md" ]]; then
    ROOT="$CAND"; LOCAL_MODE=1
  fi
fi
if [[ "$LOCAL_MODE" -eq 0 && -f ".trae/skills/$SKILL_NAME/SKILL.md" ]]; then
  ROOT="$(pwd)"; LOCAL_MODE=1
fi

if [[ "$LOCAL_MODE" -eq 1 ]]; then
  SRC="$ROOT/.trae/skills/$SKILL_NAME/SKILL.md"
  echo "[info] 本地模式：使用仓库权威源 $SRC"
else
  TMPD="$(mktemp -d 2>/dev/null || echo "${TMPDIR:-/tmp}/skill.$$")"
  mkdir -p "$TMPD"
  trap 'rm -rf "$TMPD"' EXIT
  SRC="$TMPD/SKILL.md"
  echo "[info] 远程模式：下载 SKILL.md ← $RAW_URL"
  if ! curl -fsSL --connect-timeout 15 "$RAW_URL" -o "$SRC"; then
    echo "[error] 远程下载失败: $RAW_URL"
    echo "        可设置 SKILL_RAW_URL 指定镜像/加速地址后重试，例如："
    echo "        SKILL_RAW_URL=https://ghproxy.com/$RAW_URL bash <(curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install-skill.sh) --all"
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# 1. 目标目录
#    本地模式：仓库相对目录（.trae/.cursor/...）
#    远程模式：用户全局目录（$HOME/.trae/...），对所有项目生效
# ---------------------------------------------------------------------------
resolve_dst() {
  local k="$1"
  if [[ "$LOCAL_MODE" -eq 1 ]]; then
    case "$k" in
      trae)            echo "$ROOT/.trae/skills/$SKILL_NAME" ;;
      cursor)          echo "$ROOT/.cursor/skills/$SKILL_NAME" ;;
      claude)          echo "$ROOT/.claude/skills/$SKILL_NAME" ;;
      cline)           echo "$ROOT/.cline/skills/$SKILL_NAME" ;;
      continue)        echo "$ROOT/.continue/skills/$SKILL_NAME" ;;
      github-copilot)  echo "$ROOT/.github/skills/$SKILL_NAME" ;;
    esac
  else
    case "$k" in
      trae)            echo "$HOME/.trae/skills/$SKILL_NAME" ;;
      cursor)          echo "$HOME/.cursor/skills/$SKILL_NAME" ;;
      claude)          echo "$HOME/.claude/skills/$SKILL_NAME" ;;
      cline)           echo "$HOME/.cline/skills/$SKILL_NAME" ;;
      continue)        echo "$HOME/.continue/skills/$SKILL_NAME" ;;
      github-copilot)  echo "$HOME/.github/skills/$SKILL_NAME" ;;
    esac
  fi
}

ORDER=(trae cursor claude cline continue github-copilot)

if [[ "$MODE" = "list" ]]; then
  echo "支持的目标："
  for k in "${ORDER[@]}"; do
    printf "  %-18s → %s\n" "$k" "$(resolve_dst "$k")"
  done
  echo "权威源: $SRC"
  exit 0
fi

# ---------------------------------------------------------------------------
# 2. 组装要安装的目标列表
# ---------------------------------------------------------------------------
selected=()
if [[ "$MODE" = "ide" ]]; then
  for k in ${IDE_ARGS//,/ }; do
    [[ -n "$k" ]] && { case " ${ORDER[*]} " in *" $k "*) selected+=("$k");; *) echo "[warn] 未知目标: $k";; esac; }
  done
elif [[ "$MODE" = "all" ]]; then
  selected=("${ORDER[@]}")
else
  # auto：本地模式探测仓库内已存在的 skills 目录（无则默认 trae）；远程模式全装到用户全局
  if [[ "$LOCAL_MODE" -eq 1 ]]; then
    auto=()
    for k in "${ORDER[@]}"; do
      [[ -d "$(resolve_dst "$k")" ]] && auto+=("$k")
    done
    [[ ${#auto[@]} -eq 0 ]] && auto=(trae)
  else
    auto=("${ORDER[@]}")
  fi
  selected=("${auto[@]}")
fi

[[ ${#selected[@]} -eq 0 ]] && { echo "[error] 未选择任何目标，使用 --all 或 --ide=xxx"; exit 1; }

# ---------------------------------------------------------------------------
# 3. 执行安装
# ---------------------------------------------------------------------------
installed=0
for k in "${selected[@]}"; do
  dst="$(resolve_dst "$k")"

  # 目标与权威源相同（本地模式下 trae 目录即权威源）→ 跳过
  if [[ "$LOCAL_MODE" -eq 1 && "$dst/SKILL.md" -ef "$SRC" ]]; then
    echo "[ok]   $k 权威源已就位（$dst/SKILL.md），无需复制"
    installed=$((installed+1))
    continue
  fi

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
if [[ "$LOCAL_MODE" -eq 1 ]]; then
  echo "提示：修改权威源 .trae/skills/$SKILL_NAME/SKILL.md 后，重新运行本脚本即可同步到各 IDE。"
else
  echo "提示：远程模式下已安装到用户全局目录，对所有项目生效。更新：重跑同一条远程命令即可。"
fi