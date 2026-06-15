# Contributing to konsylium

Thanks for helping out — PRs are welcome. The project is small and stays that way
on purpose: it is a Markdown Agent Skill, not a framework. Keep changes light and
proportional.

## The one rule that matters: EN/PL parity

The **English edition `skills/konsylium/` is canonical.** Any change you make there
**must be mirrored** into the Polish edition `skills/konsylium-pl/`:

- `skills/konsylium/SKILL.md` ↔ `skills/konsylium-pl/SKILL.md`
- `skills/konsylium/references/personas.md` ↔ `skills/konsylium-pl/references/persony.md`
- `skills/konsylium/assets/OUTPUT_TEMPLATE.md` ↔ `skills/konsylium-pl/assets/OUTPUT_TEMPLATE.md`

CI (`.github/workflows/validate.yml`) checks that both editions have a matching file
layout. A change to one edition only will fail the build.

## Keep the frontmatter YAML-safe

Each `SKILL.md` starts with a YAML frontmatter block holding `name:` and
`description:`. Some tools parse this with strict YAML, so:

- Write `description` as a block scalar (`>-`) or a properly quoted string.
- **Never** use a plain scalar that contains `: ` or unescaped quotes — it will
  break strict parsers even if it looks fine in others.

```yaml
---
name: konsylium
description: >-
  Internal AI council of many perspectives: a "Marshal" assembles a persona
  panel, queries each blind, then synthesizes one verdict with dissent kept.
---
```

## Test it locally

Preview exactly what would be written, touching nothing:

```sh
sh install.sh --dry-run            # add --lang pl to preview the Polish edition
```

Or install into a throwaway location so nothing touches your real config — the script
honors `CLAUDE_HOME` / `CODEX_HOME`:

```sh
tmp=$(mktemp -d)
CLAUDE_HOME="$tmp/.claude" CODEX_HOME="$tmp/.codex" sh install.sh        # EN
CLAUDE_HOME="$tmp/.claude" CODEX_HOME="$tmp/.codex" sh install.sh --lang pl
find "$tmp" -type f          # inspect what was written
```

Also spot-check the path flags: `--claude-only`, `--codex-only`, `--id <name>`.

## Rebuilding the desktop-import zips

The Claude / Cowork desktop app imports a zip whose **root folder is `konsylium/`** (so the
command stays `/konsylium` for both editions):

```sh
# EN edition — the folder is already named 'konsylium'
( cd skills && zip -r ../dist/konsylium-en.zip konsylium )

# PL edition — stage it as 'konsylium/' first, then zip
rm -rf .build && mkdir -p .build/konsylium
cp skills/konsylium-pl/SKILL.md .build/konsylium/
cp -R skills/konsylium-pl/references skills/konsylium-pl/assets .build/konsylium/
( cd .build && zip -r ../dist/konsylium-pl.zip konsylium ) && rm -rf .build
```

## License

By contributing you agree your work is released under the project's MIT License.
