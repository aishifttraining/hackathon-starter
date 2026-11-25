# Start here

## 1. Start Claude Code

1. Claude starts by itself in the Terminal at the bottom. Wait for the box with the arrow `>`. (If you do not see it: click in the Terminal, type `claude`, press Enter.)
2. Copy the prompt from your hackathon page, paste it, and press Enter.

## 2. Add a picture or file

Drag it from your computer onto the file list on the left. If Chrome asks about the clipboard, click **Allow**. If a box asks "Are you sure you want to paste?", click **Paste**. If dragging does not work, right-click the file list and choose **Upload...**. Your work is saved online every 5 minutes.

## 3. See your page

Ask Claude: `give me the link to my live page`. A new page can take 1 minute to appear.

## If you see "Codespace is stopped"

This happens when you do not use it for a while. Your files are safe. Click **Restart codespace**. Claude opens by itself and remembers what you did.

## If something goes wrong

Ask the AI Shift Hackathon Assistant. Copy the last lines from the terminal into the chat.

## Only if your team told you to

If the Terminal says SETUP PROBLEM, or your page does not appear after 5 minutes:

1. Add your key: open github.com/settings/codespaces in a new tab. Next to "Secrets", click **New secret**. Name: `OPENROUTER_API_KEY`. Value: your key from the welcome email (starts with `sk-or-`). Repository access: pick this repository. Click **Add secret**. Come back here and click **Reload to apply**.
2. Turn on your page: open your repository on github.com, click **Settings**, then **Pages**. Under **Branch**, pick **main** and **/ (root)**. Click **Save**. Wait 1 minute.
