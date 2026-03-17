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

## 4. Výsledky experimentov a kontrola ohraničení
Po správnom nastavení výšky pokút algoritmus úspešne otestoval všetky metódy. Nižšie sú uvedené najlepšie dosiahnuté výsledky vrátane kontroly splnenia obmedzení (ak sú všetky hodnoty g1-g4 záporné, ohraničenie je splnené s rezervou).

### A) Mŕtva pokuta (Death Penalty)
* **Nájdený výnos:** 659 570.15 EUR
* **Kontrola ohraničení:** **SPLNENÉ** (všetky g < 0)
* **Zhodnotenie:** Algoritmus úspešne našiel platné riešenie, avšak výnos je z troch funkčných metód najnižší. Je to spôsobené tým, že mŕtva pokuta neposkytuje gradient – akonáhle algoritmus "naslepo" trafil bezpečnú (platnú) zónu, bál sa posunúť bližšie k limitom (kde je vyšší zisk), pretože akákoľvek mutácia by ho zhodila do extrémnej fixnej pokuty.

### B) Stupňovitá pokuta (Step Penalty)
* **Nájdený výnos:** 705 777.82 EUR
* **Kontrola ohraničení:** **SPLNENÉ** (všetky g < 0)
* **Zhodnotenie:** Keďže sme fixný trest za porušenie nastavili dostatočne vysoko (aby nebolo výhodné podvádzať), algoritmus dokázal konvergovat a nájsť veľmi kvalitné platné riešenie. Schodovitý gradient mu pomohol lepšie sa navigovať smerom k prípustnej oblasti ako pri mŕtvej pokute.

### C) Úmerná pokuta (Proportional Penalty)
* **Nájdený výnos:** 687 803.81 EUR
* **Kontrola ohraničení:** **SPLNENÉ** (všetky g < 0, napr. rozpočet minutý takmer na doraz, rezerva len 55.48 EUR)
* **Zhodnotenie:** Úmerná pokuta štandardne poskytuje najhladší gradient pre navigáciu algoritmu, čo mu umožňuje "prilepiť sa" tesne na hranice limitov. *(Pozn.: To, že v tomto konkrétnom behu vyšiel zisk o niečo nižší ako pri stupňovitej pokute, je prirodzená vlastnosť stochastických algoritmov, ktoré využívajú náhodnosť).*

### D) Bez pokuty (Referenčný beh)
* **Nájdený výnos:** 3 300 000.00 EUR
* **Kontrola ohraničení:** **NESPLNENÉ / EXTRÉMNE PORUŠENÉ** (g1 = 40 000 000 EUR, g2 = 17 500 000 EUR)
* **Zhodnotenie:** Ako sa očakávalo, bez akýchkoľvek pokút algoritmus maximalizoval výnos tým, že vložil maximum (10 miliónov) do každej položky. Firemný rozpočet prekročil o 40 miliónov eur. Tento beh slúži ako dôkaz nevyhnutnosti penalizácie v optimalizačných úlohách.

---

## 5. Analýza vplyvu VEĽKOSTI pokuty (Citlivosť na parametre)
Aby sme pochopili citlivosť algoritmu na veľkosť pokuty, otestovali sme úmernú pokutu s rôznymi násobiteľmi:

* **Príliš malá pokuta (napr. 0.01x porušenia):** Algoritmus ohraničenia porušuje. Ak je výnos z nepovolenej investície (napr. 11% z dlhopisov) vyšší ako pokuta za nedodržanie limitu, algoritmus doslova "zarába na podvádzaní". Limity ignoruje a tvári sa, že dosiahol obrovský výnos.
* **Optimálna pokuta (napr. 2.0x porušenia):** Pokuta je dostatočne veľká na to, aby sa porušovanie neoplatilo, no zároveň dostatočne mierna na to, aby algoritmu poskytla plynulú navigáciu k hranici (napr. k 10 miliónom).
* **Príliš veľká pokuta (napr. 1000x porušenia):** Konvergencia je nestabilná. Algoritmus je z hranice "vydesený" (drobná mutácia vyvolá astronomickú pokutu). Odrazí sa od nej preč a uspokojí sa s bezpečným, avšak veľmi neefektívnym a nízkym výnosom hlboko pod limitom.

---

## 6. Finálna vizualizácia konvergencie

![Graf konvergencie metód pokutovania a veľkostí pokút](https://github.com/klemo-j/UMINT/raw/3b0314388ee8db09d44d94d5f9a97ea30275458b/CV4/lepsigrag.png)

**Záver k vizualizácii:**
Graf krásne demonštruje rozdiel v gradientoch. Mŕtva pokuta bez gradientu dlho tápe naslepo. Stupňovitá s hrubým gradientom sa chytí rýchlejšie. Úmerná pokuta má dokonalý hladký gradient a dominuje od prvej generácie. Krivka "bez pokuty" slúži ako dôkaz, že optimalizácia v ohraničenom priestore bez penalizácie vedie k nereálnym a nepoužiteľným výsledkom.
