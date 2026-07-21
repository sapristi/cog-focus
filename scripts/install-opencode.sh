#!/usr/bin/env bash
#
# install-opencode.sh — install Cog Focus skills + instructions for opencode.
#
# Run this from the root of your own project (not from the cog-focus repo).
# It downloads three skills into .opencode/skills/, drops a cog-focus/
# instructions file, scaffolds the cog-focus/ template (without overwriting
# user customizations), and patches opencode.json so opencode loads them.
#
# Usage:
#   bash scripts/install-opencode.sh
#   curl -fsSL https://raw.githubusercontent.com/sapristi/cog-focus/main/scripts/install-opencode.sh | bash
#
# Pin to a tag/branch via COG_FOCUS_REF, e.g. COG_FOCUS_REF=v0.2.0 bash ...

set -euo pipefail

REF="${COG_FOCUS_REF:-main}"
BASE_URL="https://raw.githubusercontent.com/sapristi/cog-focus/${REF}"
TEMPLATE_BASE_URL="${BASE_URL}/template/cog-focus"

SKILLS=(cog-init reflect housekeeping)
INSTRUCTIONS_REL="cog-focus/instructions.md"
OPENCODE_JSON="opencode.json"
OPENCODE_JSONC="opencode.jsonc"

# Template files (paths relative to cog-focus/) — never overwrite if already
# present, since the user customizes these (goal, observations).
TEMPLATE_FILES=(
  "config.yaml"
  "roadmap.md"
  "memory/observations.md"
  "memory/patterns.md"
  "memory/reflect-cursor.md"
  "memory/archive/index.md"
)

# Parallel array tracking the action taken for each TEMPLATE_FILES entry.
TEMPLATE_ACTIONS=()

err() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || err "missing required command: $1"
}

require curl

# --- step 1: download skills ----------------------------------------------
printf '[1/5] downloading skills...\n'
for skill in "${SKILLS[@]}"; do
  dest_dir=".opencode/skills/${skill}"
  dest_file="${dest_dir}/SKILL.md"
  src_url="${BASE_URL}/skills/${skill}/SKILL.md"
  mkdir -p "${dest_dir}"
  curl --fail --silent --show-error --location "${src_url}" -o "${dest_file}"
  printf '       wrote %s\n' "${dest_file}"
done

# Patch the reflect SKILL.md: replace the session-source block (Claude Code
# default) with the OpenCode-specific snippet. Keep markers in place so this
# remains idempotent on re-run.
SKILL_FILE=".opencode/skills/reflect/SKILL.md"
SNIPPET_URL="${BASE_URL}/skills/reflect/opencode-session-source.md"
SNIPPET_FILE="$(mktemp)"
curl --fail --silent --show-error --location "${SNIPPET_URL}" -o "${SNIPPET_FILE}"

TMP="$(mktemp "${SKILL_FILE}.XXXXXX")"
awk -v snippet_file="${SNIPPET_FILE}" '
  /<!-- OPENCODE-PATCH:session-source:start -->/ {
    print
    while ((getline line < snippet_file) > 0) print line
    in_block=1
    next
  }
  /<!-- OPENCODE-PATCH:session-source:end -->/ {
    in_block=0
    print
    next
  }
  !in_block { print }
' "${SKILL_FILE}" > "${TMP}"
mv "${TMP}" "${SKILL_FILE}"
rm -f "${SNIPPET_FILE}"

if ! grep -q '<!-- OPENCODE-PATCH:session-source:start -->' "${SKILL_FILE}"; then
  err "reflect SKILL.md is missing the OPENCODE-PATCH marker — install script needs updating to match upstream"
fi
printf '       patched %s (opencode session source)\n' "${SKILL_FILE}"

# --- step 2: download instructions ----------------------------------------
printf '[2/5] downloading instructions...\n'
mkdir -p "$(dirname "${INSTRUCTIONS_REL}")"
curl --fail --silent --show-error --location \
  "${BASE_URL}/hooks/session-instructions.md" -o "${INSTRUCTIONS_REL}"
printf '       wrote %s\n' "${INSTRUCTIONS_REL}"

# --- step 3: scaffold template files (never overwrite) --------------------
printf '[3/5] scaffolding cog-focus/ template...\n'
for rel in "${TEMPLATE_FILES[@]}"; do
  dest="cog-focus/${rel}"
  if [ -e "${dest}" ]; then
    printf '       skipped (exists) %s\n' "${dest}"
    TEMPLATE_ACTIONS+=("skipped (exists)")
    continue
  fi
  mkdir -p "$(dirname "${dest}")"
  curl --fail --silent --show-error --location \
    "${TEMPLATE_BASE_URL}/${rel}" -o "${dest}"
  printf '       created %s\n' "${dest}"
  TEMPLATE_ACTIONS+=("created")
done

# --- step 4: patch opencode.json ------------------------------------------
printf '[4/5] patching %s...\n' "${OPENCODE_JSON}"

if [ ! -f "${OPENCODE_JSON}" ] && [ -f "${OPENCODE_JSONC}" ]; then
  err "found ${OPENCODE_JSONC} but not ${OPENCODE_JSON}. jsonc (with comments) is not supported by this installer. Please convert it to ${OPENCODE_JSON} or add \"${INSTRUCTIONS_REL}\" to its \"instructions\" array manually."
fi

if [ ! -f "${OPENCODE_JSON}" ]; then
  # Create a minimal config.
  printf '{\n  "instructions": ["%s"]\n}\n' "${INSTRUCTIONS_REL}" > "${OPENCODE_JSON}"
  printf '       created %s\n' "${OPENCODE_JSON}"
  patch_action="created"
else
  require jq
  # Decide whether a patch is needed (idempotent).
  if jq -e --arg p "${INSTRUCTIONS_REL}" \
      '(.instructions // []) | index($p)' "${OPENCODE_JSON}" >/dev/null; then
    printf '       %s already lists %s, no change\n' "${OPENCODE_JSON}" "${INSTRUCTIONS_REL}"
    patch_action="unchanged"
  else
    tmp_file="$(mktemp "${OPENCODE_JSON}.XXXXXX")"
    # Append if instructions exists, else add it with the single entry.
    jq --arg p "${INSTRUCTIONS_REL}" \
      'if has("instructions") then .instructions += [$p] else .instructions = [$p] end' \
      "${OPENCODE_JSON}" > "${tmp_file}"
    mv "${tmp_file}" "${OPENCODE_JSON}"
    printf '       updated %s\n' "${OPENCODE_JSON}"
    patch_action="updated"
  fi
fi

# --- step 5: summary -------------------------------------------------------
printf '[5/5] done.\n\n'
printf 'Files written/touched:\n'
for skill in "${SKILLS[@]}"; do
  printf '  - .opencode/skills/%s/SKILL.md\n' "${skill}"
done
printf '  - %s\n' "${INSTRUCTIONS_REL}"
for i in "${!TEMPLATE_FILES[@]}"; do
  printf '  - cog-focus/%s (%s)\n' "${TEMPLATE_FILES[$i]}" "${TEMPLATE_ACTIONS[$i]}"
done
printf '  - %s (%s)\n' "${OPENCODE_JSON}" "${patch_action}"
printf '\nNext steps:\n'
printf '  Open this project in opencode; the cog-focus instructions are now active.\n'
printf '  Run /cog-init to walk through the interactive goal-definition flow\n'
printf '  (defines goal, milestones, and optional settings — steps 4-7 of the skill).\n'
