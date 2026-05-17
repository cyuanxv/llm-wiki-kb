#!/usr/bin/env bash
# kb-starter init script
# Sets up ~/kb/ + links kb-ingest skill into Claude Code.

set -euo pipefail

# macOS ships bash 3.2 which lacks ${VAR,,}. Use this helper instead.
lc() { printf "%s" "$1" | tr '[:upper:]' '[:lower:]'; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$REPO_ROOT/kb-template"
SKILL_SRC="$REPO_ROOT/skills/kb-ingest"

# Colors
if [ -t 1 ]; then
  BOLD="$(tput bold)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  RED="$(tput setaf 1)"
  RESET="$(tput sgr0)"
else
  BOLD="" GREEN="" YELLOW="" RED="" RESET=""
fi

echo
echo "${BOLD}kb-starter init${RESET}"
echo "================="
echo

# ── 1. Pick KB path ─────────────────────────────────────────────
read -r -p "KB 路径 [~/kb]: " KB_PATH
KB_PATH="${KB_PATH:-$HOME/kb}"
KB_PATH="${KB_PATH/#\~/$HOME}"

if [ -d "$KB_PATH" ]; then
  if [ -f "$KB_PATH/SCHEMA.md" ]; then
    echo "${RED}!${RESET} $KB_PATH 已经是一个 kb（有 SCHEMA.md）。"
    echo "  如果你想重建，先 mv 走或 rm -rf。退出。"
    exit 1
  fi
  echo "${YELLOW}!${RESET} $KB_PATH 已存在但不像 kb。继续会把模板文件复制进去（不覆盖已有同名文件）。"
  read -r -p "继续？[y/N] " CONFIRM
  [ "$(lc "$CONFIRM")" = "y" ] || exit 1
fi

mkdir -p "$KB_PATH"

# ── 2. Copy template ───────────────────────────────────────────
echo
echo "${GREEN}→${RESET} 复制模板到 $KB_PATH"

# Use cp -n to avoid overwriting existing files.
# rsync would be cleaner but not always installed.
(
  cd "$TEMPLATE_DIR"
  find . -type d -exec mkdir -p "$KB_PATH/{}" \;
  find . -type f | while read -r f; do
    dest="$KB_PATH/${f#./}"
    if [ -f "$dest" ]; then
      echo "  ${YELLOW}skip${RESET} $f (已存在)"
    else
      cp "$f" "$dest"
      echo "  ${GREEN}copy${RESET} $f"
    fi
  done
)

# .gitkeep files for empty dirs
for d in inbox sources sources/work sources/learning sources/life sources/reference wiki; do
  mkdir -p "$KB_PATH/$d"
  [ -f "$KB_PATH/$d/.gitkeep" ] || touch "$KB_PATH/$d/.gitkeep"
done

# ── 3. git init ───────────────────────────────────────────────
echo
read -r -p "git init in ${KB_PATH}？[Y/n] " GIT_INIT
GIT_INIT="${GIT_INIT:-y}"
if [ "$(lc "$GIT_INIT")" = "y" ]; then
  cd "$KB_PATH"
  if [ -d .git ]; then
    echo "  ${YELLOW}skip${RESET} .git 已存在"
  else
    git init -q -b main 2>/dev/null || git init -q
    git add .
    git -c user.email="kb@local" -c user.name="kb" commit -q -m "init: kb-starter scaffold" || true
    echo "  ${GREEN}✓${RESET} git 初始化 + 第一次 commit"
  fi
fi

# ── 4. Link kb-ingest skill ───────────────────────────────────
echo
SKILL_DIR="$HOME/.claude/skills"
read -r -p "把 kb-ingest skill 链接到 $SKILL_DIR/？[Y/n] " LINK_SKILL
LINK_SKILL="${LINK_SKILL:-y}"
if [ "$(lc "$LINK_SKILL")" = "y" ]; then
  mkdir -p "$SKILL_DIR"
  TARGET="$SKILL_DIR/kb-ingest"
  if [ -e "$TARGET" ]; then
    echo "  ${YELLOW}!${RESET} $TARGET 已存在"
    read -r -p "  覆盖（备份成 .bak）？[y/N] " OVERWRITE
    if [ "$(lc "$OVERWRITE")" = "y" ]; then
      mv "$TARGET" "$TARGET.bak.$(date +%s)"
      ln -s "$SKILL_SRC" "$TARGET"
      echo "  ${GREEN}✓${RESET} 已链接（旧的备份了）"
    else
      echo "  跳过 skill 链接"
    fi
  else
    ln -s "$SKILL_SRC" "$TARGET"
    echo "  ${GREEN}✓${RESET} 链接到 $TARGET → $SKILL_SRC"
  fi
fi

# ── 5. Optional: add git remote ───────────────────────────────
echo
read -r -p "配置 git remote（推到 GitHub / GitLab 等）？[y/N] " ADD_REMOTE
if [ "$(lc "$ADD_REMOTE")" = "y" ]; then
  read -r -p "  remote URL（如 git@github.com:you/my-kb.git）: " REMOTE_URL
  if [ -n "$REMOTE_URL" ]; then
    cd "$KB_PATH"
    git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"
    echo "  ${GREEN}✓${RESET} remote 已配。第一次 push：cd $KB_PATH && git push -u origin main"
  fi
fi

# ── Done ──────────────────────────────────────────────────────
echo
echo "${BOLD}${GREEN}✓ 全部完成${RESET}"
echo
echo "下一步："
echo "  1. 把一份资料拖进 $KB_PATH/inbox/"
echo "  2. 打开 Claude Code（任意目录）"
echo "  3. 跟 Claude 说 \"ingest 一下\""
echo
echo "可选："
echo "  - 装 Obsidian → 开 vault 指向 $KB_PATH → 看 obsidian-setup.md"
echo "  - 读 DESIGN.md 理解 5 个核心理念"
echo "  - 读 EXAMPLE.md 看一次完整 walkthrough"
echo
