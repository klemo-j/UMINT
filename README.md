# Zadanie 4: Alokácia investícií do finančných produktov

## 1. Cieľ úlohy
Cieľom tohto zadania je navrhnúť optimálnu alokáciu investícií firmy do 5 rôznych finančných produktov pomocou genetického algoritmu (GA). Celkový rozpočet je 10 000 000 EUR. Úlohou je maximalizovať ročný výnos a zároveň striktne dodržať všetky definované finančné a strategické ohraničenia. Súčasťou úlohy je analýza a porovnanie vplyvu troch rôznych metód pokutovania (mŕtva, stupňovitá a úmerná pokuta), ako aj analýza vplyvu samotnej veľkosti úmernej pokuty na konvergenciu algoritmu.

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

## 4. Porovnanie hlavných metód pokutovania a analýza grafu
Po správnom nastavení výšky pokút (aby sa algoritmu neoplatilo limity ignorovať) sme dosiahli ukážkové správanie všetkých metód:

1. **Úmerná pokuta (Modrá čiara - Najlepšia metóda):** Pokuta viazaná na presnú mieru porušenia (vzdialenosť od limitu) poskytla algoritmu okamžitý a plynulý gradient. Algoritmus vďaka nej vôbec netápal v záporných číslach, takmer okamžite našiel prípustnú oblasť a stabilne konvergoval k teoretickému maximu (~714 000 EUR).
2. **Stupňovitá pokuta (Zelená čiara):** Trest bol nastavený na prísne 4 milióny za každé porušené pravidlo. Algoritmus začal hlboko v mínuse (všetci jedinci v nultej generácii porušovali pravidlá), no keďže pokuta klesá "schodovito" (2 porušenia sú lepšie ako 3), algoritmus mal aspoň čiastočný návod. Preto sa už okolo 15. generácie dokázal "prehryznúť" do platnej oblasti a dorovnal sa na úmernú pokutu.
3. **Mŕtva pokuta (Červená čiara):** Najmenej efektívny prístup. Keďže akékoľvek porušenie znamenalo tvrdý pád na fixných -5 000 000 EUR, algoritmus nemal žiadnu nápovedu, či sa zlepšuje alebo zhoršuje. Hľadanie bolo slepé, čo na grafe vidieť ako dlhú rovnú čiaru na dne. Až okolo 115. generácie úplnou náhodou (mutáciou) trafil do prípustnej oblasti a následne vystrelil do kladných čísel.
4. **Bez pokuty (Čierna čiara - Referencia):** Algoritmus odignoroval pravidlá, investoval 50 miliónov (všetky položky na maximum) a vygeneroval nereálny zisk vyše 3.3 milióna EUR (extrémne prekročenie firemného rozpočtu).

---

## 5. Analýza vplyvu VEĽKOSTI pokuty (Citlivosť na parametre)
Aby sme pochopili citlivosť algoritmu na veľkosť pokuty, otestovali sme úmernú pokutu s rôznymi násobiteľmi:

* **Príliš malá pokuta (napr. 0.01x porušenia):** Algoritmus ohraničenia porušuje. Ak je výnos z nepovolenej investície (napr. 11% z dlhopisov) vyšší ako pokuta za nedodržanie limitu, algoritmus doslova "zarába na podvádzaní". Limity ignoruje a tvári sa, že dosiahol obrovský výnos.
* **Optimálna pokuta (napr. 2.0x porušenia):** Pokuta je dostatočne veľká na to, aby sa porušovanie neoplatilo, no zároveň dostatočne mierna na to, aby algoritmu poskytla plynulú navigáciu k hranici (napr. k 10 miliónom).
* **Príliš veľká pokuta (napr. 1000x porušenia):** Konvergencia je nestabilná. Algoritmus je z hranice "vydesený" (drobná mutácia vyvolá astronomickú pokutu). Odrazí sa od nej preč a uspokojí sa s bezpečným, avšak veľmi neefektívnym a nízkym výnosom hlboko pod limitom.

---

## 6. Finálna vizualizácia konvergencie

![Graf konvergencie metód pokutovania a veľkostí pokút](https://github.com/klemo-j/UMINT/raw/3b0314388ee8db09d44d94d5f9a97ea30275458b/CV4/lepsigrag.png)

**Záver:**
Graf krásne demonštruje rozdiel v gradientoch. Mŕtva pokuta (červená) bez gradientu dlho tápe naslepo. Stupňovitá (zelená) s hrubým gradientom sa chytí rýchlejšie. Úmerná pokuta (modrá) má dokonalý hladký gradient a dominuje od prvej generácie. Krivka "bez pokuty" (čierna) slúži ako dôkaz, že optimalizácia v ohraničenom priestore bez penalizácie vedie k nereálnym a nepoužiteľným výsledkom.
