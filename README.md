<h1 align="center">Zadanie 7 - Úvod do umelej inteligencie</h1>
<h3 align="center">Rozpoznávanie rukou písaných číslic (MNIST) pomocou MLP a CNN</h3>

<p align="center">
  <em>Porovnanie architektúr, vplyvu parametrov a hardvérovej akcelerácie na efektivitu trénovania.</em>
</p>

<hr>

<h2>🧠 1. Časť: Klasické plne prepojené siete (MLP)</h2>

<h3>1.1 Porovnávané štruktúry a hyperparametre (MLP)</h3>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Model</th>
      <th>Skryté vrstvy</th>
      <th>Neuróny</th>
      <th>Epochy</th>
      <th>Learning Rate</th>
      <th>Batch Size</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">MLP 1</td>
      <td align="center">1</td>
      <td align="center">128</td>
      <td align="center">100</td>
      <td align="center">Auto (SCG)</td>
      <td align="center">Full</td>
    </tr>
    <tr>
      <td align="center">MLP 2</td>
      <td align="center">2</td>
      <td align="center">256, 128</td>
      <td align="center">100</td>
      <td align="center">Auto (SCG)</td>
      <td align="center">Full</td>
    </tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka 1: Porovnávané štruktúry MLP a hlavné hyperparametre.</em></p>

<h3>1.2 Výsledky 5 spustení pre MLP 1 (128 neurónov)</h3>
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
    <tr><td align="center">1</td><td align="center">0.0034</td><td align="center">0.0126</td><td align="center">98.76</td><td align="center">96.59</td></tr>
    <tr><td align="center">2</td><td align="center">0.0039</td><td align="center">0.0113</td><td align="center">98.64</td><td align="center">97.08</td></tr>
    <tr><td align="center">3</td><td align="center">0.0030</td><td align="center">0.0101</td><td align="center">98.95</td><td align="center">96.99</td></tr>
    <tr><td align="center">4</td><td align="center">0.0042</td><td align="center">0.0106</td><td align="center">98.62</td><td align="center">96.88</td></tr>
    <tr><td align="center">5</td><td align="center">0.0041</td><td align="center">0.0115</td><td align="center">98.63</td><td align="center">97.00</td></tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka 2: Výsledky 5 spustení pre prvú štruktúru MLP.</em></p>

<h3>1.3 Výsledky 5 spustení pre MLP 2 (256 - 128 neurónov)</h3>
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
    <tr><td align="center">1</td><td align="center">0.0034</td><td align="center">0.0093</td><td align="center">98.80</td><td align="center">97.24</td></tr>
    <tr><td align="center">2</td><td align="center">0.0030</td><td align="center">0.0087</td><td align="center">98.91</td><td align="center">97.32</td></tr>
    <tr><td align="center">3</td><td align="center">0.0046</td><td align="center">0.0102</td><td align="center">98.40</td><td align="center">97.15</td></tr>
    <tr><td align="center">4</td><td align="center">0.0036</td><td align="center">0.0093</td><td align="center">98.77</td><td align="center">97.27</td></tr>
    <tr><td align="center">5</td><td align="center">0.0027</td><td align="center">0.0088</td><td align="center">98.99</td><td align="center">97.58</td></tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka 3: Výsledky 5 spustení pre druhú štruktúru MLP.</em></p>

<h3>1.4 Súhrnné porovnanie MLP</h3>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Model</th>
      <th>Min test acc [%]</th>
      <th>Max test acc [%]</th>
      <th>Priemer test acc [%]</th>
      <th>Priemer test loss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">MLP 1</td>
      <td align="center">96.59</td>
      <td align="center">97.08</td>
      <td align="center">96.91</td>
      <td align="center">0.0112</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6ffec;"><strong>MLP 2</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>97.15</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>97.58</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>97.31</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>0.0093</strong></td>
    </tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka 4: Súhrnné porovnanie porovnávaných štruktúr MLP.</em></p>

<p>
  <strong>Zhodnotenie MLP:</strong> Z výsledkov je zrejmé, že pridanie ďalšej skrytej vrstvy a navýšenie počtu neurónov (MLP 2) prinieslo mierne, ale stabilné zlepšenie presnosti z 96.91 % na 97.31 % a zároveň znížilo priemernú testovaciu chybu. Pre úlohy počítačového videnia však táto architektúra stále nie je ideálna, čo ukáže porovnanie so sieťami typu CNN.
