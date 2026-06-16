# konsylium — an AI council that picks its own experts

> Hand one command your hardest decision. A **Marshal** assembles the right experts *for that
> question*, interrogates them independently, and returns one verdict — with the disagreement kept
> on the table, not averaged away.

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![CI](https://github.com/witczakm/konsylium/actions/workflows/validate.yml/badge.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757)
![Codex](https://img.shields.io/badge/Codex-skill-111111)
![Claude app](https://img.shields.io/badge/Claude%20app-skill-8a63d2)

**konsylium** (Polish, *“council”*) is an [Agent Skill](https://support.claude.com/en/articles/12512180-use-skills-in-claude)
for **Claude Code**, **Codex**, and the **Claude / Cowork desktop app** — for engineers facing
hard-to-reverse architecture, contract, or trade-off calls.
🇬🇧 English · 🇵🇱 [polski README](README.pl.md)

![konsylium demo — a real Mode A run](assets/konsylium-demo.svg)

<details>
<summary><b>Contents</b></summary>

- [Quickstart](#quickstart)
- [See it in action](#see-it-in-action)
- [Why konsylium](#why-konsylium)
- [How it works](#how-it-works)
- [When to use it](#when-to-use-it)
- [Install](#install)
- [How it fits your tools](#how-it-fits-your-tools)
- [CLI usage](#cli-usage)
- [Data boundary and privacy](#data-boundary-and-privacy)
- [Honest limitations](#honest-limitations)
- [Evidence and roadmap](#evidence-and-roadmap)
- [Prior art](#prior-art)
- [Contributing, changelog, license](#contributing-changelog-license)

</details>

## Quickstart

```sh
git clone https://github.com/witczakm/konsylium.git && cd konsylium && sh install.sh
```

Then, in a **new Claude Code session**:

```
/konsylium <your hardest open decision>
```

You get a recommendation, the **dissent** between perspectives, and an honest **“what we don’t know.”**
Codex, the desktop app, and the Polish edition → [Install](#install).

## See it in action

A real run — *“store bidder PII in the same table as scoring, or split?”* The Marshal didn’t use a
generic panel; it **minted Privacy, Compliance and Data-integrity personas because it read the
question** — and two of them independently caught a requirement an architect-only panel usually misses:

> **Recommendation:** Separate tables **+ an immutable snapshot** of the bidder’s identifying data at
> evaluation time — a plain foreign key isn’t enough, because a later name/ID correction must not
> rewrite the history of a past score.
> **Dissent:** the Pragmatist allowed a single-table MVP for the trivial case; the Skeptic attacked
> the “FK-only” split as false auditability.
> **What we don’t know:** whether the contacts are natural persons (privacy regime) …

Full verdict and three more decisions → **[examples/](examples/)**.

## Why konsylium

A single model gives a single, confident answer — and confidently agrees with itself. The expensive
cost in software is rarely the code; it’s **building the wrong thing** and finding out three sprints
later. Review and second opinions fix that — but pasting the same prompt into three chatbots and
merging the replies by hand is slow, so it gets skipped.

`konsylium` makes it one command, and front-loads the critique **before** you commit.

| | konsylium | a typical “LLM council” |
|---|---|---|
| **Panel** | **adaptive** — chosen *per question*, mints domain experts | fixed roster |
| **Tools** | one skill across **Claude Code + Codex + desktop app** | usually one surface |
| **Modes** | explicit **advisory** vs **independent gate** — never conflated | usually one |
| **Output** | recommendation **+ preserved dissent + “what we don’t know”** | merged answer |
| **Rounds** | one blind pass + one synthesis (evidence-based) | sometimes N-round debate |

## How it works

```
/konsylium <question>
   │
   1. Marshal (P0)   reads the question → picks 3–6 personas for THIS problem
   │                 (guardrails: ≥1 adversary · max 6 · each a different failure mode)
   2. Blind pass     each persona answers in an ISOLATED context, in parallel,
   │                 never seeing the others  (prevents conformity)
   3. Anonymize      answers relabeled P1..Pn (no names, no order bias)
   4. Chairman       one verdict: recommendation + where they disagreed (dissent)
                     + "what we don't know" + next step
```

It is a **divergence pre-check that feeds a decision** — never a merge gate. A human decides.
**Non-deterministic by design** (divergence is the point); pin the panel in Mode B for reproducibility.

### Mode B — independent gate (routing)

When a call needs *genuine model-family independence*, a council of one provider’s subagents isn’t
independent. Mode B routes the question to a cross-model consensus tool (e.g.
[`swarm-consensus`](https://github.com/anthropics/skills) or
[`llm-consortium`](https://github.com/irthomasthomas/llm-consortium)), pinning the arbiter to a
different family so *evaluator ≠ generator*. The gate is **upstream to**, never a replacement for, the
human decision.

## When to use it

- A hard-to-reverse decision; a contract / interface / invariant; security or cost.
- Choosing between 2–3 alternatives where the answer isn’t obvious.
- You have one option and want it attacked (steelman the opposition).
- Before a design doc / ADR — get divergence before locking it.
- The model keeps circling (repeated proposals, failed retries).

**Skip it** for trivial/factual questions or pure execution — it’d just burn tokens.

## Install

**Requirements:** Claude Code or Codex CLI (or the Claude desktop app). Model-agnostic — it uses
whatever your CLI is configured with. Two editions ship in the repo: English (`skills/konsylium/`)
and Polish (`skills/konsylium-pl/`); both register the `/konsylium` command.

```sh
sh install.sh --dry-run     # preview exactly what it writes — touches nothing
sh install.sh               # English → Claude Code + Codex
```

An existing install is backed up, never silently overwritten. New session → `/konsylium`.

<details>
<summary><b>Codex, the desktop app, and the Polish edition</b></summary>

- **Polish edition:** `sh install.sh --lang pl`
- **Only one tool:** `--claude-only` or `--codex-only`
- **Claude / Cowork desktop app** (it imports a ZIP, it doesn’t read those folders):
  Customize → Skills → **“+” → Create skill** → upload `dist/konsylium-en.zip` (or `-pl`) → toggle **ON**.

</details>

## How it fits your tools

- It’s a **Skill** (Markdown instructions Claude follows), **not an MCP server** — no daemon, no
  transport, nothing to run. The `/konsylium` trigger is the skill’s own invocation.
- Each persona runs in its **own isolated subagent context**; only the final synthesis returns to your
  main thread — your context stays clean.
- **Skills don’t sync across surfaces.** Claude Code, Codex and the app are three independent copies;
  update = re-install (or re-import the ZIP) per surface.

## CLI usage

```sh
claude -p "/konsylium should we store bidder PII in the same table as scoring?"
codex exec "use the konsylium skill: monolith vs microservices for a 3-person team?"
```

- **Scriptable** — wire a council into CI, a pre-commit hook, or a cron job.
- **Cold, fresh context** — a head-less run isn’t biased by your current chat.
- **Parallel & fast** — personas run concurrently; a verdict in ~1–2 minutes.
- **Pipeable** — `> verdict.md` and drop it into your PR, decision log, or ADR.

## Data boundary and privacy

- **The skill makes no network calls and has no telemetry of its own** — it’s plain Markdown; the
  only executable is `install.sh` (`sh`/`cp`/`sed`, local).
- The one outbound path is *you* letting the agent route **Mode B** to a cloud model — your choice.
- **Never put secrets or private/sensitive data in a council prompt.**

Threat model and disclosure → [SECURITY.md](SECURITY.md).

## Honest limitations

- **Model-mediated, not deterministic.** The skill *instructs* a blind parallel dispatch; it doesn’t
  hard-enforce it. The same question can yield a different panel — the point in divergence mode. Pin in Mode B.
- **No built-in diversity measurement.** Personas can *sound* different yet *think* alike; the Marshal’s
  “different failure mode” guardrail mitigates but doesn’t measure this.
- **Multi-round debate doesn’t help — and can hurt.** Research on multi-agent debate
  ([Should we be going MAD?](https://arxiv.org/abs/2311.17371) and conformity studies) shows more
  rounds don’t reliably beat self-consistency and can flip correct answers to wrong. So konsylium runs
  one blind pass + one synthesis — no rounds.
- **Cost.** A run spawns 3–6 subagents — cheaper than building the wrong thing, pricier than a one-line
  answer. Reserve it for decisions that matter.

## Evidence and roadmap

A first **[head-to-head eval](EVALS.md)** pits the council against single-pass answers on 5 real
decisions — and reports it honestly: it clearly helped once, moderately three times, and **not at all
once** (simple, bounded questions don’t need a panel). The [examples](examples/) are illustrative single
runs, not a benchmark. Treat the council as structured divergence, not an oracle. Extending the eval
with your own decisions (as a PR) is the roadmap.

## Prior art

<details>
<summary>konsylium stands on a healthy, crowded ecosystem — credit where due</summary>

[karpathy/llm-council](https://github.com/karpathy/llm-council) ·
[council-review](https://github.com/ngmeyer/council-review) ·
[council-of-high-intelligence](https://github.com/0xNyk/council-of-high-intelligence) ·
[llm-consortium](https://github.com/irthomasthomas/llm-consortium) ·
Anthropic’s [Agent Skills](https://github.com/anthropics/skills).

The distinctive parts here are the **adaptive Marshal**, the **cross-tool packaging**, and the
explicit **advisory-vs-gate** split.

</details>

## Contributing, changelog, license

PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) (one rule that matters: **keep the EN and PL
editions in parity**; CI enforces it). History in [CHANGELOG.md](CHANGELOG.md).

MIT © 2026 Michał Witczak.
