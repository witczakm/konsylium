# konsylium — konsylium AI, które samo dobiera ekspertów

> Jedna komenda odpala panel niezależnych perspektyw AI nad Twoją decyzją i zwraca jeden werdykt
> **z zachowanym dissentem na stole** — zamiast pojedynczej, pewnej siebie opinii jednego modelu.

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757)
![Codex](https://img.shields.io/badge/Codex-skill-111111)
![Claude desktop](https://img.shields.io/badge/Claude%20app-skill-8a63d2)

Lekki [Agent Skill](https://support.claude.com/en/articles/12512180-use-skills-in-claude)
dla **Claude Code**, **Codex** i **aplikacji Claude / Cowork**.
🇵🇱 polski · 🇬🇧 [English README](README.md)

*konsylium* — marka; idea to **adaptacyjne** konsylium: meta-krok czyta Twoje pytanie i dobiera
właściwych ekspertów **pod to pytanie**, zamiast sztywnej listy.

---

## Zobacz w działaniu

Realny run — *„trzymać dane oferentów w tej samej tabeli co scoring, czy rozdzielić?"* Marszałek nie
użył generycznego panelu; **zmintował persony Prywatność, Compliance i Integralność danych, bo
przeczytał pytanie**, a dwie z nich niezależnie złapały wymóg, który panel sam-architekt zwykle pomija:

> **Rekomendacja:** Osobne tabele **+ immutable snapshot** danych identyfikacyjnych oferenta w momencie
> oceny — sam klucz obcy nie wystarczy, bo późniejsza korekta nazwy/NIP nie może przepisać historii
> wcześniejszego scoringu.
> **Dissent:** Pragmatyk dopuścił jedną tabelę dla trywialnego MVP; Sceptyk zaatakował wariant
> „tylko FK" jako fałszywą audytowalność.
> **Czego nie wiemy:** czy kontakty to osoby fizyczne (reżim RODO) …

Pełny werdykt i trzy kolejne → **[examples/](examples/)** (w języku angielskim).

## Jaki problem rozwiązuje

Pojedynczy model daje jedną, pewną odpowiedź — i pewnie zgadza się sam ze sobą. Najdroższy koszt w
pracy nad softem to rzadko napisanie kodu; to **zbudowanie złej rzeczy** i odkrycie tego trzy sprinty
później. Review, red-teaming i druga opinia to naprawiają — ale ręcznie (pastowanie tego samego promptu
do kilku chatbotów i scalanie) jest wolne i łatwo je pominąć.

`konsylium` zamienia to w jedną komendę i przesuwa krytykę **zanim** się zaangażujesz.

## Co go wyróżnia

| | konsylium | typowy „LLM council" |
|---|---|---|
| **Dobór panelu** | **Adaptacyjny** — Marszałek dobiera 3–6 person *pod pytanie*, mintując ekspertów domenowych (bezpieczeństwo, integralność danych, prywatność, koszt…) | sztywna lista |
| **Narzędzia** | jeden skill na **Claude Code + Codex + aplikację** | zwykle jedna powierzchnia |
| **Tryby** | jawny **doradczy** (dywergencja) vs **bramka** (niezależność cross-model) — bez mieszania | zwykle jeden tryb |
| **Output** | rekomendacja **+ zachowany dissent + „czego nie wiemy"** | scalona odpowiedź |
| **Rundy** | 1 blind pass + 1 synteza (oparte na dowodach; patrz ograniczenia) | czasem N-rundowa debata |

Idea „AI council" nie jest nowa — patrz [Prior art](#prior-art). Wkład tutaj to adaptacyjny Marszałek,
pakowanie cross-tool i rozdział doradczy-vs-bramka.

## Jak działa (Tryb A — doradczy, domyślny)

```
/konsylium <pytanie>
   │
   1. Marszałek (P0)  czyta pytanie → dobiera 3–6 person pod TEN problem
   │                  (guardraile: ≥1 adwersarz · max 6 · każda inny tryb porażki)
   2. Blind pass      każda persona odpowiada w IZOLOWANYM kontekście, równolegle,
   │                  nie widząc innych  ← zabija konformizm
   3. Anonimizacja    odpowiedzi P1..Pn (bez nazw, bez order-bias)
   4. Chairman        jeden werdykt: rekomendacja + gdzie się różnili (dissent)
                      + „czego nie wiemy" + następny ruch
```

Konsylium to **pre-check dywergencyjny zasilający decyzję** — nigdy jej nie domyka i nigdy nie jest
bramką merge. **Decyduje człowiek.**

### Tryb B — bramka (routing, nie reimplementacja)

Gdy decyzja jest high-risk i wymaga *prawdziwej niezależności rodziny modeli*, konsylium subagentów
jednego dostawcy nie jest niezależne. Tryb B routuje pytanie do narzędzia konsensusu cross-model (np.
[`swarm-consensus`](https://github.com/anthropics/skills) albo
[`llm-consortium`](https://github.com/irthomasthomas/llm-consortium)), pinując arbitra do innej rodziny,
żeby *ewaluator ≠ generator*. Bramka jest **upstream do**, nie zamiast, decyzji człowieka. (W Trybie B
można też *przypiąć* panel dla powtarzalności.)

## Kiedy używać

- nietrywialna lub trudna do odwrócenia decyzja; kontrakt / interfejs / inwariant; bezpieczeństwo/koszt,
- wybór z 2–3 alternatyw, gdy odpowiedź nie jest oczywista,
- masz jedną opcję i chcesz ją zaatakować (steelman opozycji),
- przed pisaniem design doc / ADR — dywergencja zanim zamkniesz,
- model krąży w kółko (powtarzane propozycje, nieudane próby).

**Nie** używaj do pytań trywialnych/faktograficznych ani czystej egzekucji.
Reguła: *trywialne → nie; architektura / kontrakt / nieodwracalne → tak.*

## Instalacja

W repo są dwie edycje — **angielska** (`skills/konsylium/`) i **polska** (`skills/konsylium-pl/`).
Wybierz jedną; obie rejestrują komendę `/konsylium`.

### Claude Code & Codex (CLI)

```sh
git clone https://github.com/witczakm/konsylium.git && cd konsylium
sh install.sh --dry-run --lang pl   # podgląd, niczego nie zapisuje
sh install.sh --lang pl             # edycja polska → Claude Code + Codex
# sh install.sh                     # edycja angielska
```

Kopiuje skill do `~/.claude/skills/konsylium` i `~/.codex/skills/konsylium` (oba auto-wykrywają;
istniejąca instalacja jest backupowana, nigdy po cichu nadpisywana). Nowa sesja → `/konsylium`.

### Aplikacja Claude / Cowork

Aplikacja importuje ZIP (nie czyta tamtych folderów):
**Customize → Skills → „+" → Create skill → wgraj `dist/konsylium-pl.zip`** (lub `-en`), włącz **ON**.

## Uruchamianie z CLI — i dlaczego to ważne

```sh
claude -p "/konsylium czy trzymać dane oferentów w tej samej tabeli co scoring?"
codex exec "użyj skilla konsylium: monolit czy mikroserwisy dla 3-osobowego zespołu?"
```

- **Skryptowalne i automatyzowalne** — wepnij konsylium w CI, hook pre-commit albo cron.
- **Zimny, świeży kontekst** — run headless nie jest skażony bieżącym czatem; bliżej zdania kolegi.
- **Równolegle i szybko** — persony lecą współbieżnie; werdykt w ~1–2 min zamiast 8-minutowej pętli.
- **Pipe’owalne** — zrzuć do pliku (`> werdykt.md`) i zasil PR, decision log albo ADR.

## Paleta person domenowych

Poza bazą (Architekt · Sceptyk/Red-Team · Pragmatyk · Strażnik danych · Operator) Marszałek może
mintować: **Bezpieczeństwo/Compliance · Integralność danych · Prywatność · Koszt/FinOps ·
Wydajność/skala · Utrzymywalność**. Własne dodasz w `references/persony.md`.

## Granica danych i prywatność

- **Skill nie wykonuje połączeń sieciowych i nie ma własnej telemetrii.** To czysta instrukcja
  Markdown; jedyny wykonywalny element to `install.sh` (`sh`/`cp`/`sed`, lokalnie).
- Jedyna ścieżka „na zewnątrz" to *Ty* pozwalający agentowi zroutować **Tryb B** do modelu w chmurze.
- **Nigdy nie wkładaj sekretów ani danych prywatnych/wrażliwych do promptu konsylium.** Zasady Trybu A
  blokują routing Trybu B do chmury, gdy pytanie zawiera dane wrażliwe; resztę egzekwujesz Ty.

Model zagrożeń i zgłaszanie problemów → [SECURITY.md](SECURITY.md).

## Uczciwe ograniczenia

To pomoc w myśleniu, nie magia:

- **Model-mediated, nie deterministyczne.** Skill *instruuje* blind parallel dispatch, ale go twardo
  nie wymusza. To samo pytanie da różne panele/dissent — w trybie dywergencji to cecha, nie bug. Dla
  powtarzalności przypnij panel w Trybie B.
- **Brak wbudowanego pomiaru różnorodności.** Persony mogą *brzmieć* różnie, a *myśleć* podobnie;
  guardrail „inny tryb porażki" to ogranicza, ale nie mierzy.
- **Wielorundowa debata nie pomaga — a szkodzi.** Badania
  ([Should we be going MAD?](https://arxiv.org/abs/2311.17371) + prace o konformizmie) pokazują, że
  więcej rund nie bije self-consistency i potrafi odwrócić poprawne odpowiedzi. Dlatego konsylium robi
  **1 blind pass + 1 syntezę** — bez rund.
- **Dowody.** [Przykłady](examples/) to *ilustracyjne pojedyncze runy*, nie benchmark. Eval before/after
  jest na roadmapie; do tego czasu traktuj konsylium jako ustrukturyzowaną dywergencję, nie dowód.
- **Koszt.** Run powołuje 3–6 subagentów — taniej niż zbudować złą rzecz, drożej niż jednolinijkowa
  odpowiedź. Rezerwuj dla decyzji, które mają znaczenie.

## Prior art

`konsylium` stoi na zdrowym, zatłoczonym ekosystemie — należny kredyt:
[karpathy/llm-council](https://github.com/karpathy/llm-council),
[council-review](https://github.com/ngmeyer/council-review),
[council-of-high-intelligence](https://github.com/0xNyk/council-of-high-intelligence),
[llm-consortium](https://github.com/irthomasthomas/llm-consortium),
oraz [Agent Skills](https://github.com/anthropics/skills) Anthropic.

## Kontrybucje i changelog

PR-y mile widziane — patrz [CONTRIBUTING.md](CONTRIBUTING.md) (jedna ważna zasada: **trzymaj edycje
EN i PL w parytecie**; CI tego pilnuje). Historia w [CHANGELOG.md](CHANGELOG.md).

## Licencja

MIT © 2026 Michał Witczak. Forki i kontrybucje mile widziane.