</p>

<div align="center">
  <br>
  <img src="data/lahke_MLP_loss.png" alt="Priebeh učenia MLP" width="45%">
  <img src="data/lahke_MLP-confusion.png" alt="Matica zámen MLP" width="35%">
  <p><em>Priebeh učenia (Loss) a Matica zámen pre štruktúru MLP.</em></p>
</div>

<div align="center">
  <img src="data/MLP_Ukážky_klasifikácie.png" alt="Ukážka klasifikácie MLP" width="80%">
  <p><em>Predikcia modelu MLP na náhodne vybraných vzorkách z testovacieho datasetu.</em></p>
</div>

<hr>

<h2>👁️ 2. Časť: Konvolučné neurónové siete (CNN)</h2>

<h3>2.1 Porovnávané architektúry a hyperparametre (CNN)</h3>
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
<p align="center"><em>Tabuľka 5: Porovnávané architektúry CNN a hlavné hyperparametre.</em></p>

<h3>2.2 Výsledky trénovania (GPU Akcelerácia)</h3>

<h4>Ľahká CNN (Architektúra 1)</h4>
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
<p align="center"><em>Tabuľka 6: Výsledky 5 spustení pre prvú architektúru CNN.</em></p>

<h4>Stredná CNN (Architektúra 2)</h4>
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
<p align="center"><em>Tabuľka 7: Výsledky 5 spustení pre druhú architektúru CNN.</em></p>

<h4>Hlboká CNN (Architektúra 3)</h4>
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
<p align="center"><em>Tabuľka 8: Výsledky 5 spustení pre tretiu architektúru CNN.</em></p>

<h3>2.3 Súhrnné porovnanie architektúr CNN</h3>
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
<p align="center"><em>Tabuľka 9: Súhrnné porovnanie porovnávaných architektúr CNN.</em></p>

<div align="center">
  <br>
  <img src="data/tazka_CNN_traning.png" alt="Trénovanie - Hlboká CNN" width="45%">
  <img src="data/tazka_CNN_confusion.png" alt="Matica - Hlboká CNN" width="35%">
  <p><em>Ukážka priebehu trénovania a konfúznej matice pre najúspešnejší model (Hlboká CNN).</em></p>
</div>

<div align="center">
  <img src="data/tazka_CNN_obrazky.png" alt="Ukážka klasifikácie" width="80%">
  <p><em>Predikcia modelu Hlbokej CNN na náhodne vybraných vzorkách.</em></p>
</div>

<hr>

<h2>💻 3. Analýza hardvérovej náročnosti (CPU vs GPU)</h2>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Model</th>
      <th>CPU čas [s]</th>
      <th>GPU čas [s]</th>
      <th>Zrýchlenie</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">MLP 2</td>
      <td align="center">668.73</td>
      <td align="center">~ 110.0 (Odhad)</td>
      <td align="center">~ 6.0x</td>
    </tr>
    <tr>
      <td align="center">Ľahká CNN</td>
      <td align="center">5125.00</td>
      <td align="center">545.35</td>
      <td align="center">9.4x</td>
    </tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka 13: Súhrnné porovnanie času trénovania na CPU a GPU.</em></p>

<p>
  <strong>Zistenie:</strong> GPU akcelerácia je nevyhnutná najmä pri architektúrach CNN, kde masívne konvolučné operácie dokážu bežať paralelne. Trénovanie na GPU bolo v prípade CNN viac než 9-krát rýchlejšie, čo skrátilo celkový čas experimentu z hodín na minúty.
</p>

<hr>

