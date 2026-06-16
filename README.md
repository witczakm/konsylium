# konsylium — a few AI opinions instead of one

> A hard call? Instead of one AI answer, you get a **panel of advisors** with different viewpoints —
> each judges it on its own, and you get a single conclusion with the disagreements clearly flagged.

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![CI](https://github.com/witczakm/konsylium/actions/workflows/validate.yml/badge.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757)
![Codex](https://img.shields.io/badge/Codex-skill-111111)
![Claude app](https://img.shields.io/badge/Claude%20app-skill-8a63d2)

Think of a **medical board**: several specialists look at one case separately, then someone distils
their views into a single conclusion. Here, AI does it. Works in **Claude Code**, **Codex**, and the
**Claude app**.
🇬🇧 English · 🇵🇱 [polski README](README.pl.md)

![konsylium — how it works](assets/konsylium-demo.svg)

<details>
<summary><b>Contents</b></summary>

- [Quick start](#quick-start)
- [See an example](#see-an-example)
- [Why?](#why)
- [How it works](#how-it-works)
- [When it helps (and when it doesn't)](#when-it-helps-and-when-it-doesnt)
- [Install](#install)
- [Also from the terminal](#also-from-the-terminal)
- [Privacy & safety](#privacy--safety)
- [Honestly: what it does NOT do](#honestly-what-it-does-not-do)
- [Does it actually work?](#does-it-actually-work)
- [What it builds on (credits)](#what-it-builds-on-credits)
- [Contributing & license](#contributing--license)

</details>

## Quick start

```sh
git clone https://github.com/witczakm/konsylium.git && cd konsylium && sh install.sh
```

Then, in a **new Claude Code session**:

```
/konsylium <the hardest decision you need to make>
```

You get: one recommendation, a clear "where the advisors disagreed", and an honest "what we still don't
know". Codex and the desktop app are covered below.

## See an example

Someone asked how to design a database (where to keep customer data). Instead of a single answer,
konsylium assembled advisors for **privacy, compliance and data integrity** — and two of them
independently caught something a plain answer would miss:

> **Recommendation:** split the data into separate tables and store a "snapshot" of the data as it was
> at decision time — because a later name correction must not rewrite the history of an earlier decision.
> **Where they differed:** one advisor allowed a simpler start; another pushed back hard on it.
> **What we don't know:** whether these are personal data (then GDPR applies)…

Full verdict and three more decisions → **[examples/](examples/)**.

## Why?

A single AI answer sounds confident — and usually agrees with itself. But the costliest mistake isn't a
bug in the code; it's **building the wrong thing** and realizing it too late. A second opinion helps, but
manually asking several models and stitching the answers together is tedious enough that most people skip
it. konsylium does it in one command — and surfaces the weak spots in your decision **before** you commit.

## How it works

Four simple steps, in plain terms:

1. **Pick the panel.** A "chair" reads your question and assembles 3–6 advisors that actually fit it
   (e.g. an architect, a skeptic, a data specialist). There's always someone playing devil's advocate.
2. **Independent opinions.** Each advisor answers on their own, **without seeing the others** — so they
   don't copy or defer to one another.
3. **No names.** Opinions go into the summary anonymously, so the argument counts, not "who said it".
4. **The verdict.** You get one recommendation, a clear "where they differed", an honest "what we don't
   know", and a next step.

It's **a decision aid, not a verdict** — the final call is always yours.

### Two modes

- **Regular (advisory)** — the default. A few opinions in one session, fast. For most decisions.
- **For important / irreversible calls** — when you want genuinely independent scrutiny, konsylium hands
  the question to a tool that asks AI models from **different vendors** (not just one). A panel from a
  single provider isn't the same as a second opinion from an independent one.

## When it helps (and when it doesn't)

**Reach for it when:**
- the decision is hard to reverse or costly,
- you're choosing between 2–3 options and it isn't obvious,
- you have an idea and want it honestly challenged,
- you're writing an important doc/plan and want different angles before locking it.

**Skip it** for simple, obvious questions — a single answer is plenty there.

## Install

**What you need:** Claude Code or Codex (or the Claude app). The repo ships two language editions —
English and Polish; both register the `/konsylium` command.

```sh
sh install.sh --dry-run     # preview — writes nothing
sh install.sh               # install (English) into Claude Code + Codex
```

An existing install is backed up, never silently overwritten. Then start a new session.

<details>
<summary><b>Codex, the desktop app, the Polish edition</b></summary>

- **Polish edition:** `sh install.sh --lang pl`
- **One tool only:** add `--claude-only` or `--codex-only`
- **Claude / Cowork desktop app** (it imports a ZIP, it doesn't read the folders):
  Customize → Skills → **"+" → Create skill** → upload `dist/konsylium-en.zip` (or `-pl`) → toggle **ON**.

</details>

## Also from the terminal

You don't have to be in a chat — it works as a one-liner too (handy for automation, e.g. in CI):

```sh
claude -p "/konsylium one table to start, or split the data?"
codex exec "use the konsylium skill: monolith or microservices for a small team?"
```

Pipe the result to a file (`> verdict.md`) and drop it into your notes, a PR description, or a decision log.

## Privacy & safety

- **The skill itself sends nothing to the internet and collects no data** — it's plain text instructions;
  the only script (`install.sh`) just copies files locally.
- Anything reaches the cloud only when **you** deliberately use the "important decisions" mode.
- **Don't paste secrets or sensitive data** into a question.

Details and how to report issues → [SECURITY.md](SECURITY.md).

## Honestly: what it does NOT do

No miracle claims:

- **It's a thinking aid, not an oracle.** For a simple question, don't use it — one answer is enough.
- **The same question can give a slightly different panel and a different answer.** In the regular mode
  that's on purpose (the point is varied angles). If you need repeatability, use the "important decisions" mode.
- **Advisors can sound different yet think alike.** We make sure each looks from a different angle, but
  we don't measure that.
- **It costs a bit more than one question** (it runs several opinions at once). Use it for decisions that
  matter — still cheaper than building the wrong thing.
- **No endless arguing.** Research shows forcing AI through many rounds of debate doesn't improve quality
  (and sometimes hurts), so we keep it to one round.

## Does it actually work?

No promises that it always does. I ran a small, honest test on **5 real decisions**: it clearly helped
**once**, moderately **three times**, and **not at all once** (simple questions don't need a panel).
Details: [EVALS.md](EVALS.md). Treat it as a way to get a broader view, not an infallible oracle.

## What it builds on (credits)

The "AI panel" idea isn't new — a nod to:
[karpathy/llm-council](https://github.com/karpathy/llm-council),
[council-review](https://github.com/ngmeyer/council-review),
[council-of-high-intelligence](https://github.com/0xNyk/council-of-high-intelligence),
[llm-consortium](https://github.com/irthomasthomas/llm-consortium),
Anthropic's [Agent Skills](https://github.com/anthropics/skills).

What konsylium adds: **a panel chosen for the question** (not a fixed roster), **one package across
several tools**, and a clear split between **"advising" and "independent scrutiny"**. The specific
borrowed ideas and their licenses are in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

<details>
<summary><b>For the technically curious</b></summary>

- It's a **skill** (Markdown instructions the AI runs) — not a server; nothing to launch or maintain.
- Each advisor runs in its **own clean context**; only the summary returns to the main conversation.
- Skills **don't sync across tools** — install separately in each (Claude Code, Codex, the app).
- The "important decisions" mode routes the question to a multi-model consensus tool (e.g.
  [`llm-consortium`](https://github.com/irthomasthomas/llm-consortium)) so a *different* model evaluates
  than the one that generated — and always before, never instead of, the human's call.

</details>

## Contributing & license

PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). History: [CHANGELOG.md](CHANGELOG.md).

MIT © 2026 Michał Witczak. Use it freely.
