# Evals — does the council actually add value?

The deepest fair objection to any AI council is: *“nice prose, but is it better than just asking
once?”* This is an honest attempt to answer that — small, transparent, and deliberately **not**
self-congratulatory.

## TL;DR

On 5 real decisions, compared head-to-head with a single-pass answer:

| # | Decision | Single-pass got it…? | What the council added | Value |
|---|---|---|---|---|
| 1 | Build vs adopt a council skill (clean-room) | right conclusion | the surviving counter-argument (NIH risk) + a concrete action item (measure persona diversity) | 🟡 moderate |
| 2 | Store bidder PII in the same table as scoring? | mostly | the specific failure mode a single pass missed: **a plain FK is not enough → immutable snapshot** of identity at scoring time | 🟢 strong |
| 3 | Bash vs Python for a one-off script | **fully** | essentially nothing — the single pass already covered the dissent | ⚪ marginal |
| 4 | How to release this OSS project | generic-good | the meta-judgment: *what NOT to do* (governance theater) + naming the **evidence gap** as the deepest risk | 🟡 moderate |
| 5 | How to make the README world-class | generic-good | the restraint call: *honesty is the moat, don’t over-polish into hype* + name-barrier | 🟡 moderate |

**Honest pattern:** the council earns its cost on (a) decisions with **domain-specific failure
modes** and (b) **judgment / trade-off** calls where the *surviving dissent* and *what-not-to-do*
matter. It adds little on **simple, well-bounded** technical questions — a single strong model is
already enough there. Use it accordingly (this matches the skill’s own “when to use / skip” guidance).

## Method

- **Baseline:** one model, one shot, ~120 words, no council (“give your recommendation + key reasons”).
- **Council:** a `/konsylium` Mode-A run (Marshal picks the panel; blind pass; chairman synthesis).
- **Delta:** what the council surfaced that the baseline did *not*. Scored 🟢 strong / 🟡 moderate / ⚪ marginal.
- All 5 are **real runs** that happened while building this project — not constructed for the eval.

## The interesting cases

**#2 — the clearest win (🟢).** Both baseline and council said *“separate tables.”* The baseline even
gestured at versioning evaluations. But it stopped at *“link by foreign key.”* The council’s
data-integrity and compliance personas independently flagged that a **plain FK is insufficient** —
a later name/tax-ID correction or a duplicate-merge would silently **rewrite the history of a past
score** — so the score record needs an **immutable snapshot** of the bidder’s identity at evaluation
time. That’s a concrete, audit-relevant failure mode a competent single pass missed. This is the kind
of decision the council is *for*.

**#3 — the honest null result (⚪).** “Bash vs Python for a one-off script.” The single-pass answer was
already complete — it recommended Python, gave the dry-run safety point, and even the “one-liner → Bash”
nuance that the council later raised as dissent. The council added **nothing of value** here and cost
3–6× the tokens. Reporting this matters: a tool that claims to always help is not credible.

**#1, #4, #5 — moderate (🟡).** The baselines were good. The council’s value was not a different
conclusion but a sharper one: it surfaced the **strongest surviving objection** (#1: the NIH/“you’re
maintaining a worse engine” critique, plus a measure-diversity action item), and the **meta-judgment**
about what *not* to do (#4: avoid governance theater; name the unproven-value gap as the real risk; #5:
keep the honest limitations as the differentiator rather than polishing into hype). Useful, but a
careful operator might reach similar places by asking good follow-up questions.

## What this eval is **not**

- **Not a benchmark.** n=5, single runs, model-mediated and non-deterministic — a different run could
  produce a different panel and a different delta.
- **Baselines weren’t perfectly blind.** Baseline #1 had access to repo context, so its delta is
  *understated* (the council’s edge there is conservative).
- **Author-run.** These were scored by the project author, not an independent grader.
- It measures *“did the council surface something the single pass missed,”* not decision *outcomes* over
  time (which would need real-world follow-up).

## Takeaway

The council is **structured divergence, not an oracle.** On this small sample it paid off clearly once,
moderately three times, and not at all once — and the misses are predictable: simple, bounded questions
don’t need a panel. That’s the honest case for using it selectively, exactly where the skill says to.

*Want to extend this? Run your own 5 decisions, drop the baseline-vs-council deltas in a PR, and we’ll
grow the table.*
