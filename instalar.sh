#!/usr/bin/env bash
set -euo pipefail

DEST="${1:-$PWD}"
SOURCE_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
RAW_BASE="${FORGE_RAW_BASE:-https://raw.githubusercontent.com/jasanhdz/codex-skill-forge/main}"

if [ ! -f "$SOURCE_DIR/skill/SKILL.md" ]; then
  SOURCE_DIR="$(mktemp -d)"
  trap 'rm -rf "$SOURCE_DIR"' EXIT
  mkdir -p "$SOURCE_DIR/skill/references" "$SOURCE_DIR/skill/scripts" "$SOURCE_DIR/skill/agents"
  curl -fsSL "$RAW_BASE/skill/SKILL.md" -o "$SOURCE_DIR/skill/SKILL.md"
  curl -fsSL "$RAW_BASE/skill/references/planner.md" -o "$SOURCE_DIR/skill/references/planner.md"
  curl -fsSL "$RAW_BASE/skill/references/generator.md" -o "$SOURCE_DIR/skill/references/generator.md"
  curl -fsSL "$RAW_BASE/skill/references/evaluator.md" -o "$SOURCE_DIR/skill/references/evaluator.md"
  curl -fsSL "$RAW_BASE/skill/scripts/forge-run.sh" -o "$SOURCE_DIR/skill/scripts/forge-run.sh"
  curl -fsSL "$RAW_BASE/skill/agents/openai.yaml" -o "$SOURCE_DIR/skill/agents/openai.yaml"
fi

if [ ! -d "$DEST" ]; then
  printf 'La carpeta no existe: %s\n' "$DEST" >&2
  exit 1
fi

install_skill() {
  local base="$1"
  mkdir -p "$base/forge/references" "$base/forge/scripts" "$base/forge/agents"
  cp "$SOURCE_DIR/skill/SKILL.md" "$base/forge/SKILL.md"
  cp "$SOURCE_DIR/skill/references/"*.md "$base/forge/references/"
  cp "$SOURCE_DIR/skill/scripts/forge-run.sh" "$base/forge/scripts/forge-run.sh"
  cp "$SOURCE_DIR/skill/agents/openai.yaml" "$base/forge/agents/openai.yaml"
  chmod +x "$base/forge/scripts/forge-run.sh"
}

install_skill "$DEST/.agents/skills"
install_skill "$DEST/.opencode/skills"

printf 'Instalado en:\n'
printf '  %s\n' "$DEST/.agents/skills/forge"
printf '  %s\n' "$DEST/.opencode/skills/forge"
printf '\nAbre Codex u OpenCode en esa carpeta y usa:\n'
printf '  $forge "tu prompt de producto"\n'
