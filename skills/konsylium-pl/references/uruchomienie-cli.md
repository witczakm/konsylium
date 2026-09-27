# Uruchomienie zewnętrznych CLI w Trybie B — przepisy sprawdzone w boju

Każdy przepis pochodzi z przebiegu, w którym pierwsza próba bez tych flag SIĘ ZEPSUŁA
(`~/audits/2026-09-27-konsylium-widok`, `~/audits/2026-09-27-konsylium-2`). Nie skracaj flag.

## Wspólne dla wszystkich

1. **Kopia danych tylko do odczytu, osobny katalog per głos:**
   ```bash
   A=~/audits/$(date +%F)-konsylium-<temat>; mkdir -p "$A"/{dane,codex,agy,grok}
   cp -R <pakiet> "$A/dane" && chmod -R a-w "$A/dane"
   date > "$A/start.txt"          # znacznik czasu z zegara, nie z pamięci
   ```
   Powód: sesja Groka z CWD w żywym pakiecie zapisywała do niego (`ZMIANY/_konsylium/…`).
2. **Jeden plik promptu** (`prompt.md`) z zakazami wprost: „nie czytaj poza bieżącym katalogiem;
   nie zapisuj; nie uruchamiaj skilli, pluginów, subagentów, sieci; limit N minut". Zakaz w promptcie
   NIE wystarcza — flagi niżej go egzekwują.
3. **Limit czasu zewnętrzny** (`timeout 1500 <komenda>` albo zadanie w tle + `ps`) — Grok
   przekroczył deklarowane 20 min o ~8 min i nie zatrzymał się sam.
4. **Model faktyczny z logu**, nie z konfiguracji: zapisz do werdyktu nazwę z bannera/logu
   (przykłady niżej). Konfiguracja `routing.json` obiecywała GPT, odpowiadał kimi-k3 przez Ollamę.

## Codex

```bash
cd "$A/dane" && codex exec -s read-only --disable plugins -c skills.include_instructions=false \
  < "$A/prompt.md" > "$A/codex/out.md" 2> "$A/codex/err.log"
```
- Bez `--disable plugins -c skills.include_instructions=false` Codex sam uruchomił własne skille
  `konsylium` i `impeccable` i zawiesił się na `collab: Wait` (dyspozycja subagentów blokowała).
- Model faktyczny: nagłówek odpowiedzi (`gpt-5.6-sol`); poziom rozumowania ustaw jawnie —
  domyślny bywał `low`, gdy chodziło o `high`.
- Codex nie odpali testów projektu z sandboxa (venv, EPERM na listen) — liczby przelicza prowadzący.

## Gemini / Antigravity (`agy`)

```bash
cd "$A/dane" && agy -p --model gemini-3.1-pro-high --sandbox < "$A/prompt.md" > "$A/agy/out.md" 2> "$A/agy/agy.log"
```
- `gemini -p` (stare CLI): `IneligibleTierError` — darmowy tier wycofany; używaj `agy`.
- Bez `--dangerously-skip-permissions`. Model faktyczny potwierdzaj w `agy.log` (Pro vs Flash —
  bramka na Flash zamiast Pro była nieważna).
- W jednym przebiegu AGY stracił dostęp do terminala i „policzył" 157 wymogów zamiast 215 —
  stąd obowiązkowa kontrola liczb w kroku 3 skilla.

## Grok

```bash
cd "$A/dane" && grok --prompt-file "$A/prompt.md" --tools read_file,list_dir,grep \
  --permission-mode dontAsk --disable-web-search --no-subagents > "$A/grok/out.md" 2> "$A/grok/err.log"
```
- Bez `--tools …` i `--permission-mode dontAsk` zaczął eksplorować system plików i zawiesił się
  bez interfejsu, czekając na zatwierdzenie.
- Model faktyczny z `chat_history.jsonl` (np. `grok-4.7-build`). Działa 3–12× wolniej niż Codex —
  planuj limit czasu odpowiednio.

## Claude (druga instancja tej samej rodziny — NIE liczy się jako inna rodzina)

```bash
cd "$A/dane" && claude -p --model <model> --allowedTools "Read,Grep,Glob" < "$A/prompt.md" > "$A/claude/out.md"
```
Głos Claude'a w Trybie B to głos tej samej rodziny co prowadzący — w nagłówku werdyktu wpisz
DEGRADACJA, jeśli zastępuje brakującą rodzinę.

## Po zebraniu głosów

- `date >> "$A/start.txt"` — koniec; czas per głos do werdyktu.
- Synteza do `"$A/SYNTEZA.md"` wg `assets/OUTPUT_TEMPLATE.md` (pole „Modele faktyczne" z logów).
- W repo projektowym dodatkowo kopia/odsyłacz w `docs/reports/konsylium/`.

[DO UZUPEŁNIENIA]: przepis dla lokalnych modeli przez Ollama (kimi-k3) — użyty raz, bez zapisu flag.
