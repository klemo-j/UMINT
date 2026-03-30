<h1 align="center">Analýza a porovnanie modelov neurónových sietí (2. Experiment)</h1>

<p>
  Tento repozitár obsahuje výsledky z upraveného trénovania a testovania troch architektúr neurónových sietí (M1, M2, M3). 
  <strong>Hlavným cieľom</strong> bolo dosiahnuť priemernú úspešnosť (Accuracy) nad 92 %.
</p>

<hr>

<h2>⚙️ Architektúra modelov a hyperparametre</h2>
<table border="1">
  <thead>
    <tr>
      <th>Model</th>
      <th>Skryté vrstvy</th>
      <th>Počet neurónov</th>
      <th>Epochy</th>
      <th>Learning Rate (LR)</th>
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

<h2>📊 Finálne porovnanie modelov</h2>
<p><em>Cieľ: Dosiahnuť úspešnosť nad 92 %</em></p>
<table border="1">
  <thead>
    <tr>
      <th>Model</th>
      <th>Min. Accuracy</th>
      <th>Max. Accuracy</th>
      <th>Priemerná Accuracy</th>
      <th>Priemerný Loss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><strong>M1</strong></td>
      <td>90.59 %</td>
      <td>92.00 %</td>
      <td>91.53 %</td>
      <td>0.0405</td>
    </tr>
    <tr>
      <td align="center"><strong>M2</strong></td>
      <td><strong>91.06 %</strong></td>
      <td><strong>94.59 %</strong></td>
      <td><strong>92.52 % 🏆</strong></td>
      <td><strong>0.0392</strong></td>
    </tr>
    <tr>
      <td align="center"><strong>M3</strong></td>
      <td>90.82 %</td>
      <td>93.65 %</td>
      <td>92.19 % ✅</td>
      <td>0.0404</td>
    </tr>
  </tbody>
</table>
<p>
  <em>Záver: Modely <strong>M2</strong> aj <strong>M3</strong> v priemere prekonali hranicu 92 %. Absolútnym víťazom sa však stala sieť <strong>M2</strong> (1 skrytá vrstva, 40 neurónov), ktorá dosiahla najvyššiu priemernú úspešnosť a najnižší Loss.</em>
</p>

<hr>

<h2>🔍 Analýza najlepšej siete (M2)</h2>
<p>Detailné metriky senzitivity a špecificity pre jednotlivé triedy pri použití najlepšej nájdenej siete:</p>
<ul>
  <li><strong>Trieda 1:</strong> Senzitivita: 98.25 % | Špecificita: 92.99 %</li>
  <li><strong>Trieda 2:</strong> Senzitivita: 88.47 % | Špecificita: 97.82 %</li>
  <li><strong>Trieda 3:</strong> Senzitivita: 91.48 % | Špecificita: 99.74 %</li>
</ul>

<h3>🎯 Otestovanie konkrétnych vzoriek</h3>
<ul>
  <li>Vzorka zo skutočnej triedy <strong>1</strong> bola sieťou zaradená do: <strong>1</strong> ✅</li>
  <li>Vzorka zo skutočnej triedy <strong>2</strong> bola sieťou zaradená do: <strong>2</strong> ✅</li>
  <li>Vzorka zo skutočnej triedy <strong>3</strong> bola sieťou zaradená do: <strong>2</strong> ❌ <em>(Misklasifikácia)</em></li>
</ul>

<hr>

<h2>📈 Detailné výsledky pre všetkých 15 behov</h2>
<details>
  <summary><strong>👉 Klikni sem pre zobrazenie kompletnej tabuľky trénovacích behov</strong></summary>
  <br>
  <table border="1">
    <thead>
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
      <tr><td align="center">M1</td><td align="center">1</td><td>0.0105</td><td>0.0429</td><td>98.82 %</td><td>92.00 %</td></tr>
      <tr><td align="center">M1</td><td align="center">2</td><td>0.0023</td><td>0.0401</td><td>99.84 %</td><td>91.76 %</td></tr>
      <tr><td align="center">M1</td><td align="center">3</td><td>0.0325</td><td>0.0393</td><td>94.20 %</td><td>91.76 %</td></tr>
      <tr><td align="center">M1</td><td align="center">4</td><td>0.0231</td><td>0.0447</td><td>95.53 %</td><td>90.59 %</td></tr>
      <tr><td align="center">M1</td><td align="center">5</td><td>0.0194</td><td>0.0356</td><td>96.39 %</td><td>91.53 %</td></tr>
      <tr><td align="center">M2</td><td align="center">1</td><td>0.0140</td><td>0.0368</td><td>97.65 %</td><td>92.47 %</td></tr>
      <tr><td align="center">M2</td><td align="center">2</td><td>0.0077</td><td>0.0469</td><td>99.22 %</td><td>91.76 %</td></tr>
      <tr><td align="center">M2</td><td align="center">3</td><td>0.0118</td><td>0.0275</td><td>98.67 %</td><td>94.59 %</td></tr>
      <tr><td align="center">M2</td><td align="center">4</td><td>0.0098</td><td>0.0390</td><td>98.82 %</td><td>92.71 %</td></tr>
      <tr><td align="center">M2</td><td align="center">5</td><td>0.0046</td><td>0.0457</td><td>99.45 %</td><td>91.06 %</td></tr>
      <tr><td align="center">M3</td><td align="center">1</td><td>0.0017</td><td>0.0526</td><td>99.76 %</td><td>91.06 %</td></tr>
      <tr><td align="center">M3</td><td align="center">2</td><td>0.0041</td><td>0.0351</td><td>99.84 %</td><td>92.94 %</td></tr>
      <tr><td align="center">M3</td><td align="center">3</td><td>0.0185</td><td>0.0331</td><td>96.47 %</td><td>93.65 %</td></tr>
      <tr><td align="center">M3</td><td align="center">4</td><td>0.0049</td><td>0.0364</td><td>99.37 %</td><td>92.47 %</td></tr>
      <tr><td align="center">M3</td><td align="center">5</td><td>0.0093</td><td>0.0451</td><td>98.82 %</td><td>90.82 %</td></tr>
    </tbody>
  </table>
</details>
