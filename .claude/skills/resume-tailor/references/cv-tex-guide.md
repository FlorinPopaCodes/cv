# cv.tex Guide

Everything the resume-tailor skill needs to edit `cv.tex` safely. Read this before making any
edits in Phase 3.

## File shape

`cv.tex` is a single-file LaTeX `article` (a4paper, 11pt) built with `tectonic`. Order:

1. **Preamble** — packages, color definitions, `\titleformat` for sections, the `itemize` list
   style, the `\firstrole` / `\role` macros, `\hypersetup`.
2. `\begin{document}`
3. **Header** — a `\begin{center}` block: name (`\LARGE\textbf`), title line
   (`\textcolor{light}{...}`), contact line (email · phone · location), links line
   (LinkedIn · GitHub · personal site).
4. `\section*{Summary}` — one or two short paragraphs.
5. `\section*{Experience}` — a sequence of role blocks (below), with one manual `\newpage` for
   page balance.
6. `\section*{Skills}` — `\textbf{Category:}` lines separated by `\\[0.3em]`.
7. `\section*{Education}` — one entry.
8. `\end{document}`

## Role macros

```latex
\firstrole{<Company>}{<Title>}{<Location>}{<Dates>}   % the FIRST role under a \section* — no leading vertical space
\role{<Company>}{<Title>}{<Location>}{<Dates>}        % every subsequent role — adds 0.5em above
```

Both emit `\needspace{4\baselineskip}` so a role heading is never orphaned at the bottom of a
page. A role *block* is the macro line followed immediately by an `itemize`, with a `% tailor:`
comment directly above:

```latex
% tailor: core
\role{FairMoney}{Senior Software Engineer, Backend}{Remote}{June 2023 -- Feb 2024}
\begin{itemize}
  \item ...
  \item ...
\end{itemize}
```

**Swap rule:** exactly one role under `\section*{Experience}` uses `\firstrole`, and it must be
the first role that actually renders. If you reorder or drop roles so a different role becomes
first, change the old first role from `\firstrole` → `\role` and the new first role from
`\role` → `\firstrole`.

## `% tailor:` markers

Every role block has a comment line directly above its macro:

| Marker | Meaning | Allowed edits |
|---|---|---|
| `% tailor: core` | Always present, full detail | Reorder / reword bullets. Never drop. Ask before condensing. |
| `% tailor: condense-ok` | May be shortened | Condense to 1–2 JD-relevant bullets if space or relevance needs it. Don't drop without asking. |
| `% tailor: optional` | May be removed | Comment out the whole `\role{...}` … `\end{itemize}` block if not JD-relevant. Otherwise condense or keep. |

**Current classification:**
- `core`: Series A HR-Tech SaaS, HHA, FairMoney, Smily
- `condense-ok`: Annkissam ×3 (2020–22, 2016–19, 2013–16)
- `optional`: Catalyst Worldwide, Wizart Studios

The markers say what's *permitted*. The JD plus the user's Phase-2 answers decide what actually
happens. Keep the markers in `cv.tex` when committing tailored versions — they're cheap and the
next run reads them.

To "drop" a role, **comment it out** rather than deleting, so it's trivial to restore:

```latex
% tailor: optional  (dropped for <company> — not relevant to this JD)
% \role{Wizart Studios}{Web Developer}{Bucharest, Romania}{Nov 2010 -- Aug 2012}
% \begin{itemize}
%   \item Built and maintained websites for small local and international clients
%   \item Mentored and onboarded three junior developers
% \end{itemize}
```

## `\newpage`

