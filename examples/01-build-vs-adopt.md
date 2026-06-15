# Council verdict: build our own council skill vs adopt an existing one

> Illustrative single run · 2026-06-15 · Mode A · Panel: Architect · Skeptic · Pragmatist · Security guardian

**Question:** Should we adopt an existing third-party council skill instead of maintaining our own
small one we already built?

---

## Recommendation

**Keep the small owned skill — and graft one idea (diversity measurement) from the alternative.**
Three of four perspectives converged on "keep"; the lone "adopt" voice partly defeated itself: if
the external skill is similar in size, auditing it for a clean-room project costs about what writing
it did — which erases the "maturity for free" argument. The decider is cost asymmetry: the owned
skill already works (marginal cost ≈ editing Markdown), while adoption is a recurring expense
(audit + version pinning + adapting a fixed roster) for marginal functional gain.

## Where they disagreed (dissent)

- **Skeptic vs the rest (the only real split):** the Skeptic argued the owned skill is NIH liability —
  the quality mechanism (anonymization, shuffling, *diversity measurement*) is subtler than it looks,
  and without measuring persona diversity you risk "consensus theater." This **survived** as the
  strongest pro-adopt point and became a backlog item.
- The "keep" camp reached the same verdict from different angles (clean-room control, 1:1 mapping of
  personas to in-house roles, distribution hygiene).

## What we don't know / what we trade off

- **[TO CHECK]** Whether the owned skill has silent quality bugs — every persona, including the
  "keep" voters, named this as its own weakness. Only one real run had been done at the time.
- We knowingly forgo the alternative's extra modes and community maintenance.

## Next step

Keep the skill; add a "measure persona diversity" task; revisit adoption only if real usage exposes
quality gaps.

---

*The council is a divergence pre-check, not a gate. A human makes the decision.*
