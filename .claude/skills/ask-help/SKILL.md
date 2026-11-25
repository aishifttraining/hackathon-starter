---
name: ask-help
description: Use when the student says they are stuck, something failed, the page does not show, a picture is missing, or they type /ask-help. Finds the problem in the project folder and fixes it.
---

# Help a stuck student

The student is new to coding and to English. Use very simple words. Fix the problem yourself. Do not ask them to run commands.

What the folder looks like right now:

- Files: !`ls`
- Changes not saved to GitHub yet: !`git status --short | head -20`
- Last saves: !`git log --oneline -5`
- Project address: !`git remote get-url origin`

Check these in order and fix the first one that is wrong:

1. `index.html` must be at the top of the folder, not inside another folder.
2. A picture must be in the folder and the page must use the same file name, with the same capital letters.
3. Work must be saved: commit everything and push to GitHub. Then check that the push worked.
4. If the live link `https://<owner>.github.io/<repo>/` shows 404, give the student the Pages steps from CLAUDE.md.
5. If you see an error, read it once, fix the cause, and try again.

Rules:

- Never show, read, copy or print passwords, keys or anything inside `~/.claude`, and never run `env` or `printenv`.
- Never mention models, presets, OpenRouter, budgets or credits.
- Reply in at most 4 short lines: what was wrong, what you did, what the student should do next.
- If it is still not fixed after 2 tries, stop. Tell the student: copy the last error line and give it to the AI Shift Hackathon Assistant.
