---
name: konsylium
description: >-
  Use for a non-trivial or hard-to-reverse decision (architecture, contract/interface, security,
  cost, migration), when choosing between 2–3 alternatives, when stress-testing an option you
  already lean toward, when writing a design doc/ADR, or when the model or the user keeps circling
  (2+ failed attempts, repeated proposals). Do NOT use for trivial/factual questions, pure
  execution ("just do it"), or as a merge gate — the council is a divergence PRE-CHECK and a human
  decides. For a gate that needs independent model families → Mode B (cross-model routing).
version: 2.1.0
---

# /konsylium — internal AI council of many perspectives

## Purpose

Give one command that, in-session, runs a parallel council of perspectives on a
question and returns a single verdict with dissent preserved — instead of a single
confident opinion, and without manually pasting the same prompt into several chatbots.

The expensive cost in software work is rarely writing the code — it is **building the
wrong thing**. A council front-loads the critique (architect, skeptic, pragmatist,
domain experts) so the flaw surfaces *before* you commit, not three sprints later.

The council is a **divergence pre-check that feeds a decision** — it does not close the
decision and is never a merge gate. A human decides.

## When to use

- A non-trivial, hard-to-reverse decision; a contract/interface/invariant; security/cost.
- Choosing between 2–3 technical alternatives where the answer isn't obvious.
- You have one option and want it attacked (steelman the opposition).
- You're about to write a design doc / ADR and want divergence before locking it.
- The model (or you) keeps circling — repeated proposals, 2+ failed retries.

**Hard trigger (not discretionary):** the third NO round from the same gate in the same error
class = run the council BEFORE the fourth round, without asking. Why: in the project where this was
measured, the "keeps circling" description fired neither at 11 NO rounds nor at 6 — the council ran
only when a human ordered it. Count rounds in the session log; the third one = dispatch.

## When NOT to use

- Trivial / factual questions → answer directly. Don't burn subagents.
- Pure execution ("just do it") → run it.
- A merge gate that needs genuinely independent model families → that is Mode B (below),
  not Mode A. A council of one provider's subagents is not independent.

Rule of thumb: **trivial → no. Architecture / contract / irreversible → yes.**

---

## Mode A — advisory / divergence (DEFAULT)

In-session subagents, cheap. Four steps. **Don't skip step 1 (panel), 2 (blind) or 4 (dissent).**

### 1. Framing + Marshal (adaptive panel selection)
The framing has FOUR required fields — if one is missing, don't dispatch (a persona without them
guesses, and guesses the same way you do):

```
QUESTION:           <1–2 sentences: what we are deciding>
WHAT ALREADY EXISTS: <code / data / documents the panel must know; paths or quotes — not "see the repo">
DECISION-MAKER'S POSITION: <what the owner / counsel / client has already decided and is not up for negotiation>
SOURCE NUMBERS:     <every number the panel should rely on, with its origin; "none" if there are none>
```
Why the middle two: a panel that didn't know the existing knowledge base produced a verdict that had
to be thrown out; a panel that didn't know counsel's position advised "don't build" something the
decision-maker had already approved. Why the last one: a voice that "counted" requirements itself
reported 157 instead of 215.

Then run the **Marshal (P0, `references/personas.md`)**
— a meta-persona that reads the CONTENT of the question and assembles a **3–6 persona panel**
that covers the failure modes specific to *this* problem, instead of a generic four. The
Marshal may (a) pick from the base personas P1–P5, or (b) **mint ad-hoc domain personas**
(e.g. Security/Compliance, Data-integrity, Privacy, Cost/FinOps, Performance/Scale — see the
palette in personas.md).

**Hard guardrails:** always ≥1 adversary (Skeptic/Red-Team); max 6 personas; each persona
covers a DIFFERENT failure mode (no overlap); one-line "why" per persona.
**Fast path:** for an obvious, narrow question the Marshal just returns P1–P3.
Show the chosen panel + justifications briefly, then dispatch (step 2).

### 2. Blind first pass (anti-conformity #1)
Run each persona from the Marshal's panel as a **separate subagent in an isolated context**.
Each receives: the question + framing + ITS OWN persona prompt. **None sees the others'
answers.** In Claude Code: **all dispatches in ONE tool-call block** (one message = true
parallelism). Each returns: position + 2–3 arguments + 1 weakness of its own stance +
**confidence 0–100** + **actual model** + **numbers: recomputed / from framing / own**
(full return spec: the common tail in `references/personas.md` — append it to every persona).
Model tier (optional, cost): domain personas → a cheaper model; adversary and architect
→ the session model. For an "option A vs B" choice the Marshal assigns stances: ≥1 persona FOR,
≥1 AGAINST (forces divergence instead of convergence to the average).

### 3. Anonymize + number check + cross-ranking
Collect the answers and label them P1..Pn (no persona names, no rank-revealing order).
This removes order/brand bias before synthesis.

**Number check (mandatory):** every number a voice marks as "own" must be recomputed on the data
(script/grep/wc) BEFORE it reaches the synthesis; a mismatch goes into the verdict as "P3 said 157,
measured 215". A voice built on a wrong number counts with confidence 0.

**Cross-ranking (default, cheaper than confrontation):** send each persona the anonymized positions
of the OTHERS (shuffled order) with one instruction: "rank from best to worst justified; name the
strongest argument from someone else that you didn't have". The chairman receives the aggregated
ranking + those arguments. Nobody changes their own position (this is not a debate).
Pattern: llm-council (Karpathy) — ranking gives a weighting signal without a debate round's conformity.

