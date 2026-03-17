# Zadanie 4: Alokácia investícií do finančných produktov

## 1. Cieľ úlohy
Cieľom tohto zadania je navrhnúť optimálnu alokáciu investícií firmy do 5 rôznych finančných produktov pomocou genetického algoritmu (GA). Celkový rozpočet je 10 000 000 EUR. Úlohou je maximalizovať ročný výnos a zároveň striktne dodržať všetky definované finančné a strategické ohraničenia. Súčasťou úlohy je analýza a porovnanie vplyvu troch rôznych metód pokutovania (mŕtva, stupňovitá a úmerná pokuta), ako aj **analýza vplyvu samotnej veľkosti úmernej pokuty** na konvergenciu algoritmu.

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
Pre zabezpečenie stabilnej konvergencie a férového porovnania bolo zvolené robustné nastavenie:
* **Veľkosť populácie (NIND = 200) a generácií (MAXGEN = 400):** Obrovský spojitý priestor (0 až 10M pre 5 premenných) si vyžaduje väčšiu populáciu pre diverzitu a dostatok času na konvergenciu k hraniciam ohraničení.
* **Elitizmus a Selekcia (`selsus`, `selsort`):** Pre minimalizáciu straty diverzity sa používa ruletová selekcia. Keďže Toolbox minimalizuje, fitness (výnos) bol algoritmu podsunutý so záporným znamienkom (`-ObjV`), aby vyberal jedince s najvyšším ziskom.
* **Strategická mutácia (`mutx` + `muta`):** Bola použitá kombinácia hrubej a aditívnej mutácie. Jemná mutácia (`muta` s `Amp = 5000`) je tu absolútne kľúčová. Keď sa algoritmus priblíži k hranici limitu, hrubá mutácia by ho "odkopla" do neplatnej oblasti. Jemná mutácia umožňuje precízne "dobrusovanie" súm na eurá bez porušenia ohraničení.

---

## 4. Porovnanie hlavných metód pokutovania
1. **Mŕtva pokuta (Death Penalty):** Algoritmus nedokázal nájsť prípustné riešenie a zasekol sa v zápornej fitness. Fixná tvrdá pokuta zamedzila algoritmu rozlíšiť, či je riešenie blízko alebo ďaleko od splnenia limitov (slepé hľadanie).
2. **Stupňovitá pokuta (Step Penalty):** Algoritmus zlyhal, pretože fixná pokuta za porušené pravidlo nebola dostatočne silná voči masívnemu zisku z investovania 10M do všetkých produktov.
3. **Úmerná pokuta (Proportional):** Najlepšia metóda. Pokuta viazaná na presnú mieru porušenia (vzdialenosť od limitu) poskytla GA plynulý gradient, ktorý ho naviedol k optimálnemu prípustnému zisku okolo ~714 600 EUR.
4. **Bez pokuty (Referencia):** Algoritmus odignoroval pravidlá, investoval 50 miliónov a vygeneroval nereálny zisk vyše 3.3 milióna EUR (extrémne prekročenie firemného rozpočtu).

---

## 5. Analýza vplyvu VEĽKOSTI pokuty (Citlivosť na parametre)
Aby sme pochopili citlivosť algoritmu na veľkosť pokuty, otestovali sme **Úmernú pokutu** s tromi rôznymi násobiteľmi (`pokuta = suma_poruseni * NÁSOBOK`):

* **A) Príliš malá pokuta (Násobok 0.01x)**
  * *Výsledok:* Algoritmus ohraničenia **porušil**. 
  * *Zdôvodnenie:* Ak prekročíme rozpočet o 1 000 000 EUR a investujeme to do dlhopisov (výnos 11%), získame 110 000 EUR. Ak je pokuta len 0.01-násobok porušenia, algoritmus zaplatí pokutu 10 000 EUR, ale v čistom získa +100 000 EUR. Algoritmus doslova "zarába na porušovaní predpisov", a preto ich ignoruje a tvári sa, že dosiahol obrovský výnos.
* **B) Optimálna pokuta (Násobok 2.0x)**
  * *Výsledok:* Algoritmus našiel **absolútne teoretické maximum** bez porušenia.
  * *Zdôvodnenie:* Pokuta je dostatočne veľká na to, aby sa porušovanie neoplatilo, no zároveň dostatočne mierna na to, aby algoritmu poskytla plynulú navigáciu a nespôsobovala predčasnú stagnáciu.
* **C) Príliš veľká pokuta (Násobok 1000x)**
  * *Výsledok:* Konvergencia je **nestabilná** a algoritmus často nachádza veľmi podpriemerné riešenia.
  * *Zdôvodnenie:* Akákoľvek jemná mutácia v blízkosti ohraničenia (napr. chyba o 10 EUR) vyvolá astronomickú pokutu 10 000 EUR. Algoritmus je z hranice "vydesený", odrazí sa od nej preč a uspokojí sa s bezpečným, avšak veľmi neefektívnym a nízkym výnosom hlboko pod limitom.

---

## 6. Finálna vizualizácia konvergencie

![Graf konvergencie metód pokutovania a veľkostí pokút](https://github.com/klemo-j/UMINT/raw/5912b6e524da4a80bbb53f8cc802c5850bcbe1ea/CV4/graf.png)

**Čítanie z grafu (Záver):**
Graf jednoznačne potvrdzuje našu analýzu. Mŕtva a Stupňovitá pokuta padajú do nežiaducich záporných čísel. Krivka "Bez pokuty" nerealisticky vystrelí mimo akékoľvek limity. Úmerná pokuta s ideálnym násobiteľom (modrá) krásne konverguje na reálnu najvyššiu dosiahnuteľnú hodnotu bez porušenia limitov. 
Zároveň je dobre vidieť problém nesprávne nastavenej pokuty: Príliš malá pokuta ustrelí nereálne vysoko (lebo sa oplatí porušovať limity) a príliš veľká pokuta sa občas drží zbytočne hlboko pod optimom zo strachu pred penalizáciou.
