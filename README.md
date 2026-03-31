<h1 align="center">Zadanie 6 - Úvod do umelej inteligencie</h1>
<h3 align="center">Klasifikácia údajov pomocou neurónových sietí</h3>

<p>
  Tento projekt sa zaoberá návrhom, trénovaním a porovnaním troch rôznych architektúr neurónových sietí (M1, M2, M3) za účelom klasifikácie vstupných údajov z CTG vyšetrenia do troch tried: normálny, podozrivý a patologický.
</p>

<blockquote>
  <strong>Cieľ zadania:</strong> Dosiahnuť priemernú úspešnosť testovania (Test Accuracy) nad 92 % z 5 spustení.
</blockquote>

<hr>

<h2>⚙️ 1. Architektúra modelov a hyperparametre</h2>
<p>
  Pre experiment bolo navrhnutých 15 behov (5 pre každý model) s nasledujúcimi konfiguračnými parametrami. Learning Rate bol nastavený na automatický odhad ('Auto'). Všetky modely využívali rovnaké trénovacie funkcie a podmienky (max_fail = 20) pre zachovanie férovosti testovania.
</p>

<table border="1" cellpadding="5" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Model</th>
      <th>Skryté vrstvy</th>
      <th>Počet neurónov</th>
      <th>Epochy</th>
      <th>Learning Rate</th>
      <th>Batch Size</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><strong>M1</strong></td>
      <td align="center">1</td>
      <td align="center">30</td>
      <td align="center">500</td>
      <td align="center">Auto</td>
      <td align="center">Full</td>
    </tr>
    <tr>
      <td align="center"><strong>M2</strong></td>
      <td align="center">1</td>
      <td align="center">40</td>
      <td align="center">500</td>
      <td align="center">Auto</td>
      <td align="center">Full</td>
    </tr>
    <tr>
      <td align="center"><strong>M3</strong></td>
      <td align="center">2</td>
      <td align="center">30, 15</td>
      <td align="center">500</td>
      <td align="center">Auto</td>
      <td align="center">Full</td>
    </tr>
  </tbody>
</table>

<hr>

<h2>📊 2. Finálne porovnanie a dosiahnutie cieľa</h2>
<p>
  V nasledujúcej tabuľke je zhrnutie štatistických výsledkov pre jednotlivé modely z ich 5 trénovacích behov na nezávislých <strong>testovacích dátach</strong>.
</p>

<table border="1" cellpadding="5" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Model</th>
      <th>Min. Accuracy</th>
      <th>Max. Accuracy</th>
      <th>Priemerná Accuracy</th>
      <th>Priemerný Loss</th>
      <th>Cieľ (>92 %)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><strong>M1</strong></td>
      <td>90.59 %</td>
      <td>92.00 %</td>
      <td>91.53 %</td>
      <td>0.0405</td>
      <td align="center">❌</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6ffec;"><strong>M2 (Víťaz)</strong></td>
      <td style="background-color: #e6ffec;"><strong>91.06 %</strong></td>
      <td style="background-color: #e6ffec;"><strong>94.59 %</strong></td>
      <td style="background-color: #e6ffec;"><strong>92.52 % 🏆</strong></td>
      <td style="background-color: #e6ffec;"><strong>0.0392</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>✅</strong></td>
    </tr>
    <tr>
      <td align="center"><strong>M3</strong></td>
      <td>90.82 %</td>
      <td>93.65 %</td>
      <td>92.19 %</td>
      <td>0.0404</td>
      <td align="center">✅</td>
    </tr>
  </tbody>
</table>

<p>
  <strong>Záver pre Testovacie dáta:</strong> Modely <strong>M2</strong> aj <strong>M3</strong> v priemere úspešne prekonali stanovenú hranicu 92 %. Najlepšie výsledky dosiahol model <strong>M2</strong> (1 skrytá vrstva so 40 neurónmi), ktorý mal najvyššiu priemernú úspešnosť a najnižšiu chybovosť.
</p>

