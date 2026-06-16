# Producing the visual assets

The repo ships a static SVG demo (`assets/konsylium-demo.svg`) that renders on GitHub with no
recording. To add a **live GIF** and the **desktop-app import screenshots**, follow these steps —
they need your terminal / app, so they can't be generated automatically.

## 1. CLI demo — animated cast (asciinema → GIF)

```sh
brew install asciinema agg          # agg converts a cast to GIF
asciinema rec assets/konsylium-cli.cast --overwrite
#   in the recording, run ONE real, snappy decision, e.g.:
#   claude -p "/konsylium bash vs python for a one-off file-tidy script?"
#   …let it finish, then Ctrl-D to stop
agg assets/konsylium-cli.cast assets/konsylium-cli.gif --theme github-dark --font-size 22
```

Keep it **under ~30 seconds** — pick a fast decision (the bash-vs-python one is short). Trim dead time
before recording by having the session ready. Then reference it in the README:
`![CLI demo](assets/konsylium-cli.gif)`.

## 2. Desktop-app import — 3 screenshots

Capture these into `assets/` (PNG, retina ok). They cover the one install path that has no CLI feedback:

1. `import-1-plus.png` — Customize → **Skills**, with the **“+”** highlighted.
2. `import-2-upload.png` — the **Create skill** dialog with `dist/konsylium-en.zip` selected.
3. `import-3-enabled.png` — `konsylium` in the skills list with the toggle **ON**.

Drop them under an `<details><summary>Desktop-app import (screenshots)</summary>` block in the README so
they add proof without taking first-screen space.

## 3. Social preview image (optional)

GitHub → repo **Settings → General → Social preview** → upload a 1280×640 PNG. A clean wordmark on the
dark terminal style is enough; avoid an over-produced logo (it oversells a 12 KB skill).

> Keep all visuals honest: record a real run, don't stage a cherry-picked verdict.
