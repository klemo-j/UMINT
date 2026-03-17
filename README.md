# Zadanie 4: Alokácia investícií do finančných produktov

## 1. Cieľ úlohy
Cieľom tohto zadania je navrhnúť optimálnu alokáciu investícií firmy do 5 rôznych finančných produktov pomocou genetického algoritmu (GA). Celkový rozpočet je 10 000 000 EUR. Úlohou je maximalizovať ročný výnos a zároveň striktne dodržať všetky definované finančné a strategické ohraničenia. Súčasťou úlohy je analýza a porovnanie vplyvu troch rôznych metód pokutovania (mŕtva, stupňovitá a úmerná pokuta) na konvergenciu algoritmu a kvalitu nájdeného riešenia.

---

## 2. Matematický model a ohraničenia
**Cieľová funkcia (Maximalizácia výnosu):**
J(x) = 0.04x_1 + 0.07x_2 + 0.11x_3 + 0.06x_4 + 0.05x_5 -> max

**Ohraničenia riešenia:**
1. Celková investícia nesmie prekročiť rozpočet: SUM(x_i) <= 10 000 000
2. Investície do akcií nesmú prekročiť 2.5 milióna: x_1 + x_2 <= 2 500 000
3. Štátne dlhopisy nesmú byť menšie než úspory: x_4 >= x_5
4. Dlhopisy tvoria max 50% celkovej sumy: x_3 + x_4 <= 0.5 * SUM(x_i)

---

## 3. Obhajoba nastavení Genetického Algoritmu
Pre zabezpečenie stabilnej konvergencie a férového porovnania metód pokutovania bolo zvolené jedno spoločné, robustné nastavenie GA. Tieto parametre boli vybrané na základe charakteru úlohy (spojitý priestor hľadania s prísnymi ohraničeniami):

* **Veľkosť populácie (NIND = 200) a počet generácií (MAXGEN = 400):** Priestor hľadania je obrovský (každá z 5 premenných môže nadobúdať hodnoty od 0 do 10 miliónov). Väčšia populácia zabezpečuje dostatočnú diverzitu na začiatku hľadania, zatiaľ čo vyšší počet generácií dáva algoritmu čas na "doplazenie sa" k optimálnym hraniciam ohraničení.
* **Kríženie a Elitizmus (GGAP = 0.8):** 80 % populácie sa v každej generácii nahrádza novými potomkami vytvorenými dvojbodovým krížením (`crossov(..., 2, 0)`). Zvyšných 20 % najlepších jedincov z predchádzajúcej generácie prežíva vďaka funkcii `selsort`, čo garantuje, že algoritmus nikdy nestratí už nájdené dobré riešenie (elitizmus).
* **Selekcia (`selsus`):** Pre minimalizáciu straty diverzity bola zvolená selekcia metódou váhovaného ruletového kolesa (Stochastic Universal Sampling). **Trik implementácie:** Keďže funkcie v toolboxe sú stavané na hľadanie minima, do selekcie bola posielaná reálna kladná hodnota výnosu so záporným znamienkom (`-ObjV`), čo donútilo GA vyberať jedince s najvyšším ziskom.
* **Strategická mutácia (`mutx` + `muta`):** Pravdepodobnosť mutácie bola nastavená na `PM = 0.2`. Úloha vyžaduje kombináciu dvoch prístupov:
  1. Hrubá mutácia (`mutx`): Zabezpečuje preskakovanie v priestore (exploration) nahradením génu úplne novým číslom.
  2. Jemná mutácia (`muta` s `Amp = 5000`): Toto je pre finančnú úlohu **absolútne kľúčové**. Keď sa algoritmus dostane tesne k hranici limitu (napríklad k rozpočtu 10 miliónov), hrubá mutácia by ho zakaždým "odkopla" preč a spôsobila by porušenie limitu. Jemná mutácia iba pripočíta/odpočíta malú sumu (max 5000 EUR), vďaka čomu sa riešenie dokáže dokonale "prilepiť" na hranicu ohraničení bez toho, aby ju prekročilo.

