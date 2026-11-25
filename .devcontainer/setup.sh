#!/usr/bin/env bash
# Points Claude Code at OpenRouter with the student's key. Runs on create and on every start.
# The key comes from the Codespaces secret OPENROUTER_API_KEY (never from this repo).
# One fixed model setup for everyone: the OpenRouter preset below (set up in the AI Shift account). Safe to run again.
set -u

MODEL="@preset/the-ai-shift"
# Pasted keys often carry a stray space or line break; strip all white space.
KEY="$(printf '%s' "${OPENROUTER_API_KEY:-}" | tr -d '[:space:]')"
WORKSPACE="${WORKSPACE_DIR:-$PWD}"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

if [ -z "$KEY" ]; then
  echo "SETUP PROBLEM: no hackathon key found. Open START-HERE.md and follow 'Add your key'."
  exit 0
fi
case "$KEY" in
  sk-or-*) ;;
  *) echo "SETUP PROBLEM: the key does not start with sk-or-. Copy it again from your welcome email."; exit 0 ;;
esac

mkdir -p "$CONFIG_DIR"
# Key and model go through the environment, not the command line, so they never show in process lists.
HK_KEY="$KEY" HK_MODEL="$MODEL" HK_WS="$WORKSPACE" HK_CFG="$CONFIG_DIR" HK_HOME="$HOME" node -e '
const fs = require("fs"), path = require("path");
const e = process.env;
const settingsFile = path.join(e.HK_CFG, "settings.json");
let s = {};
try { s = JSON.parse(fs.readFileSync(settingsFile, "utf8")); } catch (_) {}
s.env = Object.assign(s.env || {}, {
  ANTHROPIC_BASE_URL: "https://openrouter.ai/api",
  ANTHROPIC_AUTH_TOKEN: e.HK_KEY,
  ANTHROPIC_API_KEY: "",
  ANTHROPIC_DEFAULT_OPUS_MODEL: e.HK_MODEL,
  ANTHROPIC_DEFAULT_SONNET_MODEL: e.HK_MODEL,
  ANTHROPIC_DEFAULT_HAIKU_MODEL: e.HK_MODEL,
  CLAUDE_CODE_SUBAGENT_MODEL: e.HK_MODEL,
  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: "1",
  CLAUDE_CODE_MAX_OUTPUT_TOKENS: "32000",
  ENABLE_TOOL_SEARCH: "false",
  // The model has a 1M window; compact at 200K so each request stays small and cheap (pilot average was 63-88K).
  CLAUDE_CODE_AUTO_COMPACT_WINDOW: "200000"
});
s.model = e.HK_MODEL;
// No question boxes for first-time students: edits are accepted and the normal tools are pre-allowed.
// (Auto mode was removed 24 Nov: its safety check does not work through the gateway and then asks hard questions.)
// The deny rules below still apply.
s.permissions = Object.assign(s.permissions || {}, { defaultMode: "acceptEdits" });
const allow = ["Bash", "Read(//tmp/**)", "Edit(//tmp/**)", "Write(//tmp/**)", "WebFetch", "WebSearch"];
s.permissions.allow = Array.from(new Set([...(s.permissions.allow || []), ...allow]));
s.skipAutoPermissionPrompt = true;
s.permissions.disableAutoMode = "disable"; // no "Make auto mode your default?" question, and no auto-mode check
s.statusLine = { type: "command", command: "bash " + path.join(e.HK_WS, ".devcontainer", "status.sh") };
// Partial hardening: keep Claude from reading the key it runs on (settings file and environment).
const deny = ["Read(~/.claude/**)", "Read(~/.claude.json)", "Bash(env)", "Bash(env *)", "Bash(printenv)", "Bash(printenv *)", "Bash(*~/.claude*)", "Bash(*$HOME/.claude*)", "Bash(*OPENROUTER_API_KEY*)", "Bash(*ANTHROPIC_AUTH_TOKEN*)",
  // PDFs sent to the gateway are parsed for a fee on every request; CLAUDE.md says to use pdftotext instead.
  "Read(**/*.pdf)", "Read(//**/*.pdf)"];
s.permissions.deny = Array.from(new Set([...(s.permissions.deny || []), ...deny]));
fs.writeFileSync(settingsFile, JSON.stringify(s, null, 2));
fs.chmodSync(settingsFile, 0o600);

const stateFile = e.HK_CFG === path.join(e.HK_HOME, ".claude")
  ? path.join(e.HK_HOME, ".claude.json") : path.join(e.HK_CFG, ".claude.json");
