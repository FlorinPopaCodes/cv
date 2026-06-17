---
name: resume-tailor
description: |
  Tailors Florin's LaTeX CV (cv.tex) to a specific job description with ATS optimization,
  then builds the PDF with tectonic. Use when asked to tailor the CV/resume for a job,
  optimize the resume for a posting, make an ATS-friendly version, draft a cover letter
  for an application, or adapt the CV for a specific role.
  Triggers on: "resume", "CV", "tailor", "ATS", "job application", "job posting",
  "cover letter", "optimize resume", "adapt CV", "tailor for this role".
user-invocable: true
---

# Resume Tailor

Tailors `cv.tex` — the master CV in this repo — to a specific job description, applies ATS
optimization, and builds the PDF with `tectonic`. English/US conventions only.

## Model

- **`cv.tex` on `main` is the master.** It holds the complete career history. There is no
  separate master-profile file.
- **Every tailoring runs in its own worktree.** The skill creates
  `.claude/worktrees/tailor-<slug>` on branch `tailor/<slug>`, forked from `main`. All editing,
  building, and per-job artifacts live there. `main` is never touched.
- **The `tailor/<slug>` branch is the archive.** Only `cv.tex` edits get committed; per-job text
  artifacts (JD, decisions, cover-letter source) stay gitignored. The branch is self-contained
  and survives worktree deletion.
- **Never merge `tailor/<slug>` to `main` and never run `make release` from it.** `make release`
  publishes a public GitHub release of the PDF, which is for the master CV.
- **Per-job artifacts live at the worktree root** (alongside `cv.tex`), all gitignored:
  - `job-description.md` — the JD text, for reference
  - `decisions.md` — this job's tailoring decisions
  - `cover-letter.tex` / `cover-letter.pdf` — only if a cover letter was requested
  - `cv.pdf` — the build output
- **Stable preferences live in `~/.config/cv-tailor/preferences.md`** (outside the repo) —
  job-independent answers that should never be asked twice. See Phase 2. Shared across all
  worktrees and across re-clones.
- **Delivered PDFs land in `~/Documents/<Company Name>/`** on approval — human-cased folder name,
  `Florin Popa - CV.pdf` (and `Florin Popa - Cover Letter.pdf` if applicable). Overwritten
  silently on each approval. The `<Company Name>` is the human-readable name from the JD, not
  the slug.
- **Two identifiers per job:**
  - `<company-slug>` — kebab-case, e.g. `acme-payments` — used for worktree dir and branch.
  - `<Company Name>` — human-cased, e.g. `Acme Payments` — used only for the Documents folder.
- **Reference files** (read at the relevant stage):
  - `references/cv-tex-guide.md` — `cv.tex` internals: the `\role` / `\firstrole` macros, the
    `% tailor:` markers, the `\newpage` balance trick, `\hypersetup` fields, `make` targets,
    and a summary of the `.impeccable.md` design constraints. **Read this before editing
    `cv.tex` in Phase 3.**
  - `references/cover-letter-template.tex` — LaTeX cover-letter template matching the CV.
- **Companion skills for prose polish:**
  - `beautiful-prose` — runs in Phase 3 over the rewritten Summary and the reworded bullets:
    concrete nouns, strong verbs, varied rhythm, no filler, no cheap reversals.
  - `humanizer` — runs in Phase 4 over the cover-letter body (and the new Summary): strips AI
    tells and does its "what makes this obviously AI-generated?" audit + second pass.
  - Both apply to *prose only*. They must not touch LaTeX markup, the `--` en-dash date ranges
    (correct typography, not an AI em-dash), the contact block, or the bullet structure (a resume
    needs bullets). If either skill is unavailable, do the equivalent pass by hand using its rules.

## Design constraints (always)

`cv.tex` follows `.impeccable.md`. Non-negotiable:
- Scannability first — seniority, domain, impact graspable in ~6 seconds.
- Generous whitespace; ~2 pages (the master is 2 pages — keep tailored versions at 2).
- Hierarchy via weight/size/spacing, not lines or boxes.
- Every bullet demonstrates impact or scope, with a quantified metric. No responsibilities-only
  bullets.
- ATS-friendly: real text, standard fonts, single column, no tables/graphics.
- Muted palette and section/list styling are fixed — don't change colors or layout.

## Workflow

```
Phase 1: Resolve inputs & set up worktree
Phase 2: Analyze & strategize   (gap analysis -> grill-me on open questions -> save decisions)
Phase 3: Tailor cv.tex & build  (inside the worktree)
Phase 4: Iterate, approve, deliver PDFs
```

