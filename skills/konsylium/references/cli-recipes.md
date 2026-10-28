# Running external CLIs in Mode B — battle-tested recipes

Every recipe comes from a run where the first attempt without these flags BROKE
(`~/audits/2026-09-27-konsylium-widok`, `~/audits/2026-09-27-konsylium-2`). Don't trim the flags.

## Common to all

1. **Read-only copy of the data, a separate folder per voice:**
   ```bash
   A=~/audits/$(date +%F)-konsylium-<topic>; mkdir -p "$A"/{dane,codex,agy,grok}
   cp -R <package> "$A/dane" && chmod -R a-w "$A/dane"
   date > "$A/start.txt"          # timestamp from the clock, not from memory
   ```
   Why: a Grok session with its working directory in the live package wrote into it (`ZMIANY/_konsylium/…`).
2. **One prompt file** (`prompt.md`) with explicit bans: "don't read outside the current folder;
   don't write; don't run skills, plugins, subagents, network; limit N minutes". A ban in the prompt
   is NOT enough — the flags below enforce it.
3. **External time limit** (`timeout 1500 <command>` or a background job + `ps`) — Grok
   overran its declared 20 min by ~8 min and didn't stop on its own.
4. **Actual model from the log**, not from configuration: write into the verdict the name from the
   banner/log (examples below). The `routing.json` configuration promised GPT; kimi-k3 answered via Ollama.

## Codex

```bash
cd "$A/dane" && codex exec -s read-only --disable plugins -c skills.include_instructions=false \
  < "$A/prompt.md" > "$A/codex/out.md" 2> "$A/codex/err.log"
```
- Without `--disable plugins -c skills.include_instructions=false` Codex launched its own
  `konsylium` and `impeccable` skills and hung on `collab: Wait` (subagent dispatch blocked).
- Actual model: the response header (`gpt-5.6-sol`); set the reasoning level explicitly —
  the default was sometimes `low` when `high` was intended.
- Codex can't run the project's tests from the sandbox (venv, EPERM on listen) — the lead recomputes numbers.

## Gemini / Antigravity (`agy`)

```bash
cd "$A/dane" && agy -p --model gemini-3.1-pro-high --sandbox < "$A/prompt.md" > "$A/agy/out.md" 2> "$A/agy/agy.log"
```
- `gemini -p` (old CLI): `IneligibleTierError` — the free tier was withdrawn; use `agy`.
- No `--dangerously-skip-permissions`. Confirm the actual model in `agy.log` (Pro vs Flash —
  a gate run on Flash instead of Pro was invalid).
- In one run AGY lost terminal access and "counted" 157 requirements instead of 215 —
  hence the mandatory number check in step 3 of the skill.

## Grok

```bash
cd "$A/dane" && grok --prompt-file "$A/prompt.md" --tools read_file,list_dir,grep \
  --permission-mode dontAsk --disable-web-search --no-subagents > "$A/grok/out.md" 2> "$A/grok/err.log"
```
- Without `--tools …` and `--permission-mode dontAsk` it started exploring the file system and hung
  headless, waiting for approval.
- Actual model from `chat_history.jsonl` (e.g. `grok-4.7-build`). Runs 3–12× slower than Codex —
  plan the time limit accordingly.

## Claude (a second instance of the same family — does NOT count as another family)

```bash
cd "$A/dane" && claude -p --model <model> --allowedTools "Read,Grep,Glob" < "$A/prompt.md" > "$A/claude/out.md"
```
A Claude voice in Mode B is a voice from the same family as the lead — write DEGRADATION in the
verdict header if it stands in for a missing family.

## After collecting the voices

- `date >> "$A/start.txt"` — end; time per voice goes into the verdict.
- Synthesis to `"$A/SYNTEZA.md"` per `assets/OUTPUT_TEMPLATE.md` (the "Actual models" field from the logs).
- In a project repo, also a copy/link in `docs/reports/konsylium/`.

[TO BE COMPLETED]: a recipe for local models via Ollama (kimi-k3) — used once, flags not recorded.
