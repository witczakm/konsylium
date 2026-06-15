# Council verdict: how to release this project professionally

> Illustrative single run · 2026-06-16 · Mode A · **Panel chosen by the Marshal:**
> OSS Maintainer · Developer Experience / Docs · Adoption / Growth · Skeptic / Red-Team · Security / License

A **non-code, strategic** question — the council works on more than architecture. (This very run shaped
the release you're reading; the gallery and positioning below came out of it.)

**Question:** What should we improve/add to make this GitHub release professional and genuinely
valuable to other developers?

---

## Recommendation

**"Professional" here = a killer worked example + proof + sharp positioning + light trust signals —
NOT a pile of governance files.** All five personas independently warned (in their own-weakness note)
that heavy CI/CODEOWNERS/SHA-manifests are *process theater* for a ~12 KB Markdown skill and would
deter lightweight adopters. Highest-leverage, in order:

1. **Extract to a standalone repo** (out of any private monorepo) — prerequisite for stars/issues/trust.
2. **Show a real verdict in the README + an `examples/` gallery** — developers judge by output, not
   prose; an example also *proves* the adaptive-Marshal claim. (This gallery is that step.)
3. **Sharpen positioning** — lead with the true differentiator: *"an AI council that picks its own
   experts — adaptive panel per question"*; add a comparison table; keyword-first description + topics.
4. **Light trust signals** — explicit "no telemetry / no network by the skill," a prominent data
   boundary, a harden-ed installer (dry-run, no silent overwrite).
5. **Versioning** — a semver tag + a GitHub Release with the ZIPs as assets + a CHANGELOG.

## Where they disagreed (dissent)

- **Skeptic vs design (determinism):** "same prompt → different panel" undermines trust for the *gate*
  use case → offer opt-in panel pinning. Resolution: opt-in determinism for Mode B only; keep Mode A
  divergent.
- **Growth vs brand (name):** "konsylium" is hard to search for an English audience → keyword-first
  repo description; keep the memorable brand. Compromise adopted.
- **Skeptic's deepest cut:** there's no *evidence* the council improves decisions. Real gap, not
  cosmetic → an evidence/eval track is on the roadmap; the examples are explicitly labeled illustrative.

## What we don't know / what we trade off

- **[TO CHECK]** How much proof is "enough" — no-eval is the norm for this whole skill category, so the
  bar is genuinely unsettled.
- **[TO CHECK]** Whether renaming helps or dilutes the brand (panel: medium confidence).

## Next step

Ship Tier 1 (this repo's current state), then consider a lightweight before/after eval.

---

*The council is a divergence pre-check, not a gate. A human makes the decision.*
