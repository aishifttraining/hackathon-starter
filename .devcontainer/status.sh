#!/usr/bin/env bash
# One line shown under the Claude prompt: is the work saved, and where is the live page.
cat >/dev/null 2>&1   # Claude sends JSON on stdin; not needed
S="${HOME}/.hackathon/save-status"
NOW=$(date +%s)
if [ -f "$S" ]; then
  read -r T R < "$S"
  AGE=$(( (NOW - T) / 60 ))
  case "$R" in
    ok)       MSG="Saved online ${AGE} min ago" ;;
    failed)   MSG="NOT saved yet. Ask Claude: why is my work not saved?" ;;
    big:*)    MSG="File too big to save: ${R#big:}. Delete it or use a smaller one." ;;
    *)        MSG="Saving..." ;;
  esac
else
  MSG="Saving starts in 5 minutes"
fi
URL=""
REMOTE=$(git -C "${WORKSPACE_DIR:-$PWD}" remote get-url origin 2>/dev/null | grep 'github\.com' | sed -E 's#(\.git)?$##; s#^.*github.com[:/]##')
if [ -n "$REMOTE" ]; then OWNER=${REMOTE%%/*}; REPO=${REMOTE#*/}; URL=" | Your page: https://${OWNER}.github.io/${REPO}/"; fi
echo "${MSG}${URL}"
