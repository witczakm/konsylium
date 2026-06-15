---
name: konsylium
description: Internal AI council of many perspectives. A "Marshal" meta-step reads the question and assembles a 3–6 persona panel (architect, skeptic/red-team, pragmatist, plus domain personas like security, data-integrity, cost, performance), queries each independently (blind), then synthesizes one verdict that preserves dissent and an explicit "what we don't know" section. Use when facing a non-trivial or hard-to-reverse decision, choosing between 2–3 alternatives, stress-testing a single option you already lean toward, writing a design doc/ADR, or when the model keeps circling. It is a divergence PRE-CHECK that feeds your decision — never the merge gate (a human decides). For a genuinely independent cross-model gate it routes to a multi-model consensus tool instead of faking independence with one provider.
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
Sharpen the question in 1–2 sentences. Then run the **Marshal (P0, `references/personas.md`)**
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
answers.** Dispatch them in parallel. Each returns: position + 2–3 strongest arguments +
1 weakness of its own stance.

### 3. Anonymize
Collect the answers and label them P1..Pn (no persona names, no rank-revealing order).
This removes order/brand bias before synthesis.

### 4. Chairman synthesis (with a dissent quota)
In a fresh pass, read P1..Pn as data and write the verdict per `assets/OUTPUT_TEMPLATE.md`:
- **Recommendation** (one, assertive, justified),
- **Where they disagreed** (a real dissent quota — name which perspective held the minority view),
- **What we don't know / what we trade off** (lead with the unresolved, not a confident consensus),
- **Next step**.
If the panel split ~50/50, **say so** — don't fake consensus.

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

Mode B only routes. It does not fake independence and does not copy those tools' logic.

---

## Hard rules

- **Pre-check, not a gate.** Mode A never gates a merge — a human decides.
- **Never send private/sensitive data to a cloud model.** If the question contains it → stop,
  keep it local, Mode B routing to cloud is blocked.
- **No secrets** in persona/external prompts. Don't echo or log them.
- **Light, no rounds.** One blind pass + one synthesis. No N-round debate — evidence shows more
  rounds don't improve quality and invite conformity (see README "Honest limitations").
- **Real diversity > count.** 3–4 well-chosen personas beat 8 similar ones.
- **Honest dissent.** A 50/50 split is stated plainly; false consensus is worse than "we don't know."

## Related

- A cross-model consensus skill (e.g. `swarm-consensus`) — Mode B engine.
- Feed the verdict into your own decision/ADR process — the council opens, it doesn't close.
