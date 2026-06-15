# Council verdict: Bash or Python for a one-off file-tidy script?

> Illustrative single run · 2026-06-15 · Mode A · Panel: Architect · Skeptic · Pragmatist

A narrow, low-stakes question — the kind where the Marshal uses the **fast path** (a small default
panel rather than minting domain personas). It still produced a real minority dissent.

**Question:** For a one-off script that tidies files in a Downloads folder, choose Bash or Python?

---

## Recommendation

**Use Python (`pathlib` + `shutil`, stdlib, no dependencies).** For a one-shot sorter it's ~30 lines
of readable code that behaves correctly with spaces in names, duplicates, and missing directories —
without the defensive ceremony Bash requires to be safe.

## Where they disagreed (dissent)

- **Skeptic → Bash (minority):** `mv` / `mkdir -p` / `find` is the native shell use case — zero
  environment, one line per file type. The real divergence. But even the Skeptic conceded the failure
  mode: without `set -euo pipefail` and scrupulous quoting, Bash silently swallows errors (name
  collisions, spaces, permissions) and "succeeds" without doing the job. Architect and Pragmatist
  agreed Bash "works" on the trivial case but degrades fast.

## What we don't know / what we trade off

- **[TO CHECK]** Complexity of the sort rules — if it's literally `mv *.pdf pdf/`, Bash wins on length.
- **[TO CHECK]** The execution environment — Python 3 is present on macOS; a minimal server/CI image
  may not have it.
- Accepted: if "one-off" really stays one-off and trivial, Python is mild over-engineering.

## Next step

Write the Python version unless the rules are confirmed trivial and the target lacks Python.

---

*The council is a divergence pre-check, not a gate. A human makes the decision.*
