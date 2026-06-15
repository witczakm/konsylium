# konsylium — an AI council that picks its own experts

> One command runs a panel of independent AI perspectives on your decision and returns a single
> verdict **with the dissent kept on the table** — instead of one model’s confident opinion.

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757)
![Codex](https://img.shields.io/badge/Codex-skill-111111)
![Claude desktop](https://img.shields.io/badge/Claude%20app-skill-8a63d2)

A lightweight [Agent Skill](https://support.claude.com/en/articles/12512180-use-skills-in-claude)
for **Claude Code**, **Codex**, and the **Claude / Cowork desktop app**.
🇬🇧 English · 🇵🇱 [polski README](README.pl.md)

*konsylium* (Polish, *“council / consultation”*) — the brand; the idea is an **adaptive** council:
a meta-step reads your question and assembles the right experts **for that question**, rather than a
fixed roster.

---

## See it in action

A real run — *“store bidder PII in the same table as scoring, or split?”* The Marshal didn’t use a
generic panel; it **minted Privacy, Compliance and Data-integrity personas because it read the
question**, and two of them independently caught a requirement an architect-only panel usually misses:

> **Recommendation:** Separate tables **+ an immutable snapshot** of the bidder’s identifying data at
> evaluation time — a plain foreign key isn’t enough, because a later name/ID correction must not
> rewrite the history of a past score.
> **Dissent:** the Pragmatist allowed a single-table MVP for the trivial case; the Skeptic attacked
> the “FK-only” split as false auditability.
> **What we don’t know:** whether contacts are natural persons (privacy regime) …

Full verdict and three more → **[examples/](examples/)**.

## The problem it solves

A single model gives a single, confident answer — and confidently agrees with itself. The expensive
cost in software work is rarely writing the code; it’s **building the wrong thing** and finding out
three sprints later. Review, red-teaming and second opinions fix this — but doing them by hand
(pasting the same prompt into several chatbots, then merging) is slow and easy to skip.

`konsylium` makes that one command, and front-loads the critique **before** you commit.

## What makes it different

| | konsylium | typical “LLM council” |
|---|---|---|
| **Panel selection** | **Adaptive** — a Marshal picks 3–6 personas *per question*, minting domain experts (security, data-integrity, privacy, cost…) | fixed roster |
| **Tools** | one skill across **Claude Code + Codex + desktop app** | usually one surface |
| **Modes** | explicit **advisory** (divergence) vs **gate** (cross-model independence) — never conflated | usually one mode |
| **Output** | recommendation **+ preserved dissent + “what we don’t know”** | merged answer |
| **Rounds** | one blind pass + one synthesis (evidence-based; see limitations) | sometimes N-round debate |

The AI-council idea isn’t new — see [Prior art](#prior-art). The contributions here are the
adaptive Marshal, the cross-tool packaging, and the advisory-vs-gate split.

## How it works (Mode A — advisory, the default)

```
/konsylium <question>
   │
   1. Marshal (P0)   reads the question → picks 3–6 personas for THIS problem
   │                 (guardrails: ≥1 adversary · max 6 · each a different failure mode)
   2. Blind pass     each persona answers in an ISOLATED context, in parallel,
   │                 never seeing the others  ← kills conformity
   3. Anonymize      answers relabeled P1..Pn (no names, no order bias)
   4. Chairman       one verdict: recommendation + where they disagreed (dissent)
                     + "what we don't know" + next step
```

The council is a **divergence pre-check that feeds a decision** — it never closes the decision and is
never a merge gate. **A human decides.**

### Mode B — gate (routing, not reimplementation)

When a call is high-risk and needs *genuine model-family independence*, a council of one provider’s
subagents is not independent. Mode B routes the question to a cross-model consensus tool (e.g.
[`swarm-consensus`](https://github.com/anthropics/skills) or
[`llm-consortium`](https://github.com/irthomasthomas/llm-consortium)), pinning the arbiter to a
different family so *evaluator ≠ generator*. The gate is **upstream to**, never a replacement for, the
human decision. (Mode B is also where you’d *pin* the panel for reproducibility.)

## When to use it

- A non-trivial or hard-to-reverse decision; a contract / interface / invariant; security or cost.
- Choosing between 2–3 alternatives where the answer isn’t obvious.
- You have one option and want it attacked (steelman the opposition).
- Before writing a design doc / ADR — get divergence before locking it.
- The model keeps circling (repeated proposals, failed retries).

**Don’t** use it for trivial/factual questions or pure execution — it’d just burn tokens.
Rule of thumb: *trivial → no; architecture / contract / irreversible → yes.*

## Install

Two language editions ship in the repo — **English** (`skills/konsylium/`) and **Polish**
(`skills/konsylium-pl/`). Pick one; both register the `/konsylium` command.

### Claude Code & Codex (CLI)

```sh
git clone https://github.com/witczakm/konsylium.git && cd konsylium
sh install.sh --dry-run     # preview exactly what it writes — touches nothing
sh install.sh               # English → Claude Code + Codex
# sh install.sh --lang pl   # Polish edition
```

It copies the skill into `~/.claude/skills/konsylium` and `~/.codex/skills/konsylium` (both
auto-discover it; an existing install is backed up, never silently overwritten). New session → `/konsylium`.

### Claude / Cowork desktop app

The app imports a ZIP (it doesn’t read those folders):
**Customize → Skills → “+” → Create skill → upload `dist/konsylium-en.zip`** (or `-pl`), then toggle **ON**.

## Run it from the CLI — and why that matters

```sh
claude -p "/konsylium should we store bidder PII in the same table as scoring?"
codex exec "use the konsylium skill: monolith vs microservices for a 3-person team?"
```

- **Scriptable & automatable** — wire a council into CI, a pre-commit hook, or a cron job (“council
  every architecture ADR before it merges”).
- **Cold, fresh context** — a head-less run isn’t biased by your current chat; closer to a teammate’s read.
- **Parallel & fast** — personas run concurrently; a verdict in ~1–2 min vs an 8-minute paste-to-three-bots loop.
- **Pipeable** — capture to a file (`> verdict.md`) and feed it into your PR, decision log, or ADR.

## Domain persona palette

Beyond the base panel (Architect · Skeptic/Red-Team · Pragmatist · Security · Operator), the Marshal
can mint: **Security/Compliance · Data-integrity · Privacy · Cost/FinOps · Performance/Scale ·
Maintainability**. Add your own in `references/personas.md`.

## Data boundary & privacy

- **The skill makes no network calls and has no telemetry of its own.** It is plain Markdown
  instructions; the only executable is `install.sh` (`sh`/`cp`/`sed`, local only).
- The one outbound path is *you* letting the agent route **Mode B** to a cloud model — your choice.
- **Never put secrets or private/sensitive data in a council prompt.** Mode A’s rules stop Mode B
  cloud routing when the question contains sensitive data; you enforce it for the rest.

See [SECURITY.md](SECURITY.md) for the threat model and how to report issues.

## Honest limitations

This is a thinking aid, not magic:

- **Model-mediated, not deterministic.** The skill *instructs* a blind parallel dispatch; it doesn’t
  hard-enforce it. The same question can yield a different panel/dissent — the point in divergence
  mode, not a bug. For reproducibility, pin the panel in Mode B.
- **No built-in diversity measurement.** Personas can *sound* different yet *think* alike; the
  Marshal’s “different failure mode” guardrail mitigates but doesn’t measure this.
- **Multi-round debate doesn’t help — and can hurt.** Research on multi-agent debate
  ([Should we be going MAD?](https://arxiv.org/abs/2311.17371) and conformity studies) shows more
  rounds don’t reliably beat self-consistency and can flip correct answers to wrong. So konsylium runs
  **one blind pass + one synthesis** — no rounds.
- **Evidence.** The [examples](examples/) are *illustrative single runs*, not a benchmark. A
  before/after eval is on the roadmap; until then, treat the council as structured divergence, not proof.
- **Cost.** A run spawns 3–6 subagents — cheaper than building the wrong thing, pricier than a one-line
  answer. Reserve it for decisions that matter.

## Prior art

`konsylium` stands on a healthy, crowded ecosystem — credit where due:
[karpathy/llm-council](https://github.com/karpathy/llm-council),
[council-review](https://github.com/ngmeyer/council-review),
[council-of-high-intelligence](https://github.com/0xNyk/council-of-high-intelligence),
[llm-consortium](https://github.com/irthomasthomas/llm-consortium),
and Anthropic’s [Agent Skills](https://github.com/anthropics/skills).

## Contributing & changelog

PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) (one rule that matters: **keep the EN and PL
editions in parity**; CI enforces it). History in [CHANGELOG.md](CHANGELOG.md).

## License

MIT © 2026 Michał Witczak. Forks and contributions welcome.
