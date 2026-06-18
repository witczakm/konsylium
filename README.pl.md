# konsylium

> **Panel doradców AI zamiast jednej pewnej siebie odpowiedzi.** Jedna komenda zwołuje 3–6 doradców, którzy niezależnie oceniają Twoją decyzję z różnych stron — i oddają jeden werdykt z jasnym „w czym się różnili" oraz „czego jeszcze nie wiadomo".
>
> *Wieloperspektywiczne konsylium AI dla Claude Code, Codex i aplikacji Claude. Jedna komenda · panel w ślepo · uczciwy dissent — pre-check, nie bramka.*
>
> 🇬🇧 [English version](README.md)

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![CI](https://github.com/witczakm/konsylium/actions/workflows/validate.yml/badge.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-d97757)
![Codex](https://img.shields.io/badge/Codex-skill-111111)
![Claude app](https://img.shields.io/badge/Claude%20app-skill-8a63d2)

![konsylium — przykład działania](assets/konsylium-demo.svg)

<details>
<summary><b>Spis treści</b></summary>

- [Szybki start](#szybki-start)
- [Zobacz przykład](#zobacz-przykład)
- [Po co to?](#po-co-to)
- [Jak to działa](#jak-to-działa)
- [Czy to dla Ciebie?](#czy-to-dla-ciebie)
- [Instalacja](#instalacja)
- [Możesz też z terminala](#możesz-też-z-terminala)
- [Prywatność i bezpieczeństwo](#prywatność-i-bezpieczeństwo)
- [Szczerze: czego to NIE robi](#szczerze-czego-to-nie-robi)
- [Czy to naprawdę działa?](#czy-to-naprawdę-działa)
- [Na czym bazuje (podziękowania)](#na-czym-bazuje-podziękowania)
- [Współtworzenie i licencja](#współtworzenie-i-licencja)

</details>

## Szybki start

```sh
git clone https://github.com/witczakm/konsylium.git && cd konsylium
sh install.sh --lang pl        # podgląd bez zmian: dopisz --dry-run
```

Potem w **nowej sesji Claude Code** zadaj realne pytanie, np.:

```
/konsylium monolit czy mikroserwisy dla małego zespołu?
/konsylium podnieść ceny o 30% teraz, czy poczekać?
/konsylium jedna tabela na dane klientów, czy rozdzielić?
```

…albo cokolwiek własnego: `/konsylium <Twoja decyzja>`.

Dostajesz jeden werdykt w stałym formacie:

```text
Rekomendacja: monolit — jeden zespół, jeden deploy; mikroserwisy dokładają
  koszt operacyjny, którego teraz nie odkupisz.
W czym się różnili: Architekt vs Pragmatyk — granice modułów (napięcie
  wartości, nie błąd).
Czego nie wiemy: [DO SPRAWDZENIA] przewidywany ruch i cele SLA.
Następny ruch: zapisz jako ADR; jeśli decyzja nieodwracalna → Tryb B.
```

Instalację w Codex i aplikacji opisuję niżej.

## Zobacz przykład

Ktoś zapytał, jak zaprojektować bazę danych (gdzie trzymać dane klientów). Zamiast jednej odpowiedzi,
konsylium samo dobrało doradców od **prywatności, zgodności z prawem i porządku w danych** — i dwóch
z nich niezależnie złapało rzecz, którą zwykła odpowiedź by pominęła:

> **Rekomendacja:** rozdziel dane na osobne tabele i zapisz „migawkę” danych z chwili oceny — bo
> późniejsza poprawka nazwy nie może zmienić historii wcześniejszej decyzji.
> **W czym się różnili:** jeden doradca dopuścił prostsze rozwiązanie na start; inny ostro je podważył.
> **Czego nie wiemy:** czy to dane osób fizycznych (wtedy wchodzi RODO)…

Pełny werdykt i trzy inne decyzje → **[examples/](examples/)** (na razie po angielsku).

## Po co to?

Najgorsze decyzje wyglądają na świetne — aż do chwili, gdy jest za późno. Zwykle nie chodzi o zły kod,
tylko o zbudowanie **nie tej rzeczy**. Druga opinia by pomogła, ale komu chce się ręcznie odpytywać trzy
modele i sklejać odpowiedzi? konsylium robi to za Ciebie jedną komendą — i wytyka słabe punkty, **zanim**
się w nie wpakujesz.

## Jak to działa

Rytm jest prosty — jedno pytanie **rozchodzi się** na kilku niezależnych doradców i **schodzi z powrotem**
w jeden werdykt:

```
              Twoje pytanie
                    │
              Przewodniczący          → dobiera 3–6 doradców pod pytanie
                    │
        ┌─────┬─────┼─────┬─────┐     ↓ ROZEJŚCIE — każdy osobno (blind),
        ▼     ▼     ▼     ▼     ▼        w osobnym, czystym kontekście
     architekt sceptyk dane koszt …
        └─────┴─────┼─────┴─────┘     ↑ ZEJŚCIE — synteza, bez nazwisk
                    ▼
              Werdykt
     rekomendacja · w czym się różnili · czego nie wiemy
                    │
                    ▼
              Ty decydujesz
```

Krok po kroku:

1. **Dobór panelu.** „Przewodniczący” czyta Twoje pytanie i dobiera 3–6 doradców pasujących właśnie do
   niego (np. architekt, sceptyk, specjalista od danych). Zawsze jest ktoś, kto gra adwokata diabła.
2. **Niezależne opinie.** Każdy doradca odpowiada osobno, **nie widząc pozostałych** — dzięki temu się
   nie kopiują i nie podpinają pod cudze zdanie.
3. **Bez nazwisk.** Opinie idą do podsumowania anonimowo, żeby liczył się argument, nie „kto to powiedział”.
4. **Werdykt.** Dostajesz jedną rekomendację, jasne „w czym się różnili” oraz uczciwe „czego nie wiemy”
   i następny krok.

To **pomoc w decyzji, nie wyrok** — ostatnie słowo zawsze masz Ty.

### Dwa tryby

| Tryb | Kiedy | Co dostajesz |
|------|-------|--------------|
| **A — doradczy** (domyślny) | większość decyzji | 3–6 doradców w jednej sesji, blind, jeden werdykt — szybko |
| **B — bramka** | ważne / nieodwracalne | routing do modeli AI **różnych firm** dla prawdziwej niezależności |

Panel z jednego dostawcy to nie to samo co opinia niezależnej, innej firmy — dlatego decyzje wysokiego ryzyka eskalują do Trybu B.

## Czy to dla Ciebie?

✅ **Tak**, jeśli: decyzja jest trudna do cofnięcia albo kosztowna · wybierasz z 2–3 opcji i nie jest oczywiste · masz pomysł i chcesz, żeby ktoś go uczciwie podważył · zamykasz ważny dokument/plan i chcesz wcześniej innych spojrzeń.

❌ **Raczej nie**, jeśli: pytanie jest proste i oczywiste — jedna odpowiedź w zupełności wystarczy.

## Instalacja

**Czego potrzebujesz:** Claude Code lub Codex (albo aplikacja Claude). W repozytorium są dwie wersje
językowe — angielska i polska; obie dają komendę `/konsylium`.

```sh
sh install.sh --dry-run --lang pl   # podgląd — niczego nie zapisuje
sh install.sh --lang pl             # instalacja (polski) do Claude Code + Codex
```

Stara instalacja jest zapisywana w kopii zapasowej, nigdy po cichu nadpisywana. Potem zacznij nową sesję.

<details>
<summary><b>Codex, aplikacja desktop, wersja angielska</b></summary>

- **Wersja angielska:** `sh install.sh`
- **Tylko jedno narzędzie:** dopisz `--claude-only` lub `--codex-only`
- **Aplikacja Claude / Cowork** (wczytuje plik ZIP, nie czyta folderów):
  Customize → Skills → **„+” → Create skill** → wgraj `dist/konsylium-pl.zip` (lub `-en`) → włącz **ON**.

</details>

## Możesz też z terminala

Nie musisz być w czacie — zadziała też jedną linijką (przydatne do automatyzacji, np. w CI):

```sh
claude -p "/konsylium czy zacząć od jednej tabeli czy rozdzielić dane?"
codex exec "użyj skilla konsylium: monolit czy mikroserwisy dla małego zespołu?"
```

Wynik możesz zapisać do pliku (`> werdykt.md`) i wkleić do notatek, opisu zmiany czy dokumentu decyzji.

## Prywatność i bezpieczeństwo

- **Sam skill niczego nie wysyła do internetu i nie zbiera żadnych danych** — to zwykłe instrukcje
  tekstowe; jedyny skrypt (`install.sh`) tylko kopiuje pliki lokalnie.
- Do chmury cokolwiek trafia tylko wtedy, gdy **Ty** świadomie użyjesz trybu „dla ważnych decyzji”.
- **Nie wklejaj haseł ani danych wrażliwych** do pytania.

Szczegóły i zgłaszanie problemów → [SECURITY.md](SECURITY.md).

## Szczerze: czego to NIE robi

Bez obiecywania cudów:

- **To pomoc w myśleniu, nie wyrocznia.** Przy prostym pytaniu nie używaj — jedna odpowiedź wystarczy.
- **To samo pytanie może dać trochę inny skład doradców i inną odpowiedź.** W trybie zwykłym to celowe —
  chodzi o różne spojrzenia (potrzebujesz powtarzalności? → tryb dla ważnych decyzji).
- **Doradcy mogą brzmieć różnie, a myśleć podobnie.** Pilnujemy, żeby każdy patrzył pod innym kątem,
  ale tego nie mierzymy.
- **Kosztuje trochę więcej niż jedno pytanie** (uruchamia kilka opinii naraz). Używaj do decyzji, które
  mają znaczenie — i tak taniej niż zbudować złą rzecz.
- **Bez kłótni w kółko.** Z badań wynika, że zmuszanie AI do wielu rund dyskusji nie poprawia jakości
  (a czasem psuje), więc robimy jedną rundę.

## Czy to naprawdę działa?

Nie obiecuję, że zawsze. Zrobiłem mały, uczciwy test na **5 realnych decyzjach**: pomogło w **4**
(raz wyraźnie, trzy razy średnio), a **raz wcale** (proste pytania nie potrzebują panelu). Szczegóły:
[EVALS.md](EVALS.md). Traktuj to jako sposób na szersze spojrzenie, nie nieomylną wyrocznię.

## Na czym bazuje (podziękowania)

Pomysł „panelu AI” nie jest nowy — ukłon w stronę:
[karpathy/llm-council](https://github.com/karpathy/llm-council),
[council-review](https://github.com/ngmeyer/council-review),
[council-of-high-intelligence](https://github.com/0xNyk/council-of-high-intelligence),
[llm-consortium](https://github.com/irthomasthomas/llm-consortium),
[Agent Skills](https://github.com/anthropics/skills) Anthropic.

Co konsylium dokłada od siebie: **panel dobierany pod pytanie** (nie sztywna lista), **działanie w kilku
narzędziach z jednej paczki**, i jasny podział na **„doradzanie” a „niezależną kontrolę”**. Konkretne
zapożyczone pomysły i ich licencje: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

<details>
<summary><b>Dla technicznie zainteresowanych</b></summary>

- To **skill** (instrukcja w Markdown, którą wykonuje AI) — nie serwer, nic nie trzeba uruchamiać ani utrzymywać.
- Każdy doradca działa w **osobnym, czystym kontekście**; do głównej rozmowy wraca tylko podsumowanie.
- Skille **nie synchronizują się** między narzędziami — w każdym (Claude Code, Codex, aplikacja) instalujesz osobno.
- Tryb „dla ważnych decyzji” kieruje pytanie do narzędzia konsensusu wielomodelowego (np.
  [`llm-consortium`](https://github.com/irthomasthomas/llm-consortium)), tak by oceniał inny model niż ten,
  który generował — i to zawsze przed, nie zamiast, decyzji człowieka.

</details>

## Współtworzenie i licencja

PR-y mile widziane — patrz [CONTRIBUTING.md](CONTRIBUTING.md). Historia zmian: [CHANGELOG.md](CHANGELOG.md).

MIT © 2026 Michał Witczak. Korzystaj śmiało.
