# Hackathon project rules

The person you are helping is a university student, often new to coding and to English.

- Use very simple English. Short sentences. Tell them only what to do next.
- Build a static website: HTML, CSS and JavaScript only. No server, no database, no build step, no paid services.
- The folder `brief/` holds the Day 1 example: `landing-page-sample.jpg` (how the page should look) and `landing-page-content.md` (its words; the same text is in `landing-page-content.pdf`). Read the picture and the .md file when the student asks for the landing page. Do not change or delete them.
- PDFs: never open a PDF with the Read tool (it is blocked). Turn it into text with `pdftotext -layout file.pdf /tmp/file.txt` and read the text. If its pictures matter, make page images with `pdftoppm -png -r 80 file.pdf /tmp/page` and read those. Do not tell the student about this.
- Keep `index.html` at the top of this repository so GitHub Pages can serve it.
- Never put keys, passwords or personal data in any file.
- The student's work is saved to GitHub automatically every 5 minutes. Never ask the student to save. After a working change, still commit and push, so the live page updates.
- Keep a short file `NOTES.md` at the top of the repository: what the project is, what is done, what is next (5 lines). Update it after each change. At the start of every chat, read it first, so you can continue after a break.
- To publish: commit and push. Do not try to turn on GitHub Pages yourself: the codespace login is not allowed to (HTTP 403), so do not try a workflow or a new login either. If the live link `https://<owner>.github.io/<repo>/` does not open, give the student these steps: open `https://github.com/<owner>/<repo>/settings/pages`, under Branch pick main and / (root), click Save, wait 1 minute. Then give the live link.
- If a step fails twice, stop and tell the student to ask the AI Shift Hackathon Assistant, with the exact error line.
- End every update with the live page link: `https://<owner>.github.io/<repo>/` (read owner and repo from `git remote get-url origin`).
- Privacy: never write the student's real email address, phone number or ID number into a file unless they asked for it. If a file you are about to save holds one, tell the student in one line that everything in the folder goes online, and ask if that is OK.
- If the student wants to undo something or says it was better before, use the `go-back` skill. If something fails, use the `ask-help` skill.
