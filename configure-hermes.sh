#!/usr/bin/env bash
# Wire this repo's skills into Hermes. Idempotent. Safe to re-run on any machine.
#
# Method: ONE symlink. The whole skills/ tree is mounted at
#   ~/.hermes/external-skills/opencode -> <repo>/skills
# and that mount DIRECTORY is registered as an external skill dir. Add, edit or delete
# a skill here and the next Hermes session sees it — nothing to re-run, and no
# per-skill list anywhere in this script or in config.yaml.
#
# Why the mount dir instead of ~/.hermes/skills/opencode -> <repo>/skills?
#   Hermes resolves duplicate names by tier: project > local > create_dir > external.
#   A link inside ~/.hermes/skills/ lands in the SAME tier as the bundled skills, and
#   the 8 names present in both trees (systematic-debugging, test-driven-development,
#   requesting-code-review, xlsx, docx, pdf, google-workspace, computer-use) then lose
#   their bare name: Hermes lists "opencode/<name>" and "productivity/<name>" and the
#   plain /name stops resolving. Mounted at the external tier, Hermes' own copy keeps
#   the bare name and this tree's duplicates are shadowed with an info log.
#
# Consequences: these skills are read-only to Hermes (skill_manage refuses external
# writes — edit in the repo, which is git-tracked), and their category shows as
# "opencode".
#
# Lazy by default: every skill is LISTED at session start (name + description), and a
# body is read only when invoked. Eager loading happens only for skills.auto_load
# below. The listing for ~127 repo skills costs roughly 9k tokens per session on top
# of Hermes' own.
#
# Usage:
#   ./configure-hermes.sh
#   HERMES_PROFILE=mybot ./configure-hermes.sh     # one bot/profile only
#   HERMES_SKILLS_DIR=/path ./configure-hermes.sh  # non-default Hermes home
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$REPO_DIR/skills"
SKILLS_DIR="${HERMES_SKILLS_DIR:-$HOME/.hermes/skills}"
MOUNT_ROOT="${HERMES_MOUNT_ROOT:-$(dirname "$SKILLS_DIR")/external-skills}"
MOUNT_LINK="$MOUNT_ROOT/opencode"

hermes_cmd() {
  if [[ -n "${HERMES_PROFILE:-}" ]]; then
    hermes -p "$HERMES_PROFILE" "$@"
  else
    hermes "$@"
  fi
}

[[ -d "$SOURCE_ROOT" ]] || { echo "error: $SOURCE_ROOT not found" >&2; exit 1; }
command -v hermes >/dev/null 2>&1 || { echo "error: hermes not on PATH" >&2; exit 1; }

# Every skill dir in this repo — the only list here, and it is derived, never stored.
# No depth limit: nested layouts (skills/<group>/<name>/SKILL.md) count too.
repo_skill_names() {
  find "$SOURCE_ROOT" -name SKILL.md -printf '%h\n' | xargs -rn1 basename | sort -u
}

# ---------------------------------------------------------------------------
# 1. Mount the whole tree with one symlink.
# ---------------------------------------------------------------------------
mount_tree() {
  mkdir -p "$MOUNT_ROOT"
  if [[ -L "$MOUNT_LINK" && "$(readlink -f "$MOUNT_LINK")" == "$(readlink -f "$SOURCE_ROOT")" ]]; then
    echo "mount ok: $MOUNT_LINK -> $SOURCE_ROOT"
  else
    [[ -e "$MOUNT_LINK" || -L "$MOUNT_LINK" ]] && rm -f "$MOUNT_LINK"
    ln -s "$SOURCE_ROOT" "$MOUNT_LINK"
    echo "mounted $MOUNT_LINK -> $SOURCE_ROOT"
  fi
}

mount_tree

