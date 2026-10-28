# Council verdict: <topic>

**Question:** <one-sentence statement of what we're deciding>
**Personas:** <e.g. Architect, Skeptic, Pragmatist, Security> · **Mode:** A (advisory) / B (cross-model)
**Actual models:** <voice → model from the log, e.g. P1 claude-opus-5-5 · P2 gpt-5.4 · P3 gemini-2.5-pro; DEGRADATION: <which role lacks a second family and why>>
**Date:** <YYYY-MM-DD HH:MM from `date`> · **Trigger:** <on request / 3rd NO round of gate <name> / ADR>
**Numbers:** <recomputed on the data: yes (command) / n/a; mismatches: "P3 said 157, measured 215">
**Votes** *(option choice only)*: <persona → option · confidence/100, …> · **Cross-ranking:** <P2 > P1 > P3> · **Confrontation:** <no / yes (threshold <60 % / contradicting fact)>
**Synthesis confidence:** <high / medium / low + one sentence why>
**Outcome after the fact:** <fill in when the decision closes: recommendation right / wrong / partly — one sentence on what; until then: [OPEN]>

---

## Recommendation

<ONE assertive recommendation with justification ("why this is best here and now").
Not a list of options without a verdict.>

## Where they disagreed (dissent — at least 1 real divergence)

Label each as a **value tension** (both valid — a trade-off) or an **error catch** (a real flaw the others missed).

- **<perspective> vs <perspective>** — *(value tension / error catch)*: <what the disagreement is and what follows>
- <another, if any>

> If the panel split ~50/50, say so plainly here. Do not force a consensus.

## What we don't know / what we trade off

- <an assumption that wasn't verified — [TO CHECK]>
- <a cost/risk the recommendation knowingly accepts>
- <an open question that remains>

## Next step

<usually: feed this into your decision/ADR process; or: gather the missing evidence;
or: high-risk → Mode B (cross-model consensus / second opinion)>

---

*The council is a divergence pre-check, not a gate. A human makes the decision.*