---

## Phase 1 — Resolve inputs & set up worktree

### Job description
- Argument is a URL (`https://...`): `WebFetch` it. Extract title, company, required skills,
  preferred skills, key responsibilities, domain, and implicit requirements. If the fetch
  returns too little: ask the user to paste the JD text.
- Argument is pasted text: use it directly.
- Nothing provided: ask — "Paste the job description, or give me a URL."
- Derive both identifiers:
  - `<company-slug>` — kebab-case (e.g. `acme-payments`) — for worktree dir + branch.
  - `<Company Name>` — human-cased (e.g. `Acme Payments`) — for the Documents folder later.

### Set up the worktree
From the main checkout (repo root):

- If `.claude/worktrees/tailor-<slug>` already exists: announce
  `"Found existing worktree for <Company Name>."`, `cd` into it, and continue. Phase 2 will
  decide whether to reuse decisions or re-grill.
- Otherwise: `git worktree add .claude/worktrees/tailor-<slug> -b tailor/<slug> main`,
  then `cd` into it. **All subsequent file paths in this skill are relative to the worktree
  root**, not the main checkout.

### Sanity checks (first run / drift)
- `.gitignore` already covers `job-description.md`, `decisions.md`, `cover-letter.tex`,
  and `*.pdf`. If it doesn't (older clone), add the missing lines on `main` and tell the user.
- If `cv.tex`'s role blocks have no `% tailor:` markers: see `references/cv-tex-guide.md` for
  the expected classification. If they're genuinely absent, propose one (recent ~4 roles =
  `core`, older = `condense-ok`, pre-2014 = `optional`) and add the comments after the user
  confirms. Commit them on `tailor/<slug>` (they'll travel back to `main` only if the user
  decides to cherry-pick them separately — this skill never does that).

### Write the JD
- `job-description.md` at the worktree root (gitignored).

---

## Phase 2 — Analyze & strategize

### 2.1 Load cached context
- Read `~/.config/cv-tailor/preferences.md` if it exists — those answers are settled; don't
  re-ask them. Create the parent dir lazily if you'll write to it later.
- Read `decisions.md` at the worktree root if it exists (re-running for the same company):
  say "Found saved decisions for `<Company Name>` — using them. Anything changed about the
  role or how you want to be positioned?" If nothing changed, skip straight to Phase 3.