<p>
  <strong>Zhodnotenie Trénovacích dát:</strong> Priemerná úspešnosť na trénovacích dátach bola u všetkých modelov prirodzene vyššia (M1: ~96.9 %, M2: ~98.7 %, M3: ~98.8 %). Z výsledkov vyplýva, že model M2 predstavuje ideálny kompromis (sweet-spot), kedy mal dostatočnú kapacitu na pochopenie zložitejších vzťahov, no vďaka mechanizmu Early Stopping sa vyhol preučeniu (overfittingu), čo dokazuje jeho víťazstvo na testovacej sade.
</p>

<div align="center">
  <h3>Ukážka trénovania víťazného modelu M2</h3>
  <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV6/CV6/data/testovanie2.png" alt="Graf priebehu trénovania" width="80%">
  <p><em>Graf: Priebeh Loss a Accuracy počas trénovania najlepšieho modelu M2.</em></p>
</div>

<hr>

<h2>🏆 3. Detailná analýza najlepšej siete (M2)</h2>
<p>
  Pre absolútne najlepšiu nájdenú sieť z modelu M2 boli vypočítané metriky senzitivity a špecificity pre jednotlivé triedy.
</p>

<ul>
  <li><strong>Trieda 1:</strong> Senzitivita: 98.25 % | Špecificita: 92.99 %</li>
  <li><strong>Trieda 2:</strong> Senzitivita: 88.47 % | Špecificita: 97.82 %</li>
  <li><strong>Trieda 3:</strong> Senzitivita: 91.48 % | Špecificita: 99.74 %</li>
</ul>

<div align="center">
  <h3>Konfúzna matica (Confusion Matrix) modelu M2</h3>
  <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV6/CV6/data/matica2.png" alt="Konfúzna matica modelu M2" width="60%">
</div>

<hr>

<h2>🎯 4. Otestovanie na neznámych vzorkách</h2>
<p>
  Finálna sieť bola otestovaná na troch konkrétnych, pre sieť neznámych vzorkách z datasetu.
</p>

<ul>
  <li>Vzorka zo skutočnej triedy <strong>1</strong> bola sieťou zaradená do: <strong>1</strong> ✅ (Správne)</li>
  <li>Vzorka zo skutočnej triedy <strong>2</strong> bola sieťou zaradená do: <strong>2</strong> ✅ (Správne)</li>
  <li>Vzorka zo skutočnej triedy <strong>3</strong> bola sieťou zaradená do: <strong>2</strong> ❌ (Nesprávne klasifikované)</li>
</ul>

<p>
  <strong>Zhodnotenie chyby:</strong> Fakt, že sieť nesprávne klasifikovala patologickú vzorku (Trieda 3) ako podozrivú (Trieda 2), koreluje so zisteniami z konfúznej matice (a najnižšou senzitivitou pri Triede 2). Tieto dva stavy majú k sebe parametrovo najbližšie a ide o hraničné medicínske hodnoty, pri ktorých je separácia pre umelú sieť aj pre lekára najnáročnejšia. Sieť však s takmer 100 % istotou oddelila zdravé vzorky od oboch rizikových skupín.
</p>

<hr>


<h2>📈 5. Grafy trénovania pre modely M1 a M3</h2>
<p>V súlade s požiadavkami zadania prikladáme dokumentáciu procesu trénovania a kontingenčné matice aj pre najlepšie behy zvyšných dvoch štruktúr (M1 a M3).</p>

<details>
<summary><strong>👉 Klikni sem pre zobrazenie grafov pre modely M1 a M3</strong></summary>
<br>
<div align="center">
<h4>Najlepšia sieť z modelu M1 (30 neurónov)</h4>
<img src="https://raw.githubusercontent.com/klemo-j/UMINT/e829d5790a5f98dc8275af6fea71dcb80d90a15e/CV6/data/matica1.png" alt="Konfúzna matica M1" width="45%">
<img src="https://raw.githubusercontent.com/klemo-j/UMINT/e829d5790a5f98dc8275af6fea71dcb80d90a15e/CV6/data/trenovanie1.png" alt="Priebeh trénovania M1" width="45%">

