# konsylium — konsylium AI, które samo dobiera ekspertów

> Oddaj jednej komendzie swoją najtrudniejszą decyzję. **Marszałek** dobiera właściwych ekspertów
> *pod to pytanie*, przepytuje ich niezależnie i zwraca jeden werdykt — z zachowaną rozbieżnością
> na stole, nie uśrednioną.

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![CI](https://github.com/witczakm/konsylium/actions/workflows/validate.yml/badge.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757)
![Codex](https://img.shields.io/badge/Codex-skill-111111)
![Claude app](https://img.shields.io/badge/Claude%20app-skill-8a63d2)

**konsylium** to [Agent Skill](https://support.claude.com/en/articles/12512180-use-skills-in-claude)
dla **Claude Code**, **Codex** i **aplikacji Claude / Cowork** — dla inżynierów stojących przed
trudnymi do odwrócenia decyzjami architektonicznymi, kontraktowymi lub trade-offami.
🇵🇱 polski · 🇬🇧 [English README](README.md)

![konsylium demo — realny run Trybu A](assets/konsylium-demo.svg)

<details>
<summary><b>Spis treści</b></summary>

- [Quickstart](#quickstart)
- [Zobacz w działaniu](#zobacz-w-działaniu)
- [Dlaczego konsylium](#dlaczego-konsylium)
- [Jak działa](#jak-działa)
- [Kiedy używać](#kiedy-używać)
- [Instalacja](#instalacja)
- [Jak wpasowuje się w narzędzia](#jak-wpasowuje-się-w-narzędzia)
- [Użycie z CLI](#użycie-z-cli)
- [Granica danych i prywatność](#granica-danych-i-prywatność)
- [Uczciwe ograniczenia](#uczciwe-ograniczenia)
- [Dowody i roadmapa](#dowody-i-roadmapa)
- [Prior art](#prior-art)
- [Kontrybucje, changelog, licencja](#kontrybucje-changelog-licencja)

</details>

## Quickstart

```sh
git clone https://github.com/witczakm/konsylium.git && cd konsylium && sh install.sh --lang pl
```

Następnie, w **nowej sesji Claude Code**:

```
/konsylium <twoja najtrudniejsza otwarta decyzja>
```

Dostajesz rekomendację, **dissent** między perspektywami i uczciwe **„czego nie wiemy".**
Codex, aplikacja desktop i edycja angielska → [Instalacja](#instalacja).

## Zobacz w działaniu

Realny run — *„trzymać dane oferentów w tej samej tabeli co scoring, czy rozdzielić?"* Marszałek nie
użył generycznego panelu; **zmintował persony Prywatność, Compliance i Integralność danych, bo
przeczytał pytanie** — a dwie z nich niezależnie złapały wymóg, który panel sam-architekt zwykle pomija:

> **Rekomendacja:** Osobne tabele **+ immutable snapshot** danych identyfikacyjnych oferenta w momencie
> oceny — sam klucz obcy nie wystarczy, bo późniejsza korekta nazwy/NIP nie może przepisać historii
> wcześniejszego scoringu.
> **Dissent:** Pragmatyk dopuścił jedną tabelę dla trywialnego MVP; Sceptyk zaatakował wariant
> „tylko FK" jako fałszywą audytowalność.
> **Czego nie wiemy:** czy kontakty to osoby fizyczne (reżim RODO) …

Pełny werdykt i trzy kolejne decyzje → **[examples/](examples/)** (w języku angielskim).

## Dlaczego konsylium

Pojedynczy model daje jedną, pewną odpowiedź — i pewnie zgadza się sam ze sobą. Najdroższy koszt w
softcie to rzadko kod; to **zbudowanie złej rzeczy** i odkrycie tego trzy sprinty później. Review i
druga opinia to naprawiają — ale pastowanie tego samego promptu do trzech chatbotów i ręczne scalanie
jest wolne, więc się je pomija.

`konsylium` zamienia to w jedną komendę i przesuwa krytykę **zanim** się zaangażujesz.

| | konsylium | typowy „LLM council" |
|---|---|---|
| **Panel** | **adaptacyjny** — dobierany *pod pytanie*, mintuje ekspertów domenowych | sztywna lista |
| **Narzędzia** | jeden skill na **Claude Code + Codex + aplikację** | zwykle jedna powierzchnia |
| **Tryby** | jawny **doradczy** vs **niezależna bramka** — bez mieszania | zwykle jeden |
| **Output** | rekomendacja **+ zachowany dissent + „czego nie wiemy"** | scalona odpowiedź |
| **Rundy** | 1 blind pass + 1 synteza (oparte na dowodach) | czasem N-rundowa debata |

## Jak działa

```
/konsylium <pytanie>
   │
   1. Marszałek (P0)  czyta pytanie → dobiera 3–6 person pod TEN problem
   │                  (guardraile: ≥1 adwersarz · max 6 · każda inny tryb porażki)
   2. Blind pass      każda persona odpowiada w IZOLOWANYM kontekście, równolegle,
   │                  nie widząc innych  (zapobiega konformizmowi)
   3. Anonimizacja    odpowiedzi P1..Pn (bez nazw, bez order-bias)
   4. Chairman        jeden werdykt: rekomendacja + gdzie się różnili (dissent)
                      + „czego nie wiemy" + następny ruch
```

To **pre-check dywergencyjny zasilający decyzję** — nigdy bramka merge. Decyduje człowiek.
**Niedeterministyczne z założenia** (dywergencja to sedno); przypnij panel w Trybie B dla powtarzalności.

### Tryb B — niezależna bramka (routing)

Gdy decyzja wymaga *prawdziwej niezależności rodziny modeli*, konsylium subagentów jednego dostawcy nie
jest niezależne. Tryb B routuje pytanie do narzędzia konsensusu cross-model (np.
[`swarm-consensus`](https://github.com/anthropics/skills) albo
[`llm-consortium`](https://github.com/irthomasthomas/llm-consortium)), pinując arbitra do innej rodziny,
żeby *ewaluator ≠ generator*. Bramka jest **upstream do**, nie zamiast, decyzji człowieka.

## Kiedy używać

- decyzja trudna do odwrócenia; kontrakt / interfejs / inwariant; bezpieczeństwo lub koszt,
- wybór z 2–3 alternatyw, gdy odpowiedź nie jest oczywista,
- masz jedną opcję i chcesz ją zaatakować (steelman opozycji),
- przed design doc / ADR — dywergencja zanim zamkniesz,
- model krąży w kółko (powtarzane propozycje, nieudane próby).

**Pomiń** dla pytań trywialnych/faktograficznych i czystej egzekucji — to tylko spali tokeny.

## Instalacja

**Wymagania:** Claude Code lub Codex CLI (albo aplikacja Claude). Model-agnostyczne — używa tego, czym
skonfigurowane jest Twoje CLI. W repo dwie edycje: angielska (`skills/konsylium/`) i polska
(`skills/konsylium-pl/`); obie rejestrują komendę `/konsylium`.

```sh
sh install.sh --dry-run --lang pl   # podgląd, niczego nie zapisuje
sh install.sh --lang pl             # edycja polska → Claude Code + Codex
```

Istniejąca instalacja jest backupowana, nigdy po cichu nadpisywana. Nowa sesja → `/konsylium`.

<details>
<summary><b>Codex, aplikacja desktop, edycja angielska</b></summary>

- **Edycja angielska:** `sh install.sh`
- **Tylko jedno narzędzie:** `--claude-only` lub `--codex-only`
- **Aplikacja Claude / Cowork** (importuje ZIP, nie czyta tamtych folderów):
  Customize → Skills → **„+" → Create skill** → wgraj `dist/konsylium-pl.zip` (lub `-en`) → włącz **ON**.

</details>

## Jak wpasowuje się w narzędzia

- To **Skill** (instrukcje Markdown, które Claude wykonuje), **nie serwer MCP** — żadnego demona,
  transportu, niczego do uruchomienia. Trigger `/konsylium` to własne wywołanie skilla.
- Każda persona działa we **własnym izolowanym kontekście subagenta**; do głównego wątku wraca tylko
  finalna synteza — Twój kontekst zostaje czysty.
- **Skille nie synchronizują się między powierzchniami.** Claude Code, Codex i aplikacja to trzy
  niezależne kopie; aktualizacja = reinstalacja (lub ponowny import ZIP) na każdej powierzchni.

## Użycie z CLI

```sh
claude -p "/konsylium czy trzymać dane oferentów w tej samej tabeli co scoring?"
codex exec "użyj skilla konsylium: monolit czy mikroserwisy dla 3-osobowego zespołu?"
```

- **Skryptowalne** — wepnij konsylium w CI, hook pre-commit albo cron.
- **Zimny, świeży kontekst** — run headless nie jest skażony bieżącym czatem.
- **Równolegle i szybko** — persony lecą współbieżnie; werdykt w ~1–2 min.
- **Pipe’owalne** — `> werdykt.md` i wrzuć do PR, decision logu albo ADR.

## Granica danych i prywatność

- **Skill nie wykonuje połączeń sieciowych i nie ma własnej telemetrii** — to czysty Markdown; jedyny
  wykonywalny element to `install.sh` (`sh`/`cp`/`sed`, lokalnie).
- Jedyna ścieżka „na zewnątrz" to *Ty* pozwalający agentowi zroutować **Tryb B** do modelu w chmurze.
- **Nigdy nie wkładaj sekretów ani danych prywatnych/wrażliwych do promptu konsylium.**

Model zagrożeń i zgłaszanie → [SECURITY.md](SECURITY.md).

## Uczciwe ograniczenia

- **Model-mediated, nie deterministyczne.** Skill *instruuje* blind parallel dispatch, ale go twardo nie
  wymusza. To samo pytanie da różne panele — w trybie dywergencji to cecha. Przypnij w Trybie B.
- **Brak wbudowanego pomiaru różnorodności.** Persony mogą *brzmieć* różnie, a *myśleć* podobnie;
  guardrail „inny tryb porażki" to ogranicza, ale nie mierzy.
- **Wielorundowa debata nie pomaga — a szkodzi.** Badania
  ([Should we be going MAD?](https://arxiv.org/abs/2311.17371) + prace o konformizmie) pokazują, że
  więcej rund nie bije self-consistency i potrafi odwrócić poprawne odpowiedzi. Dlatego konsylium robi
  1 blind pass + 1 syntezę — bez rund.
- **Koszt.** Run powołuje 3–6 subagentów — taniej niż zbudować złą rzecz, drożej niż jednolinijkowa
  odpowiedź. Rezerwuj dla decyzji, które mają znaczenie.

## Dowody i roadmapa

Pierwszy **[eval head-to-head](EVALS.md)** zestawia konsylium z odpowiedziami single-pass na 5 realnych
decyzjach — i raportuje to uczciwie: wyraźnie pomogło raz, umiarkowanie trzy razy i **wcale raz** (proste,
ograniczone pytania nie potrzebują panelu). [Przykłady](examples/) to ilustracyjne pojedyncze runy, nie
benchmark. Traktuj konsylium jako ustrukturyzowaną dywergencję, nie wyrocznię. Rozszerzenie evala o własne
decyzje (jako PR) to roadmapa.

## Prior art

<details>
<summary>konsylium stoi na zdrowym, zatłoczonym ekosystemie — należny kredyt</summary>

[karpathy/llm-council](https://github.com/karpathy/llm-council) ·
[council-review](https://github.com/ngmeyer/council-review) ·
[council-of-high-intelligence](https://github.com/0xNyk/council-of-high-intelligence) ·
[llm-consortium](https://github.com/irthomasthomas/llm-consortium) ·
[Agent Skills](https://github.com/anthropics/skills) Anthropic.

Wyróżniki tutaj to **adaptacyjny Marszałek**, **pakowanie cross-tool** i jawny rozdział
**doradczy-vs-bramka**.

</details>

## Kontrybucje, changelog, licencja

PR-y mile widziane — patrz [CONTRIBUTING.md](CONTRIBUTING.md) (jedna ważna zasada: **trzymaj edycje EN
i PL w parytecie**; CI tego pilnuje). Historia w [CHANGELOG.md](CHANGELOG.md).

MIT © 2026 Michał Witczak.