<h2>🛠️ 4. Experiment: Vplyv parametra Dropout na pretrénovanie</h2>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Model</th>
      <th>Dropout</th>
      <th>Počet behov</th>
      <th>Priemer iterácie začiatku pretrénovania</th>
      <th>Priemer test loss</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">D1</td><td align="center">0.0</td><td align="center">5</td><td align="center" style="color: red;">62.6</td><td align="center">0.0381</td></tr>
    <tr><td align="center">D2</td><td align="center">0.3</td><td align="center">5</td><td align="center">98.0</td><td align="center">0.0297</td></tr>
    <tr><td align="center">D3</td><td align="center">0.5</td><td align="center">5</td><td align="center">96.4</td><td align="center">0.0361</td></tr>
    <tr><td align="center" style="background-color: #e6ffec;"><strong>D4</strong></td><td align="center" style="background-color: #e6ffec;"><strong>0.7</strong></td><td align="center" style="background-color: #e6ffec;"><strong>5</strong></td><td align="center" style="background-color: #e6ffec; color: green;"><strong>193.0</strong></td><td align="center" style="background-color: #e6ffec;"><strong>0.0230</strong></td></tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka 10: Porovnanie bodu pretrénovania pre rôzne nastavenia dropout-u.</em></p>

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Dropout</th>
      <th>Počet behov</th>
      <th>Priemer train acc [%]</th>
      <th>Priemer test acc [%]</th>
      <th>Priemer test loss</th>
    </tr>
  </thead>
  <tbody>
    <tr><td align="center">0.0</td><td align="center">5</td><td align="center">99.59</td><td align="center">98.86</td><td align="center">0.0381</td></tr>
    <tr><td align="center">0.3</td><td align="center">5</td><td align="center">99.78</td><td align="center">99.17</td><td align="center">0.0297</td></tr>
    <tr><td align="center">0.5</td><td align="center">5</td><td align="center">99.68</td><td align="center">99.14</td><td align="center">0.0361</td></tr>
    <tr><td align="center" style="background-color: #e6ffec;"><strong>0.7</strong></td><td align="center" style="background-color: #e6ffec;"><strong>5</strong></td><td align="center" style="background-color: #e6ffec;"><strong>99.74</strong></td><td align="center" style="background-color: #e6ffec;"><strong>99.26</strong></td><td align="center" style="background-color: #e6ffec;"><strong>0.0230</strong></td></tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka 11: Súhrnné porovnanie úspešnosti pre rôzne nastavenia dropout-u.</em></p>

<p>
  <strong>Zhodnotenie:</strong> Výsledky preukázali význam regularizácie. Zatiaľ čo pri nulovom dropoute dochádzalo k rýchlemu memorovaniu dát (pretrénovanie v 62. iterácii), nasadenie veľmi silného dropoutu (0.7) posunulo tento bod až na 193. iteráciu. Model tak nadobudol výbornú generalizačnú schopnosť.
</p>

<div align="center">
  <br>
  <img src="data/CNN_Drop_00.png" alt="Priebeh učenia - Dropout 0.0" width="45%">
  <p><em>Ukážka rýchleho pretrénovania pri absencii regularizácie (Dropout = 0.0).</em></p>
</div>

<hr>

<h2>🏆 5. Súhrnné porovnanie: MLP vs. CNN</h2>
<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #000; color: #fff;">
    <tr>
      <th>Prístup</th>
      <th>Počet modelov</th>
      <th>Priemer test acc [%]</th>
      <th>Priemer test loss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><strong>MLP</strong> (Najlepší: MLP 2)</td>
      <td align="center">2</td>
      <td align="center">97.31</td>
      <td align="center">0.0093</td>
    </tr>
    <tr>
      <td align="center"><strong>CNN</strong> (Najlepší: CNN 3)</td>
      <td align="center">3</td>
      <td align="center"><strong>99.27</strong></td>
      <td align="center">0.0226</td>
    </tr>
  </tbody>
</table>
<p align="center"><em>Tabuľka 12: Súhrnné porovnanie priemerných výsledkov MLP a CNN.</em></p>

<p>
  <strong>Záverečné zhodnotenie:</strong> Experiment preukázal fundamentálny rozdiel v prístupe k spracovaniu obrazu. Klasická plne prepojená sieť (MLP), ktorá vyžaduje sploštenie obrazu do 1D vektora (čím stráca priestorovú informáciu), narazila na svoj strop na úrovni ~97.3 %. Naopak, konvolučné neurónové siete (CNN), ktoré pomocou filtrov dokážu extrahovať priestorové črty ako rohy a krivky priamo z 2D obrazu, bez problémov presiahli cieľovú úspešnosť 99 %. V kombinácii so správnym hardvérom (GPU) a vhodnou regularizáciou (Dropout) predstavuje CNN optimálne riešenie pre úlohy klasifikácie obrazu.
</p>