<h4>Najlepšia sieť z modelu M3 (30, 15 neurónov)</h4>
<img src="https://raw.githubusercontent.com/klemo-j/UMINT/e829d5790a5f98dc8275af6fea71dcb80d90a15e/CV6/data/matica3.png" alt="Konfúzna matica M3" width="45%">
<img src="https://raw.githubusercontent.com/klemo-j/UMINT/e829d5790a5f98dc8275af6fea71dcb80d90a15e/CV6/data/testovanie3.png" alt="Priebeh trénovania M3" width="45%">
</div>
</details>

<hr>

<h2>📄 Príloha: Detailné výsledky pre všetkých 15 behov</h2>
<details>
  <summary><strong>👉 Klikni sem pre zobrazenie kompletnej tabuľky trénovacích behov</strong></summary>
  <br>
  <p>
    Tu sú uvedené surové dáta z výpočtov pre všetky trénovacie behy, na základe ktorých boli vypočítané finálne štatistiky.
  </p>
  
  <table border="1" cellpadding="5" cellspacing="0" align="center">
    <thead style="background-color: #f2f2f2;">
      <tr>
        <th>Model</th>
        <th>Beh</th>
        <th>Train Loss</th>
        <th>Test Loss</th>
        <th>Train Accuracy</th>
        <th>Test Accuracy</th>
      </tr>
    </thead>
    <tbody>
      <tr><td align="center">M1</td><td align="center">1</td><td align="right">0.0105</td><td align="right">0.0429</td><td align="right">98.82 %</td><td align="right">92.00 %</td></tr>
      <tr><td align="center">M1</td><td align="center">2</td><td align="right">0.0023</td><td align="right">0.0401</td><td align="right">99.84 %</td><td align="right">91.76 %</td></tr>
      <tr><td align="center">M1</td><td align="center">3</td><td align="right">0.0325</td><td align="right">0.0393</td><td align="right">94.20 %</td><td align="right">91.76 %</td></tr>
      <tr><td align="center">M1</td><td align="center">4</td><td align="right">0.0231</td><td align="right">0.0447</td><td align="right">95.53 %</td><td align="right">90.59 %</td></tr>
      <tr><td align="center">M1</td><td align="center">5</td><td align="right">0.0194</td><td align="right">0.0356</td><td align="right">96.39 %</td><td align="right">91.53 %</td></tr>
      <tr><td align="center">M2</td><td align="center">1</td><td align="right">0.0140</td><td align="right">0.0368</td><td align="right">97.65 %</td><td align="right">92.47 %</td></tr>
      <tr><td align="center">M2</td><td align="center">2</td><td align="right">0.0077</td><td align="right">0.0469</td><td align="right">99.22 %</td><td align="right">91.76 %</td></tr>
      <tr><td align="center">M2</td><td align="center">3</td><td align="right">0.0118</td><td align="right">0.0275</td><td align="right">98.67 %</td><td align="right">94.59 %</td></tr>
      <tr><td align="center">M2</td><td align="center">4</td><td align="right">0.0098</td><td align="right">0.0390</td><td align="right">98.82 %</td><td align="right">92.71 %</td></tr>
      <tr><td align="center">M2</td><td align="center">5</td><td align="right">0.0046</td><td align="right">0.0457</td><td align="right">99.45 %</td><td align="right">91.06 %</td></tr>
      <tr><td align="center">M3</td><td align="center">1</td><td align="right">0.0017</td><td align="right">0.0526</td><td align="right">99.76 %</td><td align="right">91.06 %</td></tr>
      <tr><td align="center">M3</td><td align="center">2</td><td align="right">0.0041</td><td align="right">0.0351</td><td align="right">99.84 %</td><td align="right">92.94 %</td></tr>
      <tr><td align="center">M3</td><td align="center">3</td><td align="right">0.0185</td><td align="right">0.0331</td><td align="right">96.47 %</td><td align="right">93.65 %</td></tr>
      <tr><td align="center">M3</td><td align="center">4</td><td align="right">0.0049</td><td align="right">0.0364</td><td align="right">99.37 %</td><td align="right">92.47 %</td></tr>
      <tr><td align="center">M3</td><td align="center">5</td><td align="right">0.0093</td><td align="right">0.0451</td><td align="right">98.82 %</td><td align="right">90.82 %</td></tr>
    </tbody>
  </table>
</details>
