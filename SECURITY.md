# Security Policy

## Supported versions

Only the latest release is supported. Fixes land on `main` and ship in the next
tagged release; older tags do not receive backports.

## Reporting a vulnerability

Please report privately — do not open a public issue for a security problem.

- Open a private [GitHub Security Advisory](https://github.com/witczakm/konsylium/security/advisories/new) — it notifies the maintainer directly without a public issue.

Include what you found, how to reproduce it, and the impact you expect. We aim to
acknowledge within a few days and will credit you in the fix unless you prefer otherwise.

## Threat model

`konsylium` is **pure Markdown** — a SKILL.md plus reference/asset Markdown files.
It has no executable runtime of its own. The only shipped code is `install.sh`, a
POSIX `sh` script that copies the skill into `~/.claude` / `~/.codex` using
`cp`/`sed`/`mktemp`. It writes nothing else and runs nothing in the background.

The skill itself **makes no network calls and emits no telemetry**. The single
outbound path exists only in **Mode B**, where the skill *instructs the agent* to
route a question to an external cross-model tool. That call is made by your own
tooling, to a provider you configured and control — `konsylium` neither bundles
credentials nor chooses the provider.

Because prompts may be sent to a cloud model in Mode B, **never put secrets,
credentials, or sensitive data into a konsylium prompt.** Treat anything you ask
the council as something a third-party model could see.
