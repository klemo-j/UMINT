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
      <td align="center"><strong>Ľahká CNN (CNN1)</strong></td>
      <td align="center">2</td>
      <td align="center">32, 64 | 128</td>
      <td align="center">30</td>
      <td align="center">0.001</td>
      <td align="center">128</td>
    </tr>
    <tr>
      <td align="center"><strong>Stredná CNN (CNN2)</strong></td>
      <td align="center">3</td>
      <td align="center">32, 32, 64 | 256</td>
      <td align="center">30</td>
      <td align="center">0.001</td>
      <td align="center">128</td>
    </tr>
    <tr>
      <td align="center"><strong>Hlboká CNN (CNN3)</strong></td>
      <td align="center">4</td>
      <td align="center">32, 32, 64, 64 | 512</td>
      <td align="center">30</td>
      <td align="center">0.001</td>
      <td align="center">128</td>
    </tr>
  </tbody>
</table>

<hr>

<h2>📈 2. Výsledky trénovania (GPU Akcelerácia)</h2>

<h3>2.1 Ľahká CNN (Architektúra 1)</h3>
<ul>
  <li><strong>Priemerná úspešnosť:</strong> 99.14 % | <strong>Priemerný bod pretrénovania:</strong> 96.4. iterácia</li>
</ul>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f9f9f9;">
    <tr>
      <th>Beh</th>
      <th>Train loss</th>
      <th>Test loss</th>
      <th>Train acc [%]</th>
      <th>Test acc [%]</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">1</td><td align="center">0.0509</td><td align="center">0.0353</td><td align="center">99.70</td><td align="center">99.15</td></tr>
    <tr><td align="center">2</td><td align="center">0.0226</td><td align="center">0.0370</td><td align="center">99.77</td><td align="center">99.16</td></tr>
    <tr><td align="center">3</td><td align="center">0.0541</td><td align="center">0.0363</td><td align="center">99.51</td><td align="center">99.04</td></tr>
    <tr><td align="center">4</td><td align="center">0.0301</td><td align="center">0.0344</td><td align="center">99.77</td><td align="center">99.15</td></tr>
    <tr><td align="center">5</td><td align="center">0.0228</td><td align="center">0.0373</td><td align="center">99.65</td><td align="center">99.20</td></tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka: Výsledky 5 spustení pre prvú architektúru CNN.</em></p>


<h3>2.2 Stredná CNN (Architektúra 2)</h3>
<ul>
  <li><strong>Priemerná úspešnosť:</strong> 99.18 % | <strong>Priemerný bod pretrénovania:</strong> 83.0. iterácia</li>
</ul>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f9f9f9;">
    <tr>
      <th>Beh</th>
      <th>Train loss</th>
      <th>Test loss</th>
      <th>Train acc [%]</th>
      <th>Test acc [%]</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">1</td><td align="center">0.0363</td><td align="center">0.0260</td><td align="center">99.62</td><td align="center">99.29</td></tr>
    <tr><td align="center">2</td><td align="center">0.0160</td><td align="center">0.0262</td><td align="center">99.72</td><td align="center">99.38</td></tr>
    <tr><td align="center">3</td><td align="center">0.0740</td><td align="center">0.0277</td><td align="center">99.64</td><td align="center">99.22</td></tr>
    <tr><td align="center">4</td><td align="center">0.0642</td><td align="center">0.0284</td><td align="center">99.50</td><td align="center">99.00</td></tr>
    <tr><td align="center">5</td><td align="center">0.0286</td><td align="center">0.0237</td><td align="center">99.67</td><td align="center">98.99</td></tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka: Výsledky 5 spustení pre druhú architektúru CNN.</em></p>


<h3>2.3 Hlboká CNN (Architektúra 3)</h3>
<ul>
  <li><strong>Priemerná úspešnosť:</strong> 99.27 % | <strong>Priemerný bod pretrénovania:</strong> 65.6. iterácia</li>
</ul>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f9f9f9;">
    <tr>
      <th>Beh</th>
      <th>Train loss</th>
      <th>Test loss</th>
      <th>Train acc [%]</th>
      <th>Test acc [%]</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">1</td><td align="center">0.0253</td><td align="center">0.0236</td><td align="center">99.62</td><td align="center">99.35</td></tr>
    <tr><td align="center">2</td><td align="center">0.0217</td><td align="center">0.0224</td><td align="center">99.30</td><td align="center">98.99</td></tr>
    <tr><td align="center">3</td><td align="center">0.0114</td><td align="center">0.0219</td><td align="center">99.55</td><td align="center">99.19</td></tr>
    <tr><td align="center">4</td><td align="center">0.0306</td><td align="center">0.0216</td><td align="center">99.80</td><td align="center">99.49</td></tr>
    <tr><td align="center">5</td><td align="center">0.0315</td><td align="center">0.0237</td><td align="center">99.67</td><td align="center">99.34</td></tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka: Výsledky 5 spustení pre tretiu architektúru CNN.</em></p>

<div align="center">
  <br>
  <img src="data/tazka_CNN_traning.png" alt="Trénovanie - Hlboká CNN" width="45%">
  <img src="data/tazka_CNN_confusion.png" alt="Matica - Hlboká CNN" width="35%">
  <p><em>Ukážka priebehu trénovania a konfúznej matice pre najúspešnejší model (Hlboká CNN).</em></p>
</div>

<hr>

<h2>📊 3. Súhrnné porovnanie architektúr (GPU)</h2>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Architektúra</th>
      <th>Min test acc [%]</th>
      <th>Max test acc [%]</th>
      <th>Priemer test acc [%]</th>
      <th>Priemer test loss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">Ľahká CNN (CNN1)</td>
      <td align="center">99.04</td>
      <td align="center">99.20</td>
      <td align="center">99.14</td>
      <td align="center">0.0361</td>
    </tr>
    <tr>
      <td align="center">Stredná CNN (CNN2)</td>
      <td align="center">98.99</td>
      <td align="center">99.38</td>
      <td align="center">99.18</td>
      <td align="center">0.0264</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6ffec;"><strong>Hlboká CNN (CNN3)</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>98.99</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>99.49</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>99.27</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>0.0226</strong></td>
    </tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka: Súhrnné porovnanie porovnávaných architektúr CNN.</em></p>

<hr>

<h2>💻 4. Analýza hardvérovej náročnosti (CPU vs GPU)</h2>
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
  <strong>Zistenie:</strong> Kým jeden trénovací beh na bežnom procesore trval v priemere okolo 17 až 22 minút, nasadenie grafickej karty skrátilo tento čas na necelé 2 minúty na jeden beh. Celkový čas sa tak znížil o viac ako 1 hodinu a 16 minút (9.4-násobné zrýchlenie), čo potvrdzuje absolútnu nevyhnutnosť GPU akcelerácie pri konvolučných operáciách.
</p>

<hr>

<h2>🖼️ 5. Ukážky úspešnej klasifikácie</h2>
<div align="center">
  <img src="data/tazka_CNN_obrazky.png" alt="Ukážka klasifikácie" width="80%">
  <p><em>Predikcia modelu Hlbokej CNN na náhodne vybraných vzorkách z testovacieho datasetu.</em></p>
</div>