let j = {};
try { j = JSON.parse(fs.readFileSync(stateFile, "utf8")); } catch (_) {}
j.hasCompletedOnboarding = true;
j.diffTool = "terminal"; // show file changes in the terminal, not as a separate editor tab
j.projects = j.projects || {};
j.projects[e.HK_WS] = Object.assign(j.projects[e.HK_WS] || {}, { hasTrustDialogAccepted: true });
fs.writeFileSync(stateFile, JSON.stringify(j, null, 2));
' || { echo "SETUP PROBLEM: could not write the Claude Code settings."; exit 0; }

# PDF tools (pdftotext, pdftoppm), so PDFs are read here for free and never sent to the gateway.
# Installed in the background so the first start is not slower; skipped where apt-get is missing.
if ! command -v pdftotext >/dev/null 2>&1 && command -v apt-get >/dev/null 2>&1; then
  # Retries: on first start another apt-get (the image) may hold the lock, and setup.sh runs twice (create and start).
  # setsid + nohup: a plain background job is killed when the create step ends.
  setsid nohup bash -c 'for i in 1 2 3 4 5 6 7 8 9 10; do command -v pdftotext >/dev/null 2>&1 && break; sudo apt-get update -qq && sudo apt-get install -y -qq poppler-utils && break; sleep 15; done' >>/tmp/pdf-tools-install.log 2>&1 </dev/null &
fi

# Defaults so students do not have to remember anything:
# 1) Claude starts by itself in the first terminal and picks up the last chat (falls back to a new chat).
BASHRC="$HOME/.bashrc"
if ! grep -q "hackathon-autostart" "$BASHRC" 2>/dev/null; then
  cat >> "$BASHRC" <<'RC'

# hackathon-autostart: open Claude in the first terminal, continuing the last chat if there is one
if [ "$TERM_PROGRAM" = "vscode" ] && [ -t 1 ] && command -v claude >/dev/null 2>&1; then
  _hk_pid="/tmp/.hackathon-claude.pid"
  if ! { [ -f "$_hk_pid" ] && kill -0 "$(cat "$_hk_pid" 2>/dev/null)" 2>/dev/null; }; then
    echo $$ > "$_hk_pid"
    _hk_dir="$HOME/.claude/projects/$(pwd | sed 's/[^A-Za-z0-9]/-/g')"
    if ls "$_hk_dir"/*.jsonl >/dev/null 2>&1; then claude --continue || claude; else claude; fi
    rm -f "$_hk_pid"
  fi
fi
RC
fi
# Commits always use the GitHub no-reply address, never the student's real email.
if command -v git >/dev/null 2>&1; then
  git config --global user.email "${GITHUB_USER:-student}@users.noreply.github.com" >/dev/null 2>&1 || true
  git config --global user.name "${GITHUB_USER:-student}" >/dev/null 2>&1 || true
fi
# 2) Work is saved to GitHub every 5 minutes in the background.
AUTOSAVE_PID="/tmp/.hackathon-autosave.pid"
if ! { [ -f "$AUTOSAVE_PID" ] && kill -0 "$(cat "$AUTOSAVE_PID" 2>/dev/null)" 2>/dev/null; }; then
  WORKSPACE_DIR="$WORKSPACE" nohup bash "$(dirname "$0")/autosave.sh" >/dev/null 2>&1 &
  echo $! > "$AUTOSAVE_PID"
fi

# Friendly first message in the terminal (replaces the default Codespaces welcome text). Best effort: never fails setup.
LIVE_LINE=""
_remote="$(git -C "$WORKSPACE" remote get-url origin 2>/dev/null | grep 'github\.com' | sed -E 's#(\.git)?$##; s#^.*github.com[:/]##')"
if [ -n "$_remote" ]; then LIVE_LINE="Your page will be at: https://${_remote%%/*}.github.io/${_remote#*/}/"; fi
NOTICE_DIR="/usr/local/etc/vscode-dev-containers"
if [ -d "$NOTICE_DIR" ]; then
  printf '%s\n' "Welcome! This is your own computer in the browser." "" "Claude starts by itself. Wait for the box with the arrow >." "Then paste your prompt and press Enter." "" "Your work is saved online every 5 minutes." "${LIVE_LINE}" "Stuck? Open START-HERE.md on the left." | sudo -n tee "$NOTICE_DIR/first-run-notice.txt" >/dev/null 2>&1 || true
fi

echo "Setup done. Open a terminal and type: claude"
