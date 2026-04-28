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
<p>AlexNet predstavuje staršiu, ale výpočtovo rýchlu architektúru. V režime Scratch dosahoval priemerné výsledky, no TL výrazne pomohol stabilizovať trénovanie a zvýšiť presnosť.</p>

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
      <td align="center" style="background-color: #e6f3ff;">80.9%</td>
      <td align="center" style="background-color: #e6f3ff;">75.2%</td>
      <td align="center" style="background-color: #e6f3ff;"><strong>80.5%</strong></td>
      <td align="center" style="background-color: #e6f3ff;">0.5920</td>
    </tr>
  </tbody>
</table>

<div align="center">
  <br>
  <img src="TU_VLOZ_HYPERLINK_NA_M1_AlexNet_scratch_vs_tl.png" width="48%" alt="AlexNet Scratch vs TL">
  <img src="TU_VLOZ_HYPERLINK_NA_M1_AlexNet_TL_najlepsi.png" width="48%" alt="AlexNet Najlepší Beh">
  <p><em>Obr 1: Porovnanie priebehu trénovania AlexNet (vľavo) a detail najlepšieho TL behu (vpravo).</em></p>
</div>

<hr>

<h2>🥗 3. Model M2: ResNet18</h2>
<p>ResNet18 využíva reziduálne prepojenia. Pri trénovaní od nuly mal model silnú tendenciu k pretrénovaniu (Train Acc 100%, ale Test Acc len 56%), čo potvrdzuje dôležitosť TL pre hlboké siete na menších datasetoch.</p>

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
      <td align="center">51.3%</td>
      <td align="center">56.7%</td>
      <td align="center">1.4241</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6f3ff;"><strong>Transfer Learning</strong></td>
      <td align="center" style="background-color: #e6f3ff;">76.1%</td>
      <td align="center" style="background-color: #e6f3ff;">75.0%</td>
      <td align="center" style="background-color: #e6f3ff;"><strong>80.1%</strong></td>
      <td align="center" style="background-color: #e6f3ff;">0.8655</td>
    </tr>
  </tbody>
</table>

<div align="center">
  <br>
  <img src="TU_VLOZ_HYPERLINK_NA_M2_ResNet18_scratch_vs_tl.png" width="48%" alt="ResNet18 Scratch vs TL">
  <img src="TU_VLOZ_HYPERLINK_NA_M2_ResNet18_TL_najlepsi.png" width="48%" alt="ResNet18 Najlepší Beh">
  <p><em>Obr 2: Porovnanie priebehu trénovania ResNet18. V režime Scratch je jasne vidieť masívne pretrénovanie.</em></p>
</div>

<hr>

<h2>🍣 4. Model M3: MobileNetV2 (Víťaz experimentu)</h2>
<p>MobileNetV2 sa ukázal ako najvhodnejšia architektúra pre túto úlohu. V režime TL dosiahol najvyššiu priemernú presnosť presahujúcu 85 %.</p>

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
      <td align="center">58.6%</td>
      <td align="center">38.3%</td>
      <td align="center">42.1%</td>
      <td align="center">1.6365</td>
    </tr>
    <tr>
      <td align="center" style="background-color: #e6ffec;"><strong>Transfer Learning</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>81.2%</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>81.7%</strong></td>
      <td align="center" style="background-color: #e6ffec;"><strong>85.4%</strong></td>
      <td align="center" style="background-color: #e6ffec;">0.6156</td>
    </tr>
  </tbody>
</table>

<div align="center">
  <br>
  <img src="TU_VLOZ_HYPERLINK_NA_M3_MobileNetV2_scratch_vs_tl.png" width="48%" alt="MobileNetV2 Scratch vs TL">
  <img src="TU_VLOZ_HYPERLINK_NA_M3_MobileNetV2_TL_najlepsi.png" width="48%" alt="MobileNetV2 Najlepší Beh">
  <p><em>Obr 3: MobileNetV2 preukázal najlepšiu schopnosť generalizácie pri použití Transfer Learningu.</em></p>
</div>

<hr>

<h2>🛠️ 5. Experiment: Vplyv Augmentácie (MobileNetV2 TL)</h2>
<p>Testovali sme vplyv základnej augmentácie (náhodné horizontálne preklopenie a rotácia) na najlepšom modeli. Prekvapivo, pri 40 epochách augmentácia mierne znížila finálnu presnosť, čo naznačuje, že model by potreboval viac epoch na spracovanie takto variabilných dát.</p>

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
      <td align="center">81.8%</td>
      <td align="center"><strong>85.4%</strong></td>
      <td align="center">0.6156</td>
    </tr>
    <tr>
      <td align="center">S augmentáciou</td>
      <td align="center">79.0%</td>
      <td align="center">82.7%</td>
      <td align="center">0.7007</td>
    </tr>
  </tbody>
</table>

<div align="center">
  <br>
  <img src="TU_VLOZ_HYPERLINK_NA_mobilenet_v2_aug_comparison.png" width="60%" alt="Porovnanie augmentácie">
  <p><em>Obr 4: Porovnanie výsledkov MobileNetV2 s a bez použitia augmentácie dát.</em></p>
</div>

<hr>

<h2>🏆 6. Celkové zhodnotenie</h2>
<p>
  Z experimentu vyplýva, že pre úlohy klasifikácie obrazu s obmedzeným počtom dát je <strong>Transfer Learning absolútne kľúčový</strong>. Zatiaľ čo modely trénované od nuly dosahovali Test Acc v rozmedzí 42 - 61 %, modely využívajúce predtrénované váhy z ImageNetu bez problémov prekročili hranicu 80 %.
</p>
<ul>
  <li><strong>Najlepší model:</strong> MobileNetV2 (TL) s úspešnosťou 85.4 %.</li>
  <li><strong>Zistenie o Scratch:</strong> Moderné hlboké architektúry (ResNet, MobileNet) bez predtrénovania na malých dátach masívne pretrénovávajú alebo konvergujú veľmi pomaly.</li>
  <li><strong>Zistenie o TL:</strong> Transfer Learning nielen zvyšuje presnosť, ale radikálne zrýchľuje proces učenia (vysoká presnosť už po 5. epoche).</li>
</ul>

<div align="center">
  <br>
  <img src="TU_VLOZ_HYPERLINK_NA_predikcie.jpg" width="80%" alt="Ukážky predikcií">
  <p><em>Obr 5: Ukážka klasifikácie jedál najlepším modelom na testovacom datasete.</em></p>
</div>
