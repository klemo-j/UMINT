<h1 align="center">Zadanie 8 - Úvod do umelej inteligencie</h1>
<h3 align="center">Porovnanie trénovania CNN od nuly (Scratch) a Transfer Learningu (TL)</h3>

<p align="center">
  <em>Klasifikácia 10 druhov jedál z datasetu Food-101 pomocou architektúr AlexNet, ResNet18 a MobileNetV2.</em>
</p>

<hr>

<h2>📊 1. Prehľad experimentu a hyperparametre</h2>
<p>
  Cieľom úlohy bolo porovnať efektivitu trénovania hlbokých konvolučných sietí v dvoch režimoch: trénovanie s náhodne inicializovanými váhami (Scratch) a využitie predtrénovaných modelov na datasete ImageNet (Transfer Learning). Experiment prebiehal na výseku datasetu Food-101 (7 500 obrázkov, 10 tried).
</p>

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Model</th>
      <th>Architektúra</th>
      <th>Epochy</th>
      <th>Learning Rate</th>
      <th>Batch Size</th>
      <th>Dataset Split (T/V/T)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><strong>M1</strong></td>
      <td align="center">AlexNet</td>
      <td align="center">40</td>
      <td align="center">0.0001</td>
      <td align="center">64</td>
      <td align="center">6750 / 750 / 2500</td>
    </tr>
    <tr>
      <td align="center"><strong>M2</strong></td>
      <td align="center">ResNet18</td>
      <td align="center">40</td>
      <td align="center">0.0001</td>
      <td align="center">64</td>
      <td align="center">6750 / 750 / 2500</td>
    </tr>
    <tr>
      <td align="center"><strong>M3</strong></td>
      <td align="center">MobileNetV2</td>
      <td align="center">40</td>
      <td align="center">0.0001</td>
      <td align="center">64</td>
      <td align="center">6750 / 750 / 2500</td>
    </tr>
  </tbody>
</table>

<hr>

<h2>🍎 2. Model M1: AlexNet</h2>
<p>AlexNet vykazoval najväčší rozdiel v stabilite. Zatiaľ čo pri trénovaní od nuly bola úspešnosť len okolo 60 %, Transfer Learning posunul model na hranicu 87 %.</p>

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f9f9f9;">
    <tr>
      <th>Režim</th>
      <th>Priemer Train Acc [%]</th>
      <th>Priemer Val Acc [%]</th>
      <th>Priemer Test Acc [%]</th>
      <th>Priemer Test Loss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">Scratch</td>
      <td align="center">68.0%</td>
      <td align="center">55.5%</td>
      <td align="center">60.9%</td>
      <td align="center">1.1424</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6f3ff;"><strong>Transfer Learning</strong></td>
      <td align="center" style="background-color: #e6f3ff;">99.9%</td>
      <td align="center" style="background-color: #e6f3ff;">81.2%</td>
      <td align="center" style="background-color: #e6f3ff;"><strong>87.2%</strong></td>
      <td align="center" style="background-color: #e6f3ff;">0.5876</td>
    </tr>
  </tbody>
</table>

<div align="center">
  <br>
  <img src="https://github.com/klemo-j/UMINT/blob/CV8/M1_AlexNet_scratch_vs_tl.png?raw=true" width="48%" alt="AlexNet Scratch vs TL">
  <img src="https://github.com/klemo-j/UMINT/blob/CV8/M1_AlexNet_TL_najlepsi.png?raw=true" width="48%" alt="AlexNet Najlepší Beh">
  <p><em>Obr 1: Porovnanie AlexNet – TL verzia dosahuje takmer 100 % tréningovú presnosť.</em></p>
</div>

<hr>

<h2>🥗 3. Model M2: ResNet18</h2>
<p>ResNet18 v režime TL prekonal stanovenú hranicu 90 %. Pri trénovaní od nuly (Scratch) je opäť viditeľné masívne pretrénovanie (Overfitting), kde model dosahuje 100 % na tréningových dátach, ale na testovacích len 57 %.</p>

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f9f9f9;">
    <tr>
      <th>Režim</th>
      <th>Priemer Train Acc [%]</th>
      <th>Priemer Val Acc [%]</th>
      <th>Priemer Test Acc [%]</th>
      <th>Priemer Test Loss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">Scratch</td>
      <td align="center">100.0%</td>
      <td align="center">51.5%</td>
      <td align="center">57.1%</td>
      <td align="center">1.4147</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6f3ff;"><strong>Transfer Learning</strong></td>
      <td align="center" style="background-color: #e6f3ff;">100.0%</td>
      <td align="center" style="background-color: #e6f3ff;">88.0%</td>
      <td align="center" style="background-color: #e6f3ff;"><strong>92.7%</strong></td>
      <td align="center" style="background-color: #e6f3ff;">0.2329</td>
    </tr>
  </tbody>
