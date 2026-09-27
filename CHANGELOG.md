# Changelog

All notable changes to this project are documented here. The format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versioning follows [SemVer](https://semver.org/).

## [2.1.0] — 2026-09-27 — edycja PL (EN: do przeniesienia)

Wydanie po audycie 27 przebiegów konsylium na żywym projekcie (16 raportów w `docs/reports/konsylium/`, 8 w `~/audits/`, 3 z 27.09) i przeglądzie badań 2025–2026. Zmiany celują w cztery zmierzone awarie: (1) wyzwalacz „krąży w kółko" nie zadziałał przy 11 i 6 rundach NO bramki; (2) w 3 przebiegach model faktyczny różnił się od deklarowanego (kimi-k3 zamiast GPT, Gemini za Codexa, `NIEZNANY`) i żaden raport tego nie podniósł; (3) głos podał „157 wymogów" zamiast 215 („nie policzyłem"); (4) pierwsze uruchomienie zewnętrznego CLI psuło się w 3/3 przypadków (Codex odpalił własne skille i zawisł na `collab: Wait`, Grok eksplorował system plików, `gemini -p` → `IneligibleTierError`).

### Added
- **Wyzwalacz twardy:** 3. runda NO tej samej bramki w tej samej klasie błędu = konsylium przed 4. rundą, bez pytania.
- **Framing z czterema wymaganymi polami:** PYTANIE · CO JUŻ ISTNIEJE · STANOWISKO DECYDENTA · LICZBY ŹRÓDŁOWE. Powód: panel nie znał istniejącej bazy wiedzy (werdykt do odrzucenia) i nie znał stanowiska radcy (zalecił „nie budować" tego, co decydent zatwierdził).
- **Zwrot persony ma dwa nowe pola:** *Model faktyczny* i *Liczby* (każda liczba oznaczona `[framing]` / `[przeliczone: <komenda>]` / `[własne]`).
- **Krok 3: kontrola liczb** — liczba „własna" jest przeliczana na danych przed syntezą; głos oparty na błędnej liczbie liczy się z pewnością 0.
- **Krok 3: anonimowy ranking krzyżowy** (wzór: llm-council) — domyślny, tańszy zamiennik konfrontacji; nikt nie zmienia stanowiska.
- **`references/uruchomienie-cli.md`** — przepisy uruchomienia Codex / Antigravity (`agy`) / Grok / Claude z flagami, które w boju okazały się konieczne, kopią danych `chmod -R a-w`, limitem czasu i odczytem modelu faktycznego z logu.
- **Tryb B kroki 4–6:** przepis CLI, model faktyczny z logu (zastępstwo tej samej rodziny = DEGRADACJA w nagłówku werdyktu), dane tylko do odczytu.
- **Szablon werdyktu:** pola *Modele faktyczne*, *Wyzwalacz*, *Liczby*, *Ranking krzyżowy*, *Wynik po fakcie* (kalibracja panelu wobec rzeczywistości — luka, której nie ma żaden z przejrzanych projektów).

### Changed
- **Konfrontacja (krok 5) ma kryterium liczbowe:** tylko gdy brak większości ważonej pewnością ≥ 60 % albo dwa głosy ≥ 70 są sprzeczne w fakcie (wzór: llm-consortium — próg pewności + limit iteracji). Zamiast „czuję split".
- **Werdykt ZAWSZE do pliku** (`docs/reports/konsylium/…` lub `~/audits/…/SYNTEZA.md`) — także przebiegi inline; wcześniej „na życzenie lub T2", w praktyce K1–K7 nie miały pliku syntezy.
- **Uczciwa epistemika rozszerzona na Tryb B:** modele różnych dostawców mylą się tym samym błędem w ~60 % (Kim i in., ICML 2025); zgodność głosów < test/pomiar („Debate or Vote", NeurIPS 2025).

### Odwrócona decyzja z 1.1.0
- 1.1.0 świadomie NIE przyjęło peer-rankingu („dokłada rundy"). 2.1.0 go przyjmuje, bo pomiar pokazał odwrotny problem: konfrontacja uruchamiana uznaniowo prawie nigdy nie ruszała, a gdy ruszała, nie miała sygnału do ważenia. Ranking to jedna równoległa runda bez zmiany stanowisk — nie debata.

### Not yet
- Edycja EN (`skills/konsylium`) pozostaje na 1.2.0 — port 2.0.0 + 2.1.0 do zrobienia. `dist/konsylium-en.zip` bez zmian.

## [2.0.0] — 2026-07-08 — edycja PL (wydanie lokalne, bez commitu w repo — wpis odtworzony 2026-09-27)

### Added
- **`description` w formie „Użyj gdy…"** (same warunki wyzwolenia, bez streszczenia procesu) — agent nie skraca sobie skilla do opisu.
- **Pewność 0–100 w zwrocie każdej persony** i agregacja wg typu pytania: wybór z opcji → głosy ważone pewnością (wejście, nie wyrok); pytanie otwarte → synteza narracyjna.
- **Stance przy wyborze A/B** (Marszałek: ≥1 persona ZA, ≥1 PRZECIW) — wymusza dywergencję.
- **Model-tier** (opcjonalnie): persony domenowe na tańszym modelu, adwersarz i architekt na modelu sesji.
- **Krok 5: konfrontacja warunkowa, max 1 runda** (Smit 2024; Wynn 2025 „Talk Isn't Always Cheap") + **nudge** po werdykcie (ponowne odpalenie jednej persony z kontrargumentem).
- **Chairman ≠ uczestnik**; high-stakes → synteza w świeżym subagencie. Werdykt do `docs/reports/konsylium/` (na życzenie / T2).
- **Tryb B jako routing** (swarm-consensus / llm-consortium / druga opinia ręczna) z zasadą „ewaluator ≠ generator".
- Zasady twarde: „Prawdziwa różnorodność > liczba" („Nine Judges, Two Effective Votes" 2026), „Uczciwa epistemika" (panel jednego modelu ≠ niezależna ocena).

### Changed
- W Claude Code wszystkie dispatche person w JEDNYM bloku wywołań (prawdziwa równoległość).

## [1.2.0] — 2026-06-16

### Added
- **Answers follow the question's language.** Ask in Polish, get a Polish verdict; ask in English, get
  English — no matter which edition is installed. (Before, the English edition replied in English even
  to Polish questions.)

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
