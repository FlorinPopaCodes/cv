---
name: beautiful-prose
description: A hard-edged writing style contract for timeless, forceful English prose without modern AI tics. Use when users ask for prose or rewrites that must be clean, exact, concrete, and free of AI cadence, filler, or therapeutic tone.
user-invocable: true
---

# Beautiful Prose

A hard-edged writing skill for producing timeless, forceful English prose without modern AI tics.

This is a style contract, not a vibe. Treat violations as failures.

> Adapted from [Eduard22222222/claude-skill-stack](https://github.com/Eduard22222222/claude-skill-stack/blob/main/skills/beautiful-prose/SKILL.md).

## What this skill does

When active, write prose that is:
- clean, exact, muscular
- readable at speed, rewarding on reread
- concrete, image-bearing, verb-forward
- confident without bombast
- free of modern content-marketing cadence

No filler. No "helpful assistant" tone. No therapy voice.

## Activation

Invoke with `/beautiful-prose`, or this skill applies whenever the request is for prose or a
rewrite that must be clean, exact, concrete, and free of AI cadence.

Do not announce the skill or narrate the process. Produce the prose only.

Optional control tags — pass as arguments to `/beautiful-prose`, or put them on one line before
the request:
- `REGISTER: founding_fathers | literary_modern | cold_steel | journalistic`
- `DENSITY: lean | standard | dense`
- `HEAT: cool | warm | hot` (how sharp the voice is)
- `LENGTH: micro | short | medium | long`

Example:

```
/beautiful-prose REGISTER: literary_modern DENSITY: dense HEAT: cool
Write a 700 word essay on why discipline beats motivation.
```

## Absolute prohibitions

When this skill is active, do not use:

### 1) Em dashes
- Ban "--" used as em dashes.
- Use periods, commas, colons, semicolons, or line breaks.

### 2) "It's not X, it's Y" constructions
Ban the pattern and its masked variants, including:
- "This isn't about X. It's about Y."
- "Not X but Y."
- "X is a symptom. Y is the cause." (when used as a cheap reversal)
- "The real story is Y." (when it is only a pivot)

### 3) Filler transitions and scene-setting
Ban phrases like:
- "At its core"
- "In today's world"
- "In a world where"
- "That said"
- "Let's explore"
- "Ultimately"
- "What this means is"
- "It's important to note"
- "On the one hand"

### 4) Therapeutic or validating language
No:
- "I hear you"
- "That sounds hard"
- "You're valid"
- "Give yourself grace"
- "Be kind to yourself"

### 5) AI tells and meta commentary
No:
- "In this essay"
- "This piece explores"
- "As a writer"
- "We will discuss"
- "Here are the key takeaways"
- apologies for style or capability

### 6) Symmetry padding
No balancing sentences for the sake of balance.
No three-part lists unless earned.
No "X, Y, and Z" as decoration.

## Positive constraints

Actively do the following:

### Sentence craft
- Prefer declarative sentences.
- Vary length aggressively.
- Use short sentences as impact.
- Questions are allowed only when they cut.

### Word choice
- Prefer concrete nouns to abstractions.
- Prefer strong verbs to adverbs.
- Prefer Anglo-Saxon weight when possible.
- Use Latinate precision only when it buys accuracy.

### Rhythm and structure
- Paragraphs should breathe.
- White space is intentional.
- Open with substance, not a hook.
- Close cleanly without summary.
- Do not restate the thesis.

### Authority
- Write as if truth does not need permission.
- Avoid hedging unless uncertainty is essential and explicit.
- Do not posture. Do not moralize.

## Registers (optional)

### founding_fathers
- formal, spare, civic gravity
- balanced syntax, but not decorative
- moral clarity without sermon

### literary_modern
- vivid, lean imagery
- controlled heat, sharp observation
- minimal ornament

### cold_steel
- severe compression
- punchy, unsentimental
- high signal, low warmth

### journalistic
- crisp, factual, narrative clarity
- clean momentum
- no clickbait cadence

If no register is set, default to `literary_modern`.

## Quality bar

Before finalizing, check internally:
- Remove any line that sounds like it was assembled from templates.
- Remove any sentence that merely repeats the previous one.
- Remove any sentence that exists to guide the reader's emotions.
- Ensure every paragraph advances meaning.

If quality is uncertain, write less. Silence beats slop.

## Output rules

- Plain text prose by default.
- No headings unless requested.
- No bullet points unless requested.
- If the user requests bullets, keep them taut and non-corporate.

## Examples

### Bad (banned)
"This isn't about money. It's about power."

### Good
"Money is the instrument. Power is the habit."

### Bad (filler)
"At its core, this is a complex issue. That said, in today's world..."

### Good
"It is complex. Complexity is not an excuse for fog."

## Lint checklist (manual)

Fail the output if any are true:
- Contains "--" used as an em dash.
- Contains a reversal pivot pattern ("not X, Y").
- Contains filler transitions from the banned list.
- Contains therapy language or validation.
- Contains meta writing talk ("this essay," "we will").
- Contains five consecutive sentences of similar length.

## Notes for constrained formats (resumes, LaTeX, lists)

When invoked on text that lives inside a structured document — a LaTeX CV, a bulleted resume,
a table — apply the *voice* (concrete nouns, strong verbs, varied rhythm, no filler, no cheap
reversals, no therapy tone) but relax the format bans that the structure requires:
- bullet points are fine when the document is a list;
- short factual enumerations ("Ruby, Go, TypeScript") are not "rule-of-three decoration";
- `--` inside a LaTeX date range is an en dash, not an em dash — leave it;
- never restructure or strip the host document's markup.

## Tests

See `references/test-cases.md`.
