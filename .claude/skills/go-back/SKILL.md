---
name: go-back
description: Use when the student wants to undo a change, says the page was better before, or something broke after a change, or types /go-back. Puts the project back to an earlier saved version without losing anything.
---

# Go back to an earlier version

The student is new to coding and to English. Use very simple words. Do it for them.

Earlier saves (newest first): !`git log --format='%h  %ar  %s' -8`

Steps:

1. Pick the save from before the problem. If it is not clear, ask ONE question: "Do you want the version from a few minutes ago, or from an hour ago?"
2. Put the files back from that save with `git checkout <save> -- .` (this makes a new change; nothing is deleted from the history).
3. Commit with the message "Go back to an earlier version" and push.
4. Tell the student in 2 lines what you did and give the live page link.

Never use `git reset --hard`, `git push --force`, or delete history. Never mention models, presets, OpenRouter, budgets or credits.