# ---------------------------------------------------------------------------
# 2. Register the mount directory (not the skills) as an external skill dir.
#    Merged, not replaced; a run where it is already listed changes nothing.
# ---------------------------------------------------------------------------
register_mount_root() {
  local current changed merged
  current="$(hermes_cmd config get skills.external_dirs 2>/dev/null || true)"

  # `config get` prints "[]" or a YAML-ish "- /path" list; accept both, plus JSON.
  # Prints "<changed> <json>" so the caller knows whether a write is needed.
  read -r changed merged < <(printf '%s\n' "$current" | WANT="$MOUNT_ROOT" python3 -c '
import json, os, sys

entries = []
for line in sys.stdin:
    line = line.strip()
    if not line or line == "[]":
        continue
    if line.startswith("- "):
        entries.append(line[2:].strip().strip("\x27\""))
    elif line.startswith("["):
        try:
            entries.extend(json.loads(line))
        except json.JSONDecodeError:
            pass
    else:
        entries.append(line)

want = os.environ["WANT"]
known = {os.path.realpath(os.path.expanduser(str(e))) for e in entries}
changed = "0"
if os.path.realpath(want) not in known:
    entries.append(want)
    changed = "1"
print(changed, json.dumps([str(e) for e in entries], separators=(",", ":")))
')

  if [[ "$changed" == "1" ]]; then
    hermes_cmd config set skills.external_dirs "$merged" >/dev/null   # never hand-edit config.yaml
    echo "added $MOUNT_ROOT to skills.external_dirs"
  else
    echo "skills.external_dirs already includes $MOUNT_ROOT"
  fi
}

register_mount_root

# ---------------------------------------------------------------------------
# 3. Clean up per-skill links left by older versions of this script.
# ---------------------------------------------------------------------------
migrate_old_links() {
  local stale_dir="$SKILLS_DIR/imported" link target removed=0 repo_real
  [[ -d "$stale_dir" ]] || return 0
  repo_real="$(readlink -f "$SOURCE_ROOT")"
  for link in "$stale_dir"/*; do
    [[ -L "$link" ]] || continue
    target="$(readlink -f "$link" 2>/dev/null || true)"
    case "$target" in
      "$repo_real"/*) rm -f "$link"; removed=$((removed + 1)) ;;
    esac
  done
  rmdir "$stale_dir" 2>/dev/null || true
  [[ $removed -gt 0 ]] && echo "removed $removed stale per-skill symlink(s) from $stale_dir"
  return 0
}

migrate_old_links

# ---------------------------------------------------------------------------
# 4. Always-on skills (skills.auto_load) — deliberately explicit, NOT an import list.
#    The whole tree is mounted above; this only pins which skills sit in the system
#    prompt verbatim from the first token instead of loading on demand, on every
#    surface (CLI, TUI, gateway/bots, cron, API), resolved once per agent lifecycle so
#    a model switch or compression never re-injects. "Always on" cannot be inferred
#    from a directory, so it stays named here.
#
#    Cost: ~9KB every session. Caveman also sets how the agent TALKS, so a bot on
#    this profile answers in caveman too — HERMES_PROFILE=mybot decides for one bot.
#    caveman-commit is deliberately NOT pinned: it is mounted with the rest of the tree
#    and loads on demand at commit time, so it costs nothing until used.
# ---------------------------------------------------------------------------
AUTO_LOAD=(ponytail caveman)

configure_auto_load() {
  local want_json want_flat have
  want_json="$(printf '%s\n' "${AUTO_LOAD[@]}" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')"
  want_flat="$(printf '%s ' "${AUTO_LOAD[@]}" | sed 's/ *$//')"
  have="$(hermes_cmd config get skills.auto_load 2>/dev/null | sed 's/^ *- *//' | grep -v '^\[\]$' | tr '\n' ' ' | sed 's/ *$//')"
  if [[ "$have" == "$want_flat" ]]; then
    echo "skills.auto_load already = $have"
    return 0
  fi
  hermes_cmd config set skills.auto_load "$want_json" >/dev/null
  echo "skills.auto_load = $(hermes_cmd config get skills.auto_load 2>/dev/null | sed 's/^ *- *//' | tr '\n' ' ')"
}

configure_auto_load

# ---------------------------------------------------------------------------
# 5. Fail loudly if the wiring did not take.
# ---------------------------------------------------------------------------
verify() {
  local failed=0 listed rows repo_count name
  repo_count="$(repo_skill_names | wc -l)"

  if [[ "$(readlink -f "$MOUNT_LINK" 2>/dev/null || true)" != "$(readlink -f "$SOURCE_ROOT")" ]]; then
    echo "verify: $MOUNT_LINK does not point at $SOURCE_ROOT" >&2
    failed=1
  fi

  hermes_cmd config get skills.external_dirs 2>/dev/null | grep -qF "$MOUNT_ROOT" \
    || { echo "verify: $MOUNT_ROOT missing from skills.external_dirs" >&2; failed=1; }

  listed="$(hermes_cmd skills list 2>/dev/null)"

  # Row count, not name matching: the CLI truncates long names with an ellipsis.
  rows="$(grep -c '^│' <<<"$listed" || true)"
  if [[ "$rows" -lt "$repo_count" ]]; then
    echo "verify: only $rows catalog rows for $repo_count repo skills" >&2
    failed=1
  fi

  # A name field containing "/" means a same-tier collision broke the bare name
  # ("opencode/foo" + "productivity/foo") — what the external mount is there to avoid.
  if grep -qE '^│ [a-z0-9._-]+/' <<<"$listed"; then
    echo "verify: catalog has qualified (collided) skill names:" >&2
    grep -oE '^│ [a-z0-9._/-]+/' <<<"$listed" | sort -u >&2
    failed=1
  fi

  for name in "${AUTO_LOAD[@]}"; do
    hermes_cmd config get skills.auto_load 2>/dev/null | sed 's/^ *- *//' | grep -qx "$name" \
      || { echo "verify: $name missing from skills.auto_load" >&2; failed=1; }
  done

  if [[ $failed -eq 0 ]]; then
    echo "verify: ok — $repo_count repo skills mounted at $MOUNT_LINK (one symlink, no per-skill list)"
    echo "         $(tail -1 <<<"$listed")"
  else
    echo "verify: FAILED" >&2
    exit 1
  fi
}

verify
