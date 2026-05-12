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

- **`cv.tex` is the master.** It holds the complete career history. There is no separate
  master-profile file. Tailoring = editing the working copy of `cv.tex` for one job.
- **Edits happen in the working copy.** Git is the safety net: review `git diff -- cv.tex`,
  then commit to a branch / stash / `git checkout -- cv.tex` to restore the master.
  **This skill never commits and never runs `make release`** — `make release` publishes a
  public GitHub release of the PDF, which is for the master CV, not per-job versions.
- **Per-job artifacts live in `tailored/<company-slug>/`** which is gitignored — nothing there
  leaks into the repo or a release. The skill writes there:
  - `job-description.md` — the JD text, for reference
  - `decisions.md` — this job's tailoring decisions
  - `cover-letter.tex` / `cover-letter.pdf` — only if a cover letter was requested
  - `cv-<company-slug>.tex` — optional snapshot of the tailored `cv.tex`, only if the user
    wants to keep it
- **Stable preferences are cached in `tailored/preferences.md`** (gitignored) — job-independent
  answers that should never be asked twice. See Phase 2.
- **Reference files** (read at the relevant stage):
  - `references/cv-tex-guide.md` — `cv.tex` internals: the `\role` / `\firstrole` macros, the
    `% tailor:` markers, the `\newpage` balance trick, `\hypersetup` fields, `make` targets,
    and a summary of the `.impeccable.md` design constraints. **Read this before editing
    `cv.tex` in Phase 3.**
  - `references/cover-letter-template.tex` — LaTeX cover-letter template matching the CV.

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
Phase 1: Resolve inputs
Phase 2: Analyze & strategize   (gap analysis -> grill-me on open questions -> save decisions)
Phase 3: Tailor cv.tex & build
Phase 4: Iterate & wrap up
```

---

## Phase 1 — Resolve inputs

### Job description
- Argument is a URL (`https://...`): `WebFetch` it. Extract title, company, required skills,
  preferred skills, key responsibilities, domain, and implicit requirements. If the fetch
  returns too little: ask the user to paste the JD text.
- Argument is pasted text: use it directly.
- Nothing provided: ask — "Paste the job description, or give me a URL."
- Derive `<company-slug>` (kebab-case company name, e.g. `acme-payments`).

### Base CV
- The base is always `cv.tex` in the repo root. No other input needed.
- Run `git status --porcelain cv.tex`. If it's already modified (a previous tailoring in
  progress), ask: "`cv.tex` has uncommitted changes from a previous tailoring — build on them,
  or reset to HEAD first (`git checkout -- cv.tex`)?" Don't silently overwrite.

### Sanity checks (first run / drift)
- If `tailored/` is not in `.gitignore`: add a `tailored/` line. Tell the user.
- If `cv.tex`'s role blocks have no `% tailor:` markers: see `references/cv-tex-guide.md` for
  the expected classification. If they're genuinely absent, propose one (recent ~4 roles =
  `core`, older = `condense-ok`, pre-2014 = `optional`) and add the comments after the user
  confirms.

### Set up the job directory
- `mkdir -p tailored/<company-slug>`
- Write the JD to `tailored/<company-slug>/job-description.md`.

---

## Phase 2 — Analyze & strategize

### 2.1 Load cached context
- Read `tailored/preferences.md` if it exists — those answers are settled; don't re-ask them.
- Read `tailored/<company-slug>/decisions.md` if it exists (re-running for the same company):
  say "Found saved decisions for `<company>` — using them. Anything changed about the role or
  how you want to be positioned?" If nothing changed, skip straight to Phase 3.