### 4. Chairman synthesis (with a dissent quota)
In a fresh pass, read P1..Pn as data and write the verdict per `assets/OUTPUT_TEMPLATE.md`.
Chairman ≠ participant: it does not vote. High-stakes → a fresh subagent (clean context) may do the synthesis.

Aggregate by question type:
- **choice between options (A/B/C)** → first a tally of confidence-weighted votes (an input, not a ruling),
- **open/design question** → narrative synthesis (no voting — arguments count).

The verdict contains:
- **A header with the actual models** per voice (from the log/`--version`, not from configuration) — in
  Mode B a missing second model family is a **DEGRADATION written in the header**, not a silent substitution,
- **Recommendation** (one, assertive, justified),
- **Where they disagreed** (a real dissent quota — at least one genuine divergence; name which
  perspective held the minority view, and label each as a *value tension* (both valid — a trade-off)
  or an *error catch* (a real flaw the others missed)),
- **What we don't know / what we trade off** (lead with the unresolved, not a confident consensus),
- **Next step**.
If the panel split ~50/50, **say so** — don't fake consensus.
**Verdict ALWAYS to a file:** `docs/reports/konsylium/YYYY-MM-DD-<topic>.md` (outside a repo:
`~/audits/<date>-konsylium-<topic>/SYNTEZA.md`) — also for inline runs, also for a quick 3-persona run.
A verdict that lives only in chat or a log is a verdict you can't later check against the outcome.
The file has an `Outcome after the fact:` field to fill in when the decision closes (panel calibration).

### 5. Confrontation (CONDITIONAL — only below a threshold)
Run it ONLY if, after cross-ranking: (a) there is no confidence-weighted majority ≥ 60 % for a choice
between options, OR (b) two voices with confidence ≥ 70 contradict each other on a fact (not on values).
A numeric criterion, not "feels split" — pattern: llm-consortium (confidence threshold + iteration cap).
**Max 1 round** — research shows further rounds add conformity, not quality.
Mechanics: each persona gets the **anonymized** positions of the others (A/B/C, shuffled order)
+ the instruction: "name the strongest argument from someone else; what do you change, what do you
keep, and why — **change your mind only because of an argument, never because of headcount**".
After the round: re-synthesize (step 4). Still disputed → **escalate to a human**, not another round.

### After the verdict: nudge (optional)
The user may challenge one persona's assumption. Then re-run ONLY that persona (with its original
answer + the counter-argument): "what do you change / what do you keep, and why".
Cheaper than a new council; append the result to the verdict as an annex.

---

## Mode B — gate / evaluator (ROUTING, not reimplementation)

When the decision is high-risk and needs **genuine model-family independence** (a merge gate,
an irreversible call), do NOT do it with one provider's subagents. Instead:
1. Prepare a self-contained question (context + ≤5 questions + expected answer format).
2. Route it to a cross-model tool:
   - automated cross-model consensus → e.g. the `swarm-consensus` skill, or `llm-consortium`
     (different families; pin the arbiter to a non-member family so evaluator ≠ generator),
   - or a manual cross-AI second opinion (paste to a different vendor's model).
3. The gate result is **upstream to**, never a replacement for, the human decision.
4. **Run per `references/cli-recipes.md`** (flags, isolation, time limit per CLI) — the first run
   of an external CLI broke in 3 out of 3 runs without a recipe.
5. **Actual model from the log**: each voice records which model really answered (CLI banner,
   `--version`, response header). The configuration promised GPT in 8 roles, kimi-k3 answered via
   Ollama — and no report raised it. A same-family substitution = degradation in the verdict header.
6. **Data for an external CLI = a read-only copy** (`cp -R` + `chmod -R a-w`), never the live
   package — sessions with their working directory in the live folder wrote into it.

Mode B only routes. It does not fake independence and does not copy those tools' logic.

---

## Hard rules

- **Answer in the user's language.** Write the verdict — and have each persona answer — in the same
  language as the question (a Polish question gets a Polish verdict).
- **Pre-check, not a gate.** Mode A never gates a merge — a human decides.
- **Never send private/sensitive data to a cloud model.** If the question contains it → stop,
  keep it local, Mode B routing to cloud is blocked.
- **No secrets** in persona/external prompts. Don't echo or log them.
- **Light by default.** 1 blind pass + 1 synthesis. Confrontation (step 5) only on a real split and
  max 1 round — an N-round debate doesn't improve quality and invites conformity (Smit 2024;
  Wynn 2025 "Talk Isn't Always Cheap": agents abandon CORRECT answers under peer pressure).
- **Real diversity > count.** 3–5 well-chosen personas beat 8 similar ones; beyond 5–6 only the
  correlation of errors grows ("Nine Judges, Two Effective Votes" 2026).
- **Honest dissent.** A 50/50 split is stated plainly; false consensus is worse than "we don't know."
- **Honest epistemics.** A panel of one model's personas = diversity of perspectives, NEVER an
  "independent assessment" — the model's shared misconceptions pass through every persona.
  Mode B doesn't give full independence either: when two models from different vendors are wrong,
  ~60 % of the time they pick THE SAME error (Kim et al., ICML 2025). Agreement between voices is
  weaker evidence than a test or a measurement — settle a disputed fact with a fact, not a vote count
  ("Debate or Vote", NeurIPS 2025: the gain comes from voting, not from debate itself).

## Related

- A cross-model consensus skill (e.g. `swarm-consensus`) — Mode B engine.
- Feed the verdict into your own decision/ADR process — the council opens, it doesn't close.
