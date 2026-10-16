#!/usr/bin/env bash
# Install Claude Code config from this repo. Idempotent. Safe to re-run on any machine.
# Mirrors configure-crush.sh: one source of truth in this repo, symlinked into place.
#
# Wires up:
#   ~/.claude/skills   -> skills/
#   ~/.claude/commands -> commands/
#   ~/.claude/CLAUDE.md -> AGENTS.md   (global ponytail persona, applies to every project)
#   ponytail hooks (SessionStart, UserPromptSubmit, SubagentStart) registered in
#     ~/.claude/settings.json, so Claude Code enforces the same ruleset as opencode
#   MCP servers (context7, playwright, svelte) at user scope via `claude mcp add`
#
# Ends with verify() -- a partial install used to exit 1 with no explanation and
# silently leave CLAUDE.md and commands/ unlinked.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$CONFIG_DIR"

link() {
  local source="$1" dest="$2"
  if [[ ! -e "$source" ]]; then
    echo "error: $source not found" >&2
    exit 1
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" && "$(readlink "$dest")" == "$source" ]]; then
      echo "already linked: $dest -> $source"
      return
    fi
    echo "backing up existing $dest -> $dest.bak.$(date +%s)"
    mv "$dest" "$dest.bak.$(date +%s)"
  fi
  ln -s "$source" "$dest"
  echo "linked $dest -> $source"
}

link "$REPO_DIR/skills" "$CONFIG_DIR/skills"
link "$REPO_DIR/commands" "$CONFIG_DIR/commands"
link "$REPO_DIR/AGENTS.md" "$CONFIG_DIR/CLAUDE.md"

# Register the three ponytail hooks in settings.json, in place: idempotent,
# preserves every unrelated key, and replaces only our own entries so hooks
# belonging to other tools on the same event survive a re-run.
register_hooks() {
  local settings="$CONFIG_DIR/settings.json"
  [[ -f "$settings" ]] || printf '{\n  "theme": "auto"\n}\n' > "$settings"

  SETTINGS="$settings" HOOKS_DIR="$REPO_DIR/hooks" node -e '
const fs = require("fs");
const path = require("path");

const settingsPath = process.env.SETTINGS;
const scripts = {
  SessionStart: "ponytail-activate.js",
  UserPromptSubmit: "ponytail-mode-tracker.js",
  SubagentStart: "ponytail-subagent.js",
};

let settings = {};
try {
  const raw = fs.readFileSync(settingsPath, "utf8").replace(/^\uFEFF/, "");
  const parsed = JSON.parse(raw);
  if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) settings = parsed;
} catch (e) { /* missing or invalid: rewrite from {} */ }

settings.hooks = settings.hooks && typeof settings.hooks === "object" ? settings.hooks : {};

const isPonytail = (h) => String((h && h.command) || "").includes("hooks/ponytail-");

for (const [event, script] of Object.entries(scripts)) {
  const groups = (settings.hooks[event] || []).filter((g) => !(g.hooks || []).some(isPonytail));
  groups.push({
    hooks: [{
      type: "command",
      command: "node " + JSON.stringify(path.join(process.env.HOOKS_DIR, script)),
    }],
  });
  settings.hooks[event] = groups;
}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + "\n", "utf8");
'
  echo "registered 3 ponytail hooks in $settings"
}

register_hooks

if command -v claude >/dev/null 2>&1; then
  add_mcp_http() {
    local name="$1" url="$2"
    if claude mcp get "$name" >/dev/null 2>&1; then
      echo "mcp already registered: $name"
    else
      claude mcp add -s user --transport http "$name" "$url"
    fi
  }
  add_mcp_stdio() {
    local name="$1"; shift
    if claude mcp get "$name" >/dev/null 2>&1; then
      echo "mcp already registered: $name"
    else
      claude mcp add -s user "$name" -- "$@"
    fi
  }

  add_mcp_http context7 "https://mcp.context7.com/mcp"
  add_mcp_stdio playwright npx @playwright/mcp@latest
  add_mcp_stdio svelte npx -y @sveltejs/mcp
  # disabled: prompts Wix OAuth on every start; re-enable if working on Wix apps
  # add_mcp_http wix-mcp-remote "https://mcp.wix.com/mcp"
else
  echo "warning: claude CLI not found, skipping MCP registration" >&2
fi

# Fail loudly, and say what is missing, if any of the above did not take.
verify() {
  local failed=0 dest
  for dest in "$CONFIG_DIR/skills" "$CONFIG_DIR/commands" "$CONFIG_DIR/CLAUDE.md"; do
    if [[ ! -e "$dest" ]]; then
      echo "verify: missing $dest" >&2
      failed=1
    fi
  done

  if SETTINGS="$CONFIG_DIR/settings.json" node -e '
const fs = require("fs");
const need = ["ponytail-activate.js", "ponytail-mode-tracker.js", "ponytail-subagent.js"];
let settings = {};
try {
  settings = JSON.parse(fs.readFileSync(process.env.SETTINGS, "utf8").replace(/^\uFEFF/, ""));
} catch (e) { process.exit(1); }
const all = Object.values(settings.hooks || {}).flat().flatMap((g) => g.hooks || []);
process.exit(need.every((f) => all.some((h) => String((h && h.command) || "").includes(f))) ? 0 : 1);
'; then
    :
  else
    echo "verify: ponytail hooks missing from $CONFIG_DIR/settings.json" >&2
    failed=1
  fi

  if [[ $failed -eq 0 ]]; then
    echo "verify: ok"
  else
    echo "verify: FAILED" >&2
    exit 1
  fi
}

verify

