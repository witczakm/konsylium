# Changelog

All notable changes to this project are documented here. The format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versioning follows [SemVer](https://semver.org/).

## [1.1.0] — 2026-06-16

Quality borrows from peer projects (ideas only, reimplemented clean-room — see THIRD-PARTY-NOTICES.md).

### Added
- **Problem-restate gate** — each persona first reframes the question in one sentence (catches mis-framing).
- **Value-tension vs error-catch** labeling in the synthesis/dissent — separates valid trade-offs from real flaws the others missed.
- **Curated persona triads** for common domains (schema, security review, API design, build-vs-adopt, migration) to guide the Marshal.
- Strengthened the dissent quota in the chairman step.
- `THIRD-PARTY-NOTICES.md` crediting adapted ideas (CC0 / MIT / Apache-2.0 sources).

### Deliberately NOT adopted
- Multi-round refinement, peer-ranking, embedding clustering, multi-provider in the *core* council — they add rounds/deps or duplicate Mode B, contradicting the one-pass, lightweight design.

## [1.0.0] — 2026-06-16

First public release.

### Added
- `/konsylium` Agent Skill for **Claude Code**, **Codex**, and the **Claude / Cowork desktop app**.
- **Adaptive Marshal (P0):** a meta-step that reads the question and assembles a 3–6 persona panel
  for *that* problem, minting domain personas (security, data-integrity, privacy, cost, performance)
  instead of a fixed roster.
- **Mode A** (in-session divergence): blind parallel pass → anonymize → chairman synthesis with
  preserved dissent and an explicit "what we don't know" section.
- **Mode B** (gate): routes to a cross-model consensus tool for genuine model-family independence
  — never fakes independence with one provider.
- Two language editions: **English** (`skills/konsylium/`) and **Polish** (`skills/konsylium-pl/`).
- `install.sh` for Claude Code + Codex (`--lang en|pl`, `--dry-run`, no silent overwrite) and
  prebuilt app-import ZIPs (`dist/`).
- `examples/` gallery of illustrative real runs; bilingual README; SECURITY, CONTRIBUTING, and a
  CI workflow that validates frontmatter and EN/PL parity.