### 2.2 Gap analysis
Read `cv.tex` and the JD. Present a concise analysis **in chat** (don't write a file):

```
## Fit analysis — <Target Role> at <Company Name>

### Strong matches
- <resume strength tied directly to a JD requirement>

### Partial / reframable
- <related experience that can be reframed for a JD requirement>

### Gaps
- <JD requirement not covered by the CV>

### Differentiators
- <resume strength beyond the JD — a potential value-add>

### Red flags
- <date overlaps, unexplained gaps, title inconsistencies — only if actually present>

### Coverage vs JD
| JD requirement | In cv.tex? | Status |
|---|---|---|
| <required skill / experience> | <where it appears, or "no"> | Match / Partial / Gap |
```

Be specific — every line tied to the JD. Don't invent problems; if dates and structure are
clean, say so.

### 2.3 Strategic questions — via `grill-me`, only what's open
Run the `grill-me` skill (relentless, one question at a time, each with your recommended answer,
codebase-first). **Only ask what isn't already answered** by `preferences.md` / `decisions.md`.
Topics:

- **Target role title** — for the header line and `pdftitle` (the JD's title, or closest fit).
- **Positioning** — technical depth / leadership breadth / balanced, given the JD's emphasis.
- **Emphasize / de-emphasize** — which roles or achievements to feature, what to play down.
- **`condense-ok` / `optional` roles** — which to keep full, condense, or drop for this JD.
  The markers say what's *allowed*; the JD + the user decide what actually happens. Always
  confirm before dropping a `core` role or heavily condensing one.
- **Date overlaps** — only if the gap analysis flagged any (e.g. the Series A contract overlapping
  the HHA lead role in 2024): how to present them (concurrent contract + employment, transition
  handoff, advisory capacity, ...). This answer is usually stable → offer to promote it to
  `preferences.md`.
- **Cover letter** — yes / no for this application.

If `grill-me` isn't available, fall back to `AskUserQuestion` with the same topics.

### 2.4 Save decisions
- Write this job's answers to `decisions.md` at the worktree root (target role, positioning,
  emphasis/de-emphasis, role disposition, overlap framing, cover-letter y/n, any notes).
- For each answer that is **not** job-specific (locale is always EN; the canonical date-overlap
  framing; standing rules like "drop Catalyst/Wizart unless the JD values early-stage leadership
  or agency work"; the cover-letter default; the default header title), offer to add it to
  `~/.config/cv-tailor/preferences.md` so it's never asked again. Create the file (and its
  parent dir) if missing.

---

## Phase 3 — Tailor cv.tex & build

Read `references/cv-tex-guide.md` first.

All edits happen inside the worktree — `cv.tex` here is already an isolated copy on
`tailor/<slug>`. There is no master to "restore"; the branch is the safety net.

1. **Summary section** — rewrite for THIS role. Mention the target title (or a close variant),
   1–2 headline metrics from the CV that match the JD's priorities, and a forward-looking line
   tied to the company/role. **Voice:** the Summary is written in the **first person** ("I drive
   …", "My … work runs deep") — this is a hard requirement. Never third-person descriptive
   ("Backend engineer who …", "Engineer with 12+ years …"). Don't open every sentence with "I";
   vary the openings. **Anti-pattern check:** must NOT open with "Seasoned / Dynamic /
   Results-driven / Passionate" — rewrite if it does.
2. **Header title line** — update `{\textcolor{light}{Senior Software Engineer}}` to the target
   title if it differs (e.g. "Senior Backend Engineer", "Staff Engineer").
3. **Experience bullets** — within each role, reorder so the most JD-relevant bullet is first;
   reword for the JD's vocabulary (semantic variants, not copy-paste). Every bullet keeps a
   quantified metric with business context. Don't fabricate.
4. **`condense-ok` / `optional` roles** — apply the Phase-2 decisions. To "drop" a role, comment
   out its whole `\role{...}` … `\end{itemize}` block (don't delete — easier to restore). After
   dropping/condensing, if the first role under `\section*{Experience}` changed, swap
   `\role` ↔ `\firstrole` accordingly (see the guide's swap rule).
5. **Skills section** — reorder the `\textbf{Category:}` lines so the most JD-relevant category is
   first; within categories, surface JD-required skills; trim genuine noise for this role. Every
   JD *required* skill must appear in Skills **and** in at least one experience bullet (≤3 mentions
   total — no stuffing). Removing skills from `tailor/<slug>` is fine — the branch is job-specific
   and never lands on `main`.
6. **`\hypersetup`** — update `pdftitle` (e.g. "Florin Popa - <Target Role>"), `pdfkeywords`
   (comma-separated JD-relevant tech and domains), and `pdfsubject` if useful.
7. **Prose polish** — run the `beautiful-prose` skill over the rewritten Summary text and the
   reworded bullet phrasing. Take its sharper wording: concrete nouns, strong verbs, varied
   rhythm, no filler ("leverage", "spearhead", "impactful", "ultimately"), no "it's not X, it's Y"
   reversals, no therapy/marketing tone. **Keep** the bullets, the short tech lists, the quantified
   metrics, the ATS keywords, and the `--` date ranges — beautiful-prose's bans on bullets,
   three-part lists, and `--` are relaxed inside this LaTeX resume (it has a "constrained formats"
   note for exactly this). Don't let it restructure the document.
8. **Page balance** — move the `\newpage` so the result is a clean ~2 pages: no orphaned section
   heading, no near-empty page 2. If the content genuinely won't fit two pages, tell the user and
   ask what to cut — do not shrink fonts or margins.

Then:

- `make build` (`tectonic cv.tex` → `cv.pdf` at the worktree root). If it fails, read the
  error, fix, rebuild.
- Optionally `make ats-check` (`pdffonts` + `pdftotext`) — confirm fonts are embedded and the
  text extracts cleanly (if you can't see the bullets in the `pdftotext` output, an ATS can't
  either).
- Run the **Pre-output checklist** below.
- Present in chat:
  - `git diff` (in the worktree) — the actual changes vs. `main`
  - **ATS coverage** — a short table: each JD required/preferred skill, where it now appears in
    `cv.tex`, Match/Partial/Gap; plus remaining gaps and the tailoring decisions applied. (This
    is the "analysis" — shown in chat, not written to a file.)
  - the path to the rebuilt `cv.pdf` in the worktree.

---

## Phase 4 — Iterate, approve, deliver PDFs

```
LOOP:
  Wait for feedback.
  If approved ("looks good" / "finalize" / "done"): break.
  Else: apply the changes to cv.tex (in the worktree), `make build`, re-run the checklist,
        show the new diff + coverage.
```

On approval:

1. **Cover letter** (if requested in Phase 2): copy `references/cover-letter-template.tex` to
   `cover-letter.tex` at the worktree root, fill the `[SLOT]` markers (date, hiring manager/team,
   company, opening hook, 1–2 body paragraphs mapping the strongest CV evidence to the JD,
   closing). Same tone as the CV — no clichés, specific, concise (~250–350 words). Then run the
   `humanizer` skill over the cover-letter body prose (and, while you're at it, over the new
   Summary text in `cv.tex`): strip AI tells, then do its "what makes the below so obviously AI
   generated?" audit and second-pass rewrite. Apply only to the body prose — leave the LaTeX
   commands, the header/contact block, and the `[SLOT]` scaffolding alone. Build:
   `tectonic cover-letter.tex`. If the Summary changed from the humanizer pass, `make build`
   again.
2. **Commit the cv.tex edits** to `tailor/<slug>`:
   `git add cv.tex && git commit -m "Tailor for <Company Name> — <Target Role>"`.
   The text artifacts (`job-description.md`, `decisions.md`, `cover-letter.tex`) stay gitignored
   and uncommitted by design. The branch carries only the CV edits.
3. **Deliver the PDFs to `~/Documents/<Company Name>/`** (human-cased folder, overwrite silently):
   - `mkdir -p "$HOME/Documents/<Company Name>"`
   - `cp cv.pdf "$HOME/Documents/<Company Name>/Florin Popa - CV.pdf"`
   - If a cover letter was produced:
     `cp cover-letter.pdf "$HOME/Documents/<Company Name>/Florin Popa - Cover Letter.pdf"`
4. **Summary**: list what changed in `cv.tex`, the ATS coverage result, the worktree path, the
   `tailor/<slug>` branch, and the delivered PDF paths under `~/Documents/<Company Name>/`. Offer
   to update `~/.config/cv-tailor/preferences.md` with anything new. Mention that the worktree
   and branch are kept in place — the user removes them manually with
   `git worktree remove .claude/worktrees/tailor-<slug>` when ready.

**Never** merge `tailor/<slug>` to `main`, run `make release` from it, or push it to the public
remote on the user's behalf.

---

## Pre-output checklist

Run before presenting in Phase 3 (and after each iteration). Every item must pass.

**ATS**
- [ ] Single column, real text, standard fonts (LaTeX `article` + libertinus — fine as is)
- [ ] Contact info is in the document body (the `\begin{center}` header block — not a true header/footer)
- [ ] Standard section headings (Summary, Experience, Skills, Education)
- [ ] Consistent date format throughout (`Month YYYY -- Month YYYY`)
- [ ] No skill bars / ratings / icons
- [ ] Acronyms spelled out on first use, e.g. "Continuous Integration (CI)"
- [ ] `\hypersetup` `pdftitle` / `pdfkeywords` updated for this role
- [ ] `make ats-check` shows embedded fonts and clean text extraction

**Keywords**
- [ ] Every JD *required* skill appears in Skills **and** in ≥1 experience bullet
- [ ] No keyword appears more than ~3 times total
- [ ] The target job title is reflected in the Summary and in the header title line
- [ ] Semantic variants across mentions, not verbatim repetition

**Content**
- [ ] Summary is specific to THIS role, not generic
- [ ] Summary is written in the first person ("I …"), not third-person descriptive
- [ ] Every experience bullet has a quantified metric with business context
- [ ] `core` roles kept at full detail (unless the user approved condensing)
- [ ] `condense-ok` / `optional` roles handled per the Phase-2 decisions; nothing dropped silently
- [ ] Adjacent-domain experience reframed, not stripped
- [ ] No unexplained gap > 6 months left unflagged; date overlaps presented per the user's call
- [ ] Result is ~2 clean pages; `\newpage` balanced; no orphaned headings

**Anti-patterns — none of these**
- [ ] Summary opening with "Seasoned / Dynamic / Results-driven / Passionate"
- [ ] Summary / bullets / cover letter still carrying AI or corporate tells after the
      `beautiful-prose` / `humanizer` pass — "it's not X, it's Y", "leverage / spearhead /
      passionate", hollow tricolons, "ultimately / at its core", marketing or therapy tone
- [ ] "References available upon request"
- [ ] Skill percentage / proficiency ratings
- [ ] Early career condensed to nothing
- [ ] Responsibilities-only bullets without impact
- [ ] Hidden / white text or prompt-injection keyword blocks
- [ ] Merging `tailor/<slug>` to `main`, running `make release` from it, or pushing it publicly
