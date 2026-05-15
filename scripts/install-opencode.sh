#!/usr/bin/env bash
#
# install-opencode.sh — install Cog Focus skills + instructions for opencode.
#
# Run this from the root of your own project (not from the cog-focus repo).
# It downloads three skills into .opencode/skills/, drops a cog-focus/
# instructions file, and patches opencode.json so opencode loads them.
#
# Usage:
#   bash scripts/install-opencode.sh
#   curl -fsSL https://raw.githubusercontent.com/sapristi/cog-focus/main/scripts/install-opencode.sh | bash
#
# Pin to a tag/branch via COG_FOCUS_REF, e.g. COG_FOCUS_REF=v0.2.0 bash ...

set -euo pipefail

REF="${COG_FOCUS_REF:-main}"
BASE_URL="https://raw.githubusercontent.com/sapristi/cog-focus/${REF}"

SKILLS=(cog-init reflect housekeeping)
INSTRUCTIONS_REL="cog-focus/instructions.md"
OPENCODE_JSON="opencode.json"
OPENCODE_JSONC="opencode.jsonc"

err() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || err "missing required command: $1"
}

require curl

# --- step 1: download skills ----------------------------------------------
printf '[1/4] downloading skills...\n'
for skill in "${SKILLS[@]}"; do
  dest_dir=".opencode/skills/${skill}"
  dest_file="${dest_dir}/SKILL.md"
  src_url="${BASE_URL}/skills/${skill}/SKILL.md"
  mkdir -p "${dest_dir}"
  curl --fail --silent --show-error --location "${src_url}" -o "${dest_file}"
  printf '       wrote %s\n' "${dest_file}"
done

# --- step 2: download instructions ----------------------------------------
printf '[2/4] downloading instructions...\n'
mkdir -p "$(dirname "${INSTRUCTIONS_REL}")"
curl --fail --silent --show-error --location \
  "${BASE_URL}/hooks/session-instructions.md" -o "${INSTRUCTIONS_REL}"
printf '       wrote %s\n' "${INSTRUCTIONS_REL}"

# --- step 3: patch opencode.json ------------------------------------------
printf '[3/4] patching %s...\n' "${OPENCODE_JSON}"

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

# --- step 4: summary -------------------------------------------------------
printf '[4/4] done.\n\n'
printf 'Files written/touched:\n'
for skill in "${SKILLS[@]}"; do
  printf '  - .opencode/skills/%s/SKILL.md\n' "${skill}"
done
printf '  - %s\n' "${INSTRUCTIONS_REL}"
printf '  - %s (%s)\n' "${OPENCODE_JSON}" "${patch_action}"
printf '\nNext steps:\n'
printf '  Open this project in opencode; the cog-focus instructions are now active.\n'
printf '  Note: roadmap.md and memory files are not yet scaffolded -- see the\n'
printf '  plugin README for next steps.\n'
