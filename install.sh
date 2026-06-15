#!/usr/bin/env sh
# install.sh — install the konsylium skill into Claude Code (CLI) and Codex (CLI).
# Both tools read the same Agent Skills standard (SKILL.md + references/ + assets/).
#
# The Claude / Cowork DESKTOP app does NOT read these dirs — import dist/konsylium-<lang>.zip
# via Customize -> Skills -> "+" -> Create skill (see README).
#
# This script writes ONLY to (no network, no telemetry):
#   ${CLAUDE_HOME:-~/.claude}/skills/<id>     and     ${CODEX_HOME:-~/.codex}/skills/<id>
# An existing install at those paths is backed up (never silently overwritten).
set -eu

LANG_VARIANT="en"
SKILL_ID="konsylium"
DO_CLAUDE=1
DO_CODEX=1
DRY=0

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

usage() {
  cat <<EOF
konsylium installer — Claude Code + Codex

Usage: sh install.sh [options]
  --lang en|pl     language edition (default: en)
  --id NAME        command / dir name (default: konsylium)
  --claude-only    install only into Claude Code
  --codex-only     install only into Codex
  --dry-run        show exactly what would happen; write nothing
  -h, --help       this help

Targets (override via env): \${CLAUDE_HOME:-~/.claude}/skills  and  \${CODEX_HOME:-~/.codex}/skills
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --lang) LANG_VARIANT="$2"; shift 2 ;;
    --id) SKILL_ID="$2"; shift 2 ;;
    --claude-only) DO_CODEX=0; shift ;;
    --codex-only) DO_CLAUDE=0; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

case "$LANG_VARIANT" in
  en) SRC="$REPO_DIR/skills/konsylium" ;;
  pl) SRC="$REPO_DIR/skills/konsylium-pl" ;;
  *) echo "Unknown --lang: $LANG_VARIANT (use en|pl)" >&2; exit 1 ;;
esac
[ -f "$SRC/SKILL.md" ] || { echo "Source not found: $SRC/SKILL.md" >&2; exit 1; }

install_to() {
  dest="$1/skills/$SKILL_ID"; tool="$2"
  echo "$tool: $dest"
  if [ -e "$dest" ]; then
    bak="$dest.bak.$(date +%Y%m%d-%H%M%S)"
    echo "  existing install found -> backing up to: $bak"
    [ "$DRY" = 1 ] || mv "$dest" "$bak"
  fi
  if [ "$DRY" = 1 ]; then
    echo "  would write: SKILL.md, references/*.md, assets/*.md (name normalized to '$SKILL_ID')"
    return
  fi
  mkdir -p "$dest"
  cp "$SRC/SKILL.md" "$dest/SKILL.md"
  if [ -d "$SRC/references" ]; then mkdir -p "$dest/references"; cp "$SRC"/references/*.md "$dest/references/" 2>/dev/null || true; fi
  if [ -d "$SRC/assets" ]; then mkdir -p "$dest/assets"; cp "$SRC"/assets/*.md "$dest/assets/" 2>/dev/null || true; fi
  tmp=$(mktemp); sed "s/^name: .*/name: $SKILL_ID/" "$dest/SKILL.md" > "$tmp" && mv "$tmp" "$dest/SKILL.md"
  echo "  installed."
}

[ "$DRY" = 1 ] && echo "[DRY-RUN] no files will be written."
echo "Installing '$SKILL_ID' (lang: $LANG_VARIANT) from: $SRC"
[ "$DO_CLAUDE" = 1 ] && install_to "${CLAUDE_HOME:-$HOME/.claude}" "Claude Code"
[ "$DO_CODEX" = 1 ]  && install_to "${CODEX_HOME:-$HOME/.codex}"  "Codex"

echo ""
echo "Done. Invoke with: /$SKILL_ID"
echo "Claude Code: loads automatically (restart the session if the skills dir did not exist before)."
printf 'Codex: new session; activates by description or explicitly: $%s\n' "$SKILL_ID"
