# Beautiful Prose — Test Cases

Use these to check the skill's output. Each "before" should be rewritten into something with the
shape of the "after" — not word-for-word identical, but matching the discipline: no em dashes, no
reversal pivots, no filler transitions, no therapy voice, concrete nouns, strong verbs, varied
rhythm.

## 1 — Reversal pivot ("not X, it's Y")

**Before:**
> Writing well isn't about vocabulary. It's about thinking clearly.

**After (acceptable):**
> Clear writing follows clear thinking. The vocabulary is downstream.

**Fail if:** the rewrite keeps any "not X, it's Y" / "not merely X but Y" / "the real Y is..." pivot.

## 2 — Filler scene-setting

**Before:**
> In today's fast-paced world, it's important to note that, at its core, attention is a finite
> resource that ultimately shapes everything we do.

**After (acceptable):**
> Attention is finite. Spend it and it does not come back. Most of what you call a productivity
> problem is an attention budget you never set.

**Fail if:** the rewrite opens with a scene-setter ("In today's world", "At its core") or carries
"it's important to note" / "ultimately".

## 3 — Therapeutic register

**Before:**
> It's completely valid to feel overwhelmed by this. Be kind to yourself, give yourself grace,
> and remember that progress isn't linear.

**After (acceptable):**
> Overwhelm is a signal that the list is wrong, not that you are weak. Cut the list. Start the
> smallest item before you finish reading this sentence.

**Fail if:** any "you're valid", "give yourself grace", "be kind to yourself", "that sounds hard".

## 4 — Symmetry padding / unearned tricolon

**Before:**
> Great teams are built on trust, communication, and collaboration. They innovate, they iterate,
> and they inspire.

**After (acceptable):**
> Great teams trust each other enough to disagree in the room instead of in the hallway. The rest
> is logistics.

**Fail if:** the rewrite forces a new three-part list for rhythm, or balances clauses for the sake
of balance.

## 5 — AI meta-commentary

**Before:**
> In this essay, we will explore the key reasons discipline outperforms motivation. Here are the
> takeaways you need to know.

**After (acceptable):**
> Motivation is weather. Discipline is climate. One decides whether you feel like working today;
> the other decides whether the work gets done this year.

**Fail if:** "in this essay", "we will explore/discuss", "here are the takeaways", or any apology
for style.

## 6 — Em dash overuse

**Before:**
> The plan was simple -- ship the prototype, gather feedback, iterate -- but the timeline was not.

**After (acceptable):**
> The plan was simple: ship the prototype, gather feedback, iterate. The timeline was not.

**Fail if:** the rewrite contains "--" used as an em dash. (Inside a LaTeX date range, `2020 -- 2022`
is an en dash and is fine — see the skill's "constrained formats" note.)

## 7 — Monotone rhythm

**Before:**
> The system processes requests in order. The system validates each request before processing.
> The system logs every request it processes. The system returns a response to the client.

**After (acceptable):**
> Requests arrive in order. Each one is validated, logged, then answered. Nothing skips the queue.

**Fail if:** five or more consecutive sentences of near-identical length and structure.

## 8 — Resume bullet (constrained format)

**Before:**
> Was responsible for leveraging cross-functional collaboration to drive impactful improvements to
> the data pipeline, ultimately resulting in significantly enhanced performance.

**After (acceptable):**
> Rebuilt the data pipeline; cut nightly batch time from 4 hours to 18 minutes.

**Fail if:** the rewrite drops the metric, removes the bullet, or keeps corporate filler ("leverage",
"impactful", "ultimately", "significantly enhanced"). Bullets and a short tech list are allowed here.