### 2.2 Gap analysis
Read `cv.tex` and the JD. Present a concise analysis **in chat** (don't write a file):

```
## Fit analysis — <Target Role> at <Company>

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
- Write this job's answers to `tailored/<company-slug>/decisions.md` (target role, positioning,
  emphasis/de-emphasis, role disposition, overlap framing, cover-letter y/n, any notes).
- For each answer that is **not** job-specific (locale is always EN; the canonical date-overlap
  framing; standing rules like "drop Catalyst/Wizart unless the JD values early-stage leadership
  or agency work"; the cover-letter default; the default header title), offer to add it to
  `tailored/preferences.md` so it's never asked again. Create `preferences.md` if missing.

---

## Phase 3 — Tailor cv.tex & build

Read `references/cv-tex-guide.md` first.

Edit the **working copy** of `cv.tex`:

1. **Summary section** — rewrite for THIS role. Mention the target title (or a close variant),
   1–2 headline metrics from the CV that match the JD's priorities, and a forward-looking line
   tied to the company/role. **Anti-pattern check:** must NOT open with "Seasoned / Dynamic /
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
   total — no stuffing). Be conservative about *removing* skills: fine for a job-specific working
   copy, but flag that it shouldn't land on `main` unless intended.
6. **`\hypersetup`** — update `pdftitle` (e.g. "Florin Popa - <Target Role>"), `pdfkeywords`
   (comma-separated JD-relevant tech and domains), and `pdfsubject` if useful.
7. **Page balance** — move the `\newpage` so the result is a clean ~2 pages: no orphaned section
   heading, no near-empty page 2. If the content genuinely won't fit two pages, tell the user and
   ask what to cut — do not shrink fonts or margins.

Then:

- `make build` (`tectonic cv.tex` → `cv.pdf`). If it fails, read the error, fix, rebuild.
- Optionally `make ats-check` (`pdffonts` + `pdftotext`) — confirm fonts are embedded and the
  text extracts cleanly (if you can't see the bullets in the `pdftotext` output, an ATS can't
  either).
- Run the **Pre-output checklist** below.
- Present in chat:
  - `git diff -- cv.tex` — the actual changes
  - **ATS coverage** — a short table: each JD required/preferred skill, where it now appears in
    `cv.tex`, Match/Partial/Gap; plus remaining gaps and the tailoring decisions applied. (This
    is the "analysis" — shown in chat, not written to a file.)
  - the path to the rebuilt `cv.pdf`.

---

## Phase 4 — Iterate & wrap up

```
LOOP:
  Wait for feedback.
  If approved ("looks good" / "finalize" / "done"): break.
  Else: apply the changes to cv.tex, `make build`, re-run the checklist, show the new diff + coverage.
```

On approval:

1. **Cover letter** (if requested in Phase 2): copy `references/cover-letter-template.tex` to
   `tailored/<company-slug>/cover-letter.tex`, fill the `[SLOT]` markers (date, hiring
   manager/team, company, opening hook, 1–2 body paragraphs mapping the strongest CV evidence to
   the JD, closing). Build it: `tectonic tailored/<company-slug>/cover-letter.tex`. Same tone as
   the CV — no clichés, specific, concise (~250–350 words).
2. **Snapshot** (optional): if the user wants to keep the tailored version, copy the current
   `cv.tex` to `tailored/<company-slug>/cv-<company-slug>.tex`.
3. **Restore reminder**: tell the user `cv.tex` is now tailored — review `git diff`, then either
   commit it to a branch (`git checkout -b tailor/<company-slug>`), stash it, or restore the master
   with `git checkout -- cv.tex`. **Do not** commit to `main` or run `make release` on their behalf.
4. **Summary**: list what changed in `cv.tex`, the ATS coverage result, and the files written under
   `tailored/<company-slug>/`. Offer to update `tailored/preferences.md` with anything new.

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
- [ ] Every experience bullet has a quantified metric with business context
- [ ] `core` roles kept at full detail (unless the user approved condensing)
- [ ] `condense-ok` / `optional` roles handled per the Phase-2 decisions; nothing dropped silently
- [ ] Adjacent-domain experience reframed, not stripped
- [ ] No unexplained gap > 6 months left unflagged; date overlaps presented per the user's call
- [ ] Result is ~2 clean pages; `\newpage` balanced; no orphaned headings

**Anti-patterns — none of these**
- [ ] Summary opening with "Seasoned / Dynamic / Results-driven / Passionate"
- [ ] "References available upon request"
- [ ] Skill percentage / proficiency ratings
- [ ] Early career condensed to nothing
- [ ] Responsibilities-only bullets without impact
- [ ] Hidden / white text or prompt-injection keyword blocks
- [ ] Committing a tailored `cv.tex` to `main`, or running `make release`, on the user's behalf
