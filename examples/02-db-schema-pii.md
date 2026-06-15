# Council verdict: store bidder PII in the same table as scoring, or separate?

> Illustrative single run · 2026-06-15 · Mode A · **Panel chosen by the Marshal for this question:**
> Domain Architect (DDD) · Data-integrity / temporal audit · Privacy · Compliance · Pragmatist · Skeptic/Red-Team

This run is the clearest demonstration of the **adaptive Marshal**: a database-schema question that
touches personal data and a regulated process caused the Marshal to mint *Privacy*, *Compliance* and
*Data-integrity* personas — none of which a generic architect/skeptic/pragmatist trio would include.

**Question:** Should bidder data (tax ID, company name, contact people) live in the same table as the
offer scoring/evaluation, or be split into separate tables?

---

## Recommendation

**Separate into distinct tables — and store an immutable snapshot of the bidder's identifying data
at evaluation time.** Bidder ≠ Offer ≠ Score are three entities with different lifecycles and
cardinalities; merging them creates classic update/insert/delete anomalies. Minimum shape:
`bidders` · `bidder_contacts` (PII, separate access + retention) · `offers` (with an immutable
identity snapshot) · `offer_scores` (append-only / versioned, with criteria, weights, timestamp).

**The decisive insight — surfaced independently by the Data-integrity and Compliance personas:** a
plain foreign key to the bidder is **not enough**. A later name/tax-ID correction or duplicate merge
must not rewrite the history of a past evaluation, so the score record needs a frozen snapshot. An
architect-only panel typically misses this; the domain personas caught it because the Marshal put
them in the room.

## Where they disagreed (dissent)

- **Pragmatist vs the rest:** the Pragmatist allowed a single table as a stage-0 MVP — but only for a
  trivial case (one-off import, no history, no contact workflow).
- **Skeptic vs "FK-only split":** the Skeptic accepted splitting but attacked the "just an FK" variant
  — it creates *false auditability* if master data can change. This sharpened the snapshot requirement.

## What we don't know / what we trade off

- **[TO CHECK]** Whether "contact people" are natural persons (full privacy regime) or just a legal
  entity's contact data — changes the privacy weight (but modeling + compliance still favor separation).
- We accept more joins and migration complexity for integrity and auditability.

## Next step

Adopt separation as the direction; settle the minimal schema and the snapshot scope before implementing.

---

*The council is a divergence pre-check, not a gate. A human makes the decision.*