There is one manual `\newpage` inside the Experience section (currently after the "Annkissam,
acquired by HHA" 2020–22 role). It exists purely to balance the two pages. After adding,
removing, or condensing roles, move it so:
- page 1 ends cleanly — no role heading orphaned, no large empty gap;
- page 2 isn't nearly empty — if everything fits on ~2 pages, that's the target.

If the content no longer needs a forced break, remove the `\newpage`. If it overflows to a 3rd
page, condense `condense-ok` roles or ask the user what to cut — **do not** shrink fonts or
margins (that breaks the `.impeccable.md` whitespace principle).

## `\hypersetup` — update per job

```latex
\hypersetup{
  colorlinks=true, urlcolor=linkblue, linkcolor=linkblue,
  pdfauthor={Florin Popa},
  pdftitle={Florin Popa - Senior Software Engineer},   % -> "Florin Popa - <Target Role>"
  pdfsubject={CV / Resume},
  pdfkeywords={Ruby, Rails, Go, Backend, Fintech, ...} % -> JD-relevant tech + domains, comma-separated
}
```

Also update the visible header title line inside the `\begin{center}` block:
`{\textcolor{light}{Senior Software Engineer}}` → the target role title.

Don't touch `colorlinks`, the color definitions, `geometry`, or the section/list styling — those
are the `.impeccable.md` design and stay fixed.

## Skills section

```latex
\textbf{Languages:} Ruby, Go, TypeScript, Python, JavaScript\\[0.3em]
\textbf{Frameworks \& Tools:} Ruby on Rails, Hotwire, RSpec, Sidekiq, Sorbet, REST APIs\\[0.3em]
\textbf{Infrastructure:} AWS, GCP, Docker, Kubernetes, CI/CD, GitHub Actions, CircleCI\\[0.3em]
\textbf{Data:} PostgreSQL, MySQL, SQLite, Redis, MongoDB, RabbitMQ, Kafka\\[0.3em]
\textbf{Practices:} TDD, DDD, Microservices, API Design, Performance Optimization, Code Review, Technical Mentoring\\[0.3em]
\textbf{AI Tooling:} Prompt Engineering, Claude Code, Codex, Cursor, Agent Skills, MCPs\\[0.3em]
```

Tailoring: reorder the lines (most JD-relevant category first), surface JD-required skills inside
the relevant line, trim genuine noise for the role. Keep `\\[0.3em]` between lines. Use `\&` for
ampersands. Be conservative about removing skills — fine for a job-specific working copy, but say
so; don't let it land on `main` unintentionally.

## `make` targets

| Target | Effect | Skill use |
|---|---|---|
| `make build` | `tectonic cv.tex` → `cv.pdf` | Use after every edit. |
| `make watch` | build, `open cv.pdf`, rebuild on change | Don't use from the skill (interactive / blocking). |
| `make ats-check` | `pdffonts cv.pdf` + `pdftotext cv.pdf -` | Use to verify embedded fonts and text extraction. |
| `make clean` | remove `cv.pdf` and aux files | Rarely needed. |
| `make release` | `gh release create` — **a public GitHub release of the PDF** | **Never run this.** It's for the master CV. Mention it to the user if relevant; don't invoke it. |

## `.impeccable.md` constraints (summary)

The CV must read for both ATS parsers and human skimmers (technical + non-technical hiring
managers). Keep:
- Scannability first — seniority, domain, and impact graspable in ~6 seconds.
- Generous whitespace — it signals confidence; cramming signals desperation. ~2 pages.
- Hierarchy via weight / size / spacing, not lines or boxes.
- Every word earns its place — cut any bullet that doesn't show impact or scope.
- ATS-friendly always — real text, standard fonts, single column, no tables / graphics.
- Muted palette — `#2C3E50` accent, `#4A6274` links, `#5A6A7A` secondary text. Don't change colors.
- Tone: composed, credible, sharp. No flashiness, no overselling.

## cv.tex is the master

There is no separate master profile — `cv.tex` on `main` holds the full history. When tailoring:
- **Reorder and reword freely** inside the job-specific worktree (`.claude/worktrees/tailor-<slug>`).
- **Treat removals as job-specific** — dropping a skill or commenting out a role is fine for one
  application. The `tailor/<slug>` branch holds those edits as a self-contained archive. Never
  merge `tailor/<slug>` to `main` and never run `make release` from it — `main` stays canonical.
