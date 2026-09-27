---
name: konsylium
description: Użyj przy nietrywialnej lub trudnej do odwrócenia decyzji (architektura, kontrakt/interfejs, bezpieczeństwo, koszt, migracja), przy wyborze z 2–3 alternatyw, stress-teście opcji do której się skłaniasz, przy pisaniu design doc/ADR, albo gdy model lub użytkownik krąży w kółko (2+ nieudane próby, powtarzane propozycje). NIE używaj do pytań trywialnych/faktograficznych, czystej egzekucji („po prostu zrób") ani jako bramki merge — konsylium to PRE-CHECK dywergencyjny, decyduje człowiek. Dla bramki wymagającej niezależności rodzin modeli → Tryb B (routing cross-model).
version: 2.1.0
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

**Wyzwalacz twardy (nie uznaniowy):** trzecia runda NO tej samej bramki w tej samej klasie błędu
= konsylium PRZED czwartą rundą, bez pytania. Powód: w projekcie, na którym to mierzono, opis
„krąży w kółko" nie zadziałał ani przy 11 rundach NO, ani przy 6 — konsylium ruszało dopiero na
polecenie człowieka. Licz rundy w dzienniku sesji; trzecia = dispatch.

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
Framing ma CZTERY wymagane pola — bez któregoś nie wysyłaj (persona bez nich zgaduje i zgaduje
tak samo jak Ty):

```
PYTANIE:        <1–2 zdania, co rozstrzygamy>
CO JUŻ ISTNIEJE: <kod / dane / dokumenty, które panel musi znać; ścieżki lub cytaty — nie „patrz repo">
STANOWISKO DECYDENTA: <co właściciel / radca / zamawiający już postanowił i czego nie negocjujemy>
LICZBY ŹRÓDŁOWE: <każda liczba, na której ma się oprzeć panel, z pochodzeniem; „brak" jeśli nie ma>
```
Powód dwóch środkowych: panel, który nie znał istniejącej bazy wiedzy, wydał werdykt do odrzucenia
(W9); panel, który nie znał stanowiska radcy, zalecił „nie budować" tego, co decydent już
zatwierdził. Powód ostatniego: głos, który sam „policzył" wymogi, podał 157 zamiast 215.

Następnie uruchom **Marszałka (P0, `references/persony.md`)**
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
pozostałych.** W Claude Code: **wszystkie dispatche w JEDNYM bloku wywołań narzędzi**
(jedna wiadomość = prawdziwa równoległość). Każdy zwraca: stanowisko + 2–3 argumenty
+ 1 własną słabość + **pewność 0–100** + **model faktyczny** + **liczby: przeliczone / z framingu / własne**
(pełna specyfikacja zwrotu: wspólny ogon w `references/persony.md` — dopisuj go każdej personie).
Model-tier (opcjonalnie, koszt): persony domenowe → tańszy model; adwersarz i architekt
→ model sesji. Przy wyborze „opcja A vs B" Marszałek przypisuje stance: ≥1 persona ZA,
≥1 PRZECIW (wymusza dywergencję zamiast konwergencji do średniej).

### 3. Anonimizacja + kontrola liczb + ranking krzyżowy
Zbierz odpowiedzi i podpisz P1..Pn (bez nazw person, bez kolejności ujawniającej rangę).
Kasuje order/brand bias przed syntezą.

**Kontrola liczb (obowiązkowa):** każda liczba w głosie oznaczona „własne" musi zostać przeliczona
na danych (skrypt/grep/wc) ZANIM trafi do syntezy; niezgodna → w werdykcie jako „P3 podał 157,
pomiar 215". Głos oparty na błędnej liczbie liczy się z pewnością 0.

**Ranking krzyżowy (domyślny, tańszy niż konfrontacja):** każdej personie wyślij zanonimizowane
stanowiska POZOSTAŁYCH (tasowana kolejność) z jednym poleceniem: „uszereguj od najlepiej
uzasadnionego do najsłabszego; podaj najsilniejszy cudzy argument, którego nie miałeś". Chairman
dostaje ranking zagregowany + te argumenty. Nikt nie zmienia własnego stanowiska (to nie debata).
Wzór: llm-council (Karpathy) — ranking daje sygnał do ważenia bez konformizmu rundy debaty.

### 4. Chairman synteza (z kwotą dissentu)
W świeżym podejściu przeczytaj P1..Pn jako dane i napisz werdykt wg `assets/OUTPUT_TEMPLATE.md`.
Chairman ≠ uczestnik: nie głosuje. High-stakes → syntezę może zrobić świeży subagent (czysty kontekst).

Agregacja wg typu pytania:
- **wybór z opcji (A/B/C)** → najpierw zestawienie głosów ważonych pewnością (wejście, nie wyrok),
- **pytanie otwarte/projektowe** → synteza narracyjna (bez głosowania — liczą się argumenty).

Werdykt zawiera:
- **Nagłówek z modelami faktycznymi** per głos (z logu/`--version`, nie z konfiguracji) — w Trybie B
  brak drugiej rodziny modeli to **DEGRADACJA zapisana w nagłówku**, nie ciche zastępstwo,
- **Rekomendacja** (jedna, asertywna, uzasadniona),
- **Gdzie się różnili** (kwota dissentu — min. jedna realna rozbieżność; nazwij którą perspektywą
  była mniejszość i oznacz każdą jako *napięcie wartości* (oba ważne — trade-off) lub *złapany błąd*
  (realna wada, którą inni przegapili)),
- **Czego nie wiemy / co tracimy** (prowadź nierozstrzygniętym, nie pewnym konsensusem),
- **Następny ruch**.
Split ~50/50 → **powiedz to**, nie udawaj konsensusu.
**Werdykt ZAWSZE do pliku:** `docs/reports/konsylium/YYYY-MM-DD-<temat>.md` (poza repo:
`~/audits/<data>-konsylium-<temat>/SYNTEZA.md`) — także przebieg inline, także 3 persony na szybko.
Werdykt tylko w czacie/dzienniku to werdykt, którego nie da się później skonfrontować z wynikiem.
Plik ma pole `Wynik po fakcie:` do uzupełnienia przy domykaniu decyzji (kalibracja panelu).

### 5. Konfrontacja (WARUNKOWA — tylko poniżej progu)
Uruchom TYLKO gdy po rankingu krzyżowym: (a) brak większości ważonej pewnością ≥ 60 % przy wyborze
z opcji, ALBO (b) dwa głosy o pewności ≥ 70 są sprzeczne w fakcie (nie w wartościach). Kryterium
liczbowe, nie „czuję split" — wzór: llm-consortium (próg pewności + limit iteracji).
**Max 1 runda** — badania pokazują, że kolejne rundy dokładają konformizmu, nie jakości.
Mechanika: każda persona dostaje **zanonimizowane** stanowiska pozostałych (A/B/C, tasowana
kolejność) + polecenie: „wskaż najsilniejszy cudzy argument; co zmieniasz, co podtrzymujesz
i dlaczego — **zmieniaj zdanie wyłącznie pod wpływem argumentu, nigdy liczebności**".
Po rundzie: re-synteza (krok 4). Spór nadal trwa → **eskalacja do człowieka**, nie kolejna runda.

### Po werdykcie: nudge (opcjonalny)
Użytkownik może zakwestionować założenie jednej persony. Odpal wtedy TYLKO tę personę ponownie
(z jej pierwotną odpowiedzią + kontrargumentem): „co zmieniasz / co podtrzymujesz i dlaczego".
Tańsze niż nowe konsylium; wynik dopisz do werdyktu jako aneks.

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
4. **Uruchamiaj wg `references/uruchomienie-cli.md`** (flagi, izolacja, limit czasu per CLI) —
   pierwsze uruchomienie zewnętrznego CLI psuło się w 3 z 3 przebiegów bez przepisu.
5. **Model faktyczny z logu**: każdy głos zapisuje, jaki model naprawdę odpowiedział (banner CLI,
   `--version`, nagłówek odpowiedzi). Konfiguracja obiecywała GPT w 8 rolach, a odpowiadał kimi-k3
   przez Ollamę — i żaden raport tego nie podniósł. Zastępstwo z tej samej rodziny = degradacja
   w nagłówku werdyktu.
6. **Dane dla zewnętrznego CLI = kopia tylko do odczytu** (`cp -R` + `chmod -R a-w`), nigdy żywy
   pakiet — sesje z CWD w żywym katalogu zapisywały do niego.

Tryb B tylko routuje. Nie udaje niezależności i nie kopiuje logiki tamtych narzędzi.

---

## Zasady twarde

- **Odpowiadaj w języku użytkownika.** Werdykt — i odpowiedzi każdej persony — pisz w języku pytania
  (pytanie po polsku → werdykt po polsku).
- **Pre-check, nie bramka.** Tryb A nigdy nie gate'uje merge — decyduje człowiek.
- **Nigdy dane prywatne/wrażliwe do modelu w chmurze.** Pytanie je zawiera → STOP, zostaje
  lokalnie, routing Tryb B do chmury zablokowany.
- **Bez sekretów** w promptach do person/zewnętrznych modeli. Nie echo, nie log.
- **Lekko domyślnie.** 1 blind pass + 1 synteza. Konfrontacja (krok 5) tylko przy realnym splicie
  i max 1 runda — N-rundowa debata nie poprawia jakości i sprzyja konformizmowi (Smit 2024;
  Wynn 2025 „Talk Isn't Always Cheap": agenci porzucają POPRAWNE odpowiedzi pod presją peerów).
- **Prawdziwa różnorodność > liczba.** 3–5 dobrze dobranych person bije 8 podobnych; ponad 5–6
  rośnie tylko korelacja błędów („Nine Judges, Two Effective Votes" 2026).
- **Uczciwy dissent.** Split 50/50 mówimy wprost; fałszywy konsensus gorszy niż „nie wiemy".
- **Uczciwa epistemika.** Panel person jednego modelu = dywersyfikacja perspektyw, NIGDY
  „niezależna ocena" — wspólne misconcepcje modelu przechodzą przez wszystkie persony.
  Tryb B też nie daje pełnej niezależności: gdy dwa modele różnych dostawców się mylą, w ~60 %
  wybierają TEN SAM błąd (Kim i in., ICML 2025). Zgodność głosów to słabszy dowód niż test lub
  pomiar — sporny fakt rozstrzygaj faktem, nie liczeniem głosów („Debate or Vote", NeurIPS 2025:
  zysk daje głosowanie, debata sama w sobie nie).

## Powiązane

- Skill konsensusu wielomodelowego (np. `swarm-consensus`) — silnik Trybu B.
- Werdykt zasil swoim procesem decyzyjnym/ADR — konsylium otwiera, nie domyka.