---

## 4. Výsledky experimentov pre jednotlivé metódy pokutovania
Nasledujúce výsledky reprezentujú najlepšie nájdené alokácie z 5 nezávislých behov pre každú metódu.

### A) Mŕtva pokuta (Death Penalty)
Pri porušení akéhokoľvek ohraničenia bola riešeniu okamžite udelená fixná pokuta 5 000 000 EUR.
* **Nájdený výnos / Fitness:** -1 700 000.00 EUR (Zlyhanie)
* **Zhodnotenie:** Algoritmus investoval 10M do každého produktu (celkovo 50M). Extrémne tvrdá pokuta zamedzila algoritmu rozlíšiť, či prekročil rozpočet o 1 Euro alebo o milióny. Hľadanie sa stalo slepým a nenašlo sa žiadne platné riešenie.

### B) Stupňovitá pokuta (Step Penalty)
Za každé porušené ohraničenie bola udelená pokuta 500 000 EUR (záležalo na počte porušených pravidiel).
* **Nájdený výnos / Fitness:** 2 300 000.00 EUR (Zlyhanie)
* **Zhodnotenie:** Algoritmus opäť vložil 10M do každej položky. Zistil totiž, že obrovský nereálny výnos (z 50M investície) hravo prevýši paušálnu pokutu za počet porušení. Riešenie je v praxi neprípustné.

### C) Úmerná pokuta (Proportional Penalty) - Najlepšia metóda
Pokuta bola presne viazaná na mieru porušenia ohraničenia (veľkosť pokuty = 2.0 * suma prekročenia).
* **Nájdený výnos / Fitness:** 714 675.68 EUR (Úspech)
* **Optimálna alokácia:**
  * Bežné akcie (x_1): 342 545.47 EUR
  * Preferované akcie (x_2): 2 157 161.08 EUR
  * Podnikové dlhopisy (x_3): 2 499 188.24 EUR
  * Štátne dlhopisy (x_4): 2 500 717.92 EUR
  * Úspory v banke (x_5): 2 500 376.01 EUR
* **Zhodnotenie:** Všetky ohraničenia boli splnené (kontrolné hodnoty skončili v záporných číslach, čo predstavuje povolenú rezervu). Algoritmus mal k dispozícii plynulý gradient, ktorý ho presne navigoval do prípustnej oblasti.

### D) Bez pokuty (Referenčný beh)
* **Nájdený výnos / Fitness:** 3 300 000.00 EUR
* **Zhodnotenie:** Algoritmus podľa očakávaní kompletne odignoroval pravidlá. Slúži to ako jasný dôkaz, že bez správne navrhnutej penalizácie je maximalizačný algoritmus v ohraničenom priestore nepoužiteľný.

---

## 5. Finálna vizualizácia a diskusia konvergencie

![Graf konvergencie metód pokutovania](https://github.com/klemo-j/UMINT/raw/5912b6e524da4a80bbb53f8cc802c5850bcbe1ea/CV4/graf.png)

**Čítanie z grafu (Záver):**
Na grafe je jednoznačne vidieť rozdielne správanie metód:
* **Čierna čiara (Bez pokuty):** Okamžite vyletela na maximum, keďže ju nič neobmedzovalo.
* **Červená a Zelená čiara (Mŕtva a Stupňovitá pokuta):** Začínajú hlboko v mínusových hodnotách a konvergujú veľmi slabo na neplatných, penalizovaných riešeniach. Skokové zmeny znamenajú, že algoritmus narazil na "stenu" fixnej pokuty, ktorú nevie plynule prekonať.
* **Modrá čiara (Úmerná pokuta):** Predstavuje ukážkovú a ideálnu konvergenciu. Začína v záporných číslach (keď náhodná populácia porušuje limity), ale vďaka úmernému pokutovaniu sa algoritmus rýchlo a plynule "učí" znižovať chybu, až kým neprerazí do kladných čísel a stabilizuje sa tesne pod hranicou absolútneho teoretického maxima (~725 000 EUR).
