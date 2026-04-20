<h1 align="center">Zadanie 7 - Úvod do umelej inteligencie</h1>
<h3 align="center">Rozpoznávanie rukou písaných číslic (MNIST) pomocou CNN</h3>

<p align="center">
  <em>Analýza vplyvu architektúry a hardvérovej akcelerácie na efektivitu trénovania.</em>
</p>

<hr>

<h2>🏗️ 1. Konfigurácia experimentov</h2>
<p>
  Pre zabezpečenie férového porovnania boli všetky modely trénované pomocou celého datasetu (Full batch) s Early Stoppingom. Testovanie prebiehalo na dvoch rôznych hardvérových konfiguráciách (CPU vs GPU).
</p>

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Model</th>
      <th>Konvolučné vrstvy</th>
      <th>Filtre / Neuróny v FC</th>
      <th>Epochy</th>
      <th>Learning Rate</th>
      <th>Batch Size</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><strong>Ľahká CNN</strong></td>
      <td align="center">2</td>
      <td align="center">32, 64 | 128</td>
      <td align="center">500</td>
      <td align="center">Auto</td>
      <td align="center">Full</td>
    </tr>
    <tr>
      <td align="center"><strong>Stredná CNN</strong></td>
      <td align="center">3</td>
      <td align="center">32, 32, 64 | 256</td>
      <td align="center">500</td>
      <td align="center">Auto</td>
      <td align="center">Full</td>
    </tr>
    <tr>
      <td align="center"><strong>Hlboká CNN</strong></td>
      <td align="center">4</td>
      <td align="center">32, 32, 64, 64 | 512</td>
      <td align="center">500</td>
      <td align="center">Auto</td>
      <td align="center">Full</td>
    </tr>
  </tbody>
</table>

<hr>

<h2>📈 2. Výsledky trénovania (GPU Akcelerácia)</h2>

<h3>2.1 Ľahká CNN</h3>
<ul>
  <li><strong>Priemerná úspešnosť:</strong> 99.14 % | <strong>Priemerný bod pretrénovania:</strong> 96.4. iterácia</li>
</ul>

<h3>2.2 Stredná CNN</h3>
<ul>
  <li><strong>Priemerná úspešnosť:</strong> 99.18 % | <strong>Priemerný bod pretrénovania:</strong> 83.0. iterácia</li>
</ul>

<h3>2.3 Hlboká CNN</h3>
<ul>
  <li><strong>Priemerná úspešnosť:</strong> 99.27 % | <strong>Priemerný bod pretrénovania:</strong> 65.6. iterácia</li>
</ul>

<div align="center">
  <br>
  <img src="data/tazka_CNN_traning.png" alt="Trénovanie - Hlboká CNN" width="45%">
  <img src="data/tazka_CNN_confusion.png" alt="Matica - Hlboká CNN" width="35%">
  <p><em>Ukážka priebehu trénovania a konfúznej matice pre najúspešnejší model (Hlboká CNN).</em></p>
</div>

<hr>

<h2>💻 3. Analýza hardvérovej náročnosti (CPU vs GPU)</h2>
<p>
  Dôležitou súčasťou experimentu bolo porovnanie efektivity výpočtov. Trénovanie <strong>Ľahkej CNN</strong> bolo testované ako na procesore (CPU), tak aj s využitím grafickej akcelerácie (GPU).
</p>

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Hardvér</th>
      <th>Model</th>
      <th>Celkový čas (5 behov)</th>
      <th>Priemerný čas / 1 beh</th>
      <th>Relatívne zrýchlenie</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><strong>GPU</strong> (Akcelerované)</td>
      <td align="center">Ľahká CNN</td>
      <td align="center">545.35 s</td>
      <td align="center">~ 1.8 min (109 s)</td>
      <td align="center" style="background-color: #e6ffec;"><strong>9.4x rýchlejšie</strong></td>
    </tr>
    <tr>
      <td align="center"><strong>CPU</strong> (Standard)</td>
      <td align="center">Ľahká CNN</td>
      <td align="center">5125.00 s</td>
      <td align="center">~ 17-22 min (1025 s)</td>
      <td align="center">1.0x (Základ)</td>
    </tr>
  </tbody>
</table>

<p>
  <strong>Zistenie:</strong> Kým jeden trénovací beh na bežnom procesore trval v priemere okolo 17 až 22 minút (celkovo ~1,5 hodiny pre 5 behov), nasadenie grafickej karty skrátilo tento čas na necelé 2 minúty na jeden beh. Celkový čas sa tak znížil o viac ako 1 hodinu a 16 minút (9.4-násobné zrýchlenie), čo potvrdzuje absolútnu nevyhnutnosť GPU akcelerácie pri konvolučných operáciách.
</p>

<hr>

<h2>📊 4. Celkové porovnanie architektúr (GPU)</h2>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Architektúra</th>
      <th>Priemer Acc [%]</th>
      <th>Priemer Loss</th>
      <th>Bod pretrénovania</th>
      <th>Čas GPU [s]</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">Ľahká CNN</td><td align="center">99.14</td><td align="center">0.0361</td><td align="center">96.4</td><td align="center">545.35</td></tr>
    <tr><td align="center">Stredná CNN</td><td align="center">99.18</td><td align="center">0.0264</td><td align="center">83.0</td><td align="center">589.64</td></tr>
    <tr><td align="center" style="background-color: #e6ffec;"><strong>Hlboká CNN</strong></td><td align="center"><strong>99.27</strong></td><td align="center"><strong>0.0226</strong></td><td align="center"><strong>65.6</strong></td><td align="center">578.80</td></tr>
  </tbody>
</table>

<hr>

<h2>🖼️ 5. Ukážky úspešnej klasifikácie</h2>
<div align="center">
  <img src="data/tazka_CNN_obrazky.png" alt="Ukážka klasifikácie" width="80%">
  <p><em>Predikcia modelu Hlbokej CNN na náhodne vybraných vzorkách z testovacieho datasetu.</em></p>
</div>