</table>

<div align="center">
  <br>
  <img src="https://github.com/klemo-j/UMINT/blob/CV8/M2_ResNet18_scratch_vs_tl.png?raw=true" width="48%" alt="ResNet18 Scratch vs TL">
  <img src="https://github.com/klemo-j/UMINT/blob/CV8/M2_ResNet18_TL_najlepsi.png?raw=true" width="48%" alt="ResNet18 Najlepší Beh">
  <p><em>Obr 2: Priebeh ResNet18 – TL stabilizoval validáciu a výrazne znížil Test Loss.</em></p>
</div>

<hr>

<h2>🍣 4. Model M3: MobileNetV2 (Víťaz experimentu)</h2>
<p>MobileNetV2 je vďaka Transfer Learningu najúspešnejším modelom, pričom priemerná presnosť na testovacom datasete dosiahla <strong>93.9 %</strong>, čím splnil podmienku zadania.</p>

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f9f9f9;">
    <tr>
      <th>Režim</th>
      <th>Priemer Train Acc [%]</th>
      <th>Priemer Val Acc [%]</th>
      <th>Priemer Test Acc [%]</th>
      <th>Priemer Test Loss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">Scratch</td>
      <td align="center">58.0%</td>
      <td align="center">37.7%</td>
      <td align="center">42.2%</td>
      <td align="center">1.6305</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6ffec;"><strong>Transfer Learning</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>100.0%</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>89.1%</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>93.9%</strong></td>
      <td align="center" style="background-color: #e6ffec;">0.2158</td>
    </tr>
  </tbody>
</table>

<div align="center">
  <br>
  <img src="https://github.com/klemo-j/UMINT/blob/CV8/M3_MobileNetV2_scratch_vs_tl.png?raw=true" width="48%" alt="MobileNetV2 Scratch vs TL">
  <img src="https://github.com/klemo-j/UMINT/blob/CV8/M3_MobileNetV2_TL_najlepsi.png?raw=true" width="48%" alt="MobileNetV2 Najlepší Beh">
  <p><em>Obr 3: MobileNetV2 preukázal najlepšiu generalizáciu a najnižšiu chybovosť.</em></p>
</div>

<hr>

<h2>🛠️ 5. Experiment: Vplyv Augmentácie (MobileNetV2 TL)</h2>
<p>V tomto experimente augmentácia (rotácia a horizontálne preklopenie) pozitívne ovplyvnila výsledky. Znížila Test Loss z 0.2158 na 0.1915 a zvýšila presnosť na rekordných <strong>94.6 %</strong>.</p>

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th>Varianta</th>
      <th>Priemer Val Acc [%]</th>
      <th>Priemer Test Acc [%]</th>
      <th>Priemer Test Loss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">Bez augmentácie</td>
      <td align="center">89.1%</td>
      <td align="center">93.9%</td>
      <td align="center">0.2158</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6ffec;"><strong>S augmentáciou</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>89.2%</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>94.6%</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>0.1915</strong></td>
    </tr>
  </tbody>
</table>

<div align="center">
  <br>
  <img src="https://github.com/klemo-j/UMINT/blob/CV8/mobilenet_v2_aug_comparison.png?raw=true" width="60%" alt="Porovnanie augmentácie">
  <p><em>Obr 4: Vplyv augmentácie na stabilitu chybovej funkcie validácie a finálnu presnosť.</em></p>
</div>

<hr>

<h2>🏆 6. Celkové zhodnotenie</h2>
<ul>
  <li><strong>Transfer Learning:</strong> Je pre tento typ úlohy nevyhnutný. Modely Scratch končia na hranici 42-61 %, zatiaľ čo TL modely presahujú 93 %.</li>
  <li><strong>Overfitting:</strong> ResNet18 a AlexNet vykazujú silné pretrénovanie v Scratch režime (100 % tréning vs. nízka testovacia presnosť).</li>
  <li><strong>Augmentácia:</strong> Pomohla zvýšiť generalizačnú schopnosť MobileNetV2 a dosiahnuť najlepší výsledok celého zadania (94.6 %).</li>
</ul>

<div align="center">
  <br>
  <img src="https://github.com/klemo-j/UMINT/blob/CV8/predikcie.png?raw=true" width="80%" alt="Ukážky predikcií">
  <p><em>Obr 5: Správne predikcie najlepšieho modelu (MobileNetV2 TL + Aug) na náhodných vzorkách.</em></p>
</div>
