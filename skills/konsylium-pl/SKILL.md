---
name: konsylium
description: Wewnętrzne konsylium AI z wielu perspektyw. Meta-krok „Marszałek" czyta treść pytania i dobiera panel 3–6 person (architekt, sceptyk/red-team, pragmatyk + persony domenowe: bezpieczeństwo, integralność danych, koszt, wydajność), pyta każdą niezależnie (blind), a potem syntezuje jeden werdykt z zachowanym dissentem i sekcją „czego nie wiemy". Użyj przy nietrywialnej lub trudnej do odwrócenia decyzji, wyborze z 2–3 alternatyw, stress-teście opcji, do której się skłaniasz, przy pisaniu design doc/ADR, albo gdy model krąży w kółko. To PRE-CHECK dywergencyjny, który zasila decyzję — nigdy bramka merge (decyduje człowiek). Dla prawdziwie niezależnej bramki cross-model routuje do narzędzia konsensusu wielomodelowego, zamiast udawać niezależność jednym dostawcą.
---

# /konsylium — wewnętrzne konsylium AI z wielu perspektyw

## Cel

Dać jedną komendę, która w sesji odpala równoległe konsylium perspektyw na pytanie i
zwraca jeden werdykt z zachowanym dissentem — zamiast pojedynczej, pewnej siebie opinii,
i bez ręcznego pastowania tego samego promptu do kilku chatbotów.

Najdroższy koszt w pracy nad softem to rzadko napisanie kodu — to **zbudowanie złej rzeczy**.
Konsylium przesuwa krytykę (architekt, sceptyk, pragmatyk, eksperci domenowi) na początek,
żeby wada wyszła ZANIM się zaangażujesz, a nie trzy sprinty później.

Konsylium to **wejście dywergencyjne do decyzji** — nie domyka jej i nigdy nie jest bramką
merge. Decyduje człowiek.

## Kiedy używać

- nietrywialna, trudna do odwrócenia decyzja; kontrakt/interfejs/inwariant; bezpieczeństwo/koszt,
- wybór z 2–3 alternatyw technicznych, gdy odpowiedź nie jest oczywista,
- masz jedną opcję i chcesz ją zaatakować (steelman opozycji),
- piszesz design doc / ADR i chcesz dywergencji zanim to zamkniesz,
- model (albo Ty) krąży w kółko — powtarzane propozycje, 2+ nieudane próby.

## Kiedy NIE używać

- pytania trywialne/faktograficzne → odpowiedz wprost; nie pal subagentów,
- czysta egzekucja („po prostu zrób") → zrób,
- bramka merge wymagająca prawdziwie niezależnych rodzin modeli → to Tryb B (niżej),
  nie Tryb A. Konsylium subagentów jednego dostawcy nie jest niezależne.

Reguła: **trywialne → nie. Architektura / kontrakt / nieodwracalne → tak.**

---

## Tryb A — doradczy / dywergencja (DOMYŚLNY)

Subagenci w sesji, tanio. Cztery kroki. **Nie pomijaj kroku 1 (panel), 2 (blind) ani 4 (dissent).**

### 1. Framing + Marszałek (adaptacyjny dobór panelu)
Doprecyzuj pytanie w 1–2 zdaniach. Następnie uruchom **Marszałka (P0, `references/persony.md`)**
— meta-personę, która czyta TREŚĆ pytania i dobiera panel **3–6 person** pokrywający tryby
porażki specyficzne dla TEGO problemu, zamiast generycznej czwórki. Marszałek może:
(a) wybrać z bazy P1–P5, albo (b) **utworzyć persony domenowe ad-hoc** (np. Bezpieczeństwo/
Compliance, Integralność danych, Prywatność, Koszt/FinOps, Wydajność/skala — paleta w persony.md).

**Twarde guardraile:** zawsze ≥1 adwersarz (Sceptyk/Red-Team); max 6 person; każda persona
pokrywa INNY tryb porażki (zero nakładania); jednolinijkowe „po co" per persona.
**Szybka ścieżka:** dla oczywistego, wąskiego pytania Marszałek zwraca P1–P3.
Pokaż wybrany panel + uzasadnienia (krótko), potem dispatch (krok 2).

### 2. Blind first pass (anty-konformizm #1)
Każdą personę z panelu Marszałka odpal jako **osobny subagent w izolowanym kontekście**.
Każdy dostaje: pytanie + framing + SWÓJ prompt persony. **Żaden nie widzi odpowiedzi
pozostałych.** Wysyłaj je równolegle. Każdy zwraca: stanowisko + 2–3 argumenty + 1 własną słabość.

### 3. Anonimizacja
Zbierz odpowiedzi i podpisz P1..Pn (bez nazw person, bez kolejności ujawniającej rangę).
Kasuje order/brand bias przed syntezą.

### 4. Chairman synteza (z kwotą dissentu)
W świeżym podejściu przeczytaj P1..Pn jako dane i napisz werdykt wg `assets/OUTPUT_TEMPLATE.md`:
- **Rekomendacja** (jedna, asertywna, uzasadniona),
- **Gdzie się różnili** (kwota dissentu — nazwij którą perspektywą była mniejszość),
- **Czego nie wiemy / co tracimy** (prowadź nierozstrzygniętym, nie pewnym konsensusem),
- **Następny ruch**.
Split ~50/50 → **powiedz to**, nie udawaj konsensusu.

---

## Tryb B — bramka / ewaluator (ROUTING, nie reimplementacja)

Gdy decyzja jest high-risk i wymaga **prawdziwej niezależności rodziny modeli** (bramka merge,
ruch nieodwracalny), NIE rób tego subagentami jednego dostawcy. Zamiast tego:
1. Przygotuj samowystarczalne pytanie (kontekst + ≤5 pytań + oczekiwany format).
2. Zroutuj do narzędzia cross-model:
   - automatyczny konsensus wielomodelowy → np. skill `swarm-consensus` albo `llm-consortium`
     (różne rodziny; arbitra pinuj do nie-członka, żeby ewaluator ≠ generator),
   - albo ręczna druga opinia cross-AI (wklejenie do modelu innego dostawcy).
3. Wynik bramki jest **upstream do**, nie zamiast, decyzji człowieka.

Tryb B tylko routuje. Nie udaje niezależności i nie kopiuje logiki tamtych narzędzi.

---

## Zasady twarde

- **Pre-check, nie bramka.** Tryb A nigdy nie gate'uje merge — decyduje człowiek.
- **Nigdy dane prywatne/wrażliwe do modelu w chmurze.** Pytanie je zawiera → STOP, zostaje
  lokalnie, routing Tryb B do chmury zablokowany.
- **Bez sekretów** w promptach do person/zewnętrznych modeli. Nie echo, nie log.
- **Lekko, bez rund.** 1 blind pass + 1 synteza. Bez N-rundowej debaty — dowody pokazują, że
  więcej rund nie poprawia jakości i sprzyja konformizmowi (patrz README „Uczciwe ograniczenia").
- **Prawdziwa różnorodność > liczba.** 3–4 dobrze dobrane persony biją 8 podobnych.
- **Uczciwy dissent.** Split 50/50 mówimy wprost; fałszywy konsensus gorszy niż „nie wiemy".

## Powiązane

- Skill konsensusu wielomodelowego (np. `swarm-consensus`) — silnik Trybu B.
- Werdykt zasil swoim procesem decyzyjnym/ADR — konsylium otwiera, nie domyka.
