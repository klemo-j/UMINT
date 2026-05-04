<!DOCTYPE html>
<html lang="sk">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>UMINT – Zadanie 9: Fuzzy riadenie križovatky</title>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Source+Serif+4:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">
<style>
  :root {
    --bg: #0f1117;
    --surface: #1a1d27;
    --surface2: #232733;
    --border: #2e3345;
    --text: #e2e4ed;
    --text-dim: #8b90a5;
    --accent: #6c9cff;
    --green: #4ade80;
    --red: #f87171;
    --yellow: #fbbf24;
    --orange: #fb923c;
  }

  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    font-family: 'Source Serif 4', Georgia, serif;
    background: var(--bg);
    color: var(--text);
    line-height: 1.7;
    padding: 0;
  }

  .hero {
    background: linear-gradient(135deg, #141825 0%, #1e2336 50%, #192030 100%);
    border-bottom: 1px solid var(--border);
    padding: 4rem 2rem 3rem;
    text-align: center;
  }

  .hero-badge {
    display: inline-block;
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.75rem;
    letter-spacing: 0.15em;
    text-transform: uppercase;
    color: var(--accent);
    border: 1px solid var(--accent);
    border-radius: 100px;
    padding: 0.3rem 1rem;
    margin-bottom: 1.5rem;
  }

  .hero h1 {
    font-size: 2.6rem;
    font-weight: 700;
    letter-spacing: -0.02em;
    margin-bottom: 0.5rem;
  }

  .hero h1 span { color: var(--accent); }

  .hero p {
    color: var(--text-dim);
    font-size: 1.1rem;
    max-width: 600px;
    margin: 0 auto;
  }

  .container {
    max-width: 960px;
    margin: 0 auto;
    padding: 2rem 1.5rem;
  }

  section { margin-bottom: 3.5rem; }

  h2 {
    font-size: 1.6rem;
    font-weight: 700;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 2px solid var(--border);
    letter-spacing: -0.01em;
  }

  h3 {
    font-size: 1.15rem;
    font-weight: 700;
    margin: 1.5rem 0 0.5rem;
    color: var(--accent);
  }

  p { margin-bottom: 1rem; }

  .crossroad-img {
    display: block;
    max-width: 500px;
    margin: 1.5rem auto;
    border-radius: 8px;
    border: 1px solid var(--border);
  }

  /* Tables */
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 1.2rem 0;
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.85rem;
  }

  thead th {
    background: var(--surface2);
    color: var(--accent);
    text-align: left;
    padding: 0.7rem 1rem;
    border-bottom: 2px solid var(--accent);
    font-weight: 700;
    letter-spacing: 0.03em;
  }

  tbody td {
    padding: 0.6rem 1rem;
    border-bottom: 1px solid var(--border);
  }

  tbody tr:hover { background: var(--surface); }

  .better { color: var(--green); font-weight: 700; }
  .worse { color: var(--red); }
  .check { color: var(--green); }
  .fail { color: var(--red); }

  /* Config cards */
  .config-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    margin: 1.5rem 0;
  }

  .config-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 1.2rem;
    text-align: center;
  }

  .config-card .label {
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.75rem;
    color: var(--text-dim);
    text-transform: uppercase;
    letter-spacing: 0.1em;
    margin-bottom: 0.3rem;
  }

  .config-card .lanes {
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.95rem;
    color: var(--text);
    font-weight: 700;
  }

  .config-card .lanes .on { color: var(--green); }
  .config-card .lanes .off { color: #555; }

  /* Fuzzy rules box */
  .fuzzy-box {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 1.5rem;
    margin: 1.5rem 0;
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.82rem;
    line-height: 2;
    overflow-x: auto;
  }

  .fuzzy-box .rule-header {
    color: var(--accent);
    font-weight: 700;
    margin-bottom: 0.5rem;
    font-size: 0.9rem;
  }

  .fuzzy-box .rule { color: var(--text-dim); }
  .fuzzy-box .rule em { color: var(--yellow); font-style: normal; }
  .fuzzy-box .rule strong { color: var(--text); font-weight: 400; }

  /* Result graphs */
  .graph-section { margin: 2rem 0; }

  .graph-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
    margin: 1rem 0;
  }

  .graph-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    overflow: hidden;
  }

  .graph-card img {
    width: 100%;
    display: block;
  }

  .graph-card .caption {
    padding: 0.7rem 1rem;
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.78rem;
    color: var(--text-dim);
    border-top: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
  }

  .graph-card .caption .stat { color: var(--text); font-weight: 700; }

  /* MF description */
  .mf-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 1rem;
    margin: 1rem 0;
  }

  .mf-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 1rem;
  }

  .mf-card .mf-title {
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.8rem;
    color: var(--accent);
    font-weight: 700;
    margin-bottom: 0.5rem;
  }

  .mf-card .mf-item {
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.78rem;
    color: var(--text-dim);
    margin-bottom: 0.2rem;
  }

  .mf-card .mf-item span { color: var(--text); }

  /* Limits check */
  .limits-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 0.8rem;
    margin: 1rem 0;
  }

  .limit-card {
    background: var(--surface);
    border: 1px solid var(--green);
    border-radius: 8px;
    padding: 1rem;
    text-align: center;
  }

  .limit-card .limit-label {
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.7rem;
    color: var(--text-dim);
    text-transform: uppercase;
    letter-spacing: 0.08em;
  }

  .limit-card .limit-value {
    font-family: 'JetBrains Mono', monospace;
    font-size: 1.6rem;
    font-weight: 700;
    color: var(--green);
    margin: 0.3rem 0;
  }

  .limit-card .limit-max {
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.72rem;
    color: var(--text-dim);
  }

  code {
    font-family: 'JetBrains Mono', monospace;
    background: var(--surface2);
    padding: 0.15rem 0.4rem;
    border-radius: 4px;
    font-size: 0.85em;
  }

  .footer {
    text-align: center;
    padding: 2rem;
    color: var(--text-dim);
    font-size: 0.85rem;
    border-top: 1px solid var(--border);
  }

  @media (max-width: 700px) {
    .config-grid, .mf-grid { grid-template-columns: 1fr; }
    .graph-row { grid-template-columns: 1fr; }
    .limits-grid { grid-template-columns: repeat(2, 1fr); }
    .hero h1 { font-size: 1.8rem; }
  }
</style>
</head>
<body>

<div class="hero">
  <div class="hero-badge">UMINT 2026 — Zadanie č. 9</div>
  <h1>Fuzzy riadenie <span>križovatky</span></h1>
  <p>Porovnanie pevného a fuzzy riadenia semaforov na križovatke FEI–ZOO so 7 jazdnými pruhmi</p>
</div>

<div class="container">

<!-- ===== 1. OPIS ULOHY ===== -->
<section>
  <h2>1. Opis úlohy</h2>
  <p>
    Cieľom úlohy je navrhnúť riadenie križovatky pomocou fuzzy logiky a porovnať ho s pevným
    riadením pomocou fixných časových intervalov. Križovatka má <strong>7 vstupných jazdných pruhov</strong>
    rozdelených do troch smerov: A (pruhy A1, A2, A3), B (B1, B2) a C (C1, C2).
  </p>

  <img class="crossroad-img"
       src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/crossroad.jpg"
       alt="Vizualizácia križovatky">

  <h3>Konfigurácie semaforov</h3>
  <p>Riadenie sa realizuje cyklickým prepínaním troch konfigurácií:</p>

  <div class="config-grid">
    <div class="config-card">
      <div class="label">Konfigurácia 1</div>
      <div class="lanes">
        <span class="on">A1 A2 A3</span> <span class="off">B1 B2 C1 C2</span>
      </div>
    </div>
    <div class="config-card">
      <div class="label">Konfigurácia 2</div>
      <div class="lanes">
        <span class="off">A1 A2 A3</span> <span class="on">B1 B2</span> <span class="off">C1</span> <span class="on">C2</span>
      </div>
    </div>
    <div class="config-card">
      <div class="label">Konfigurácia 3</div>
      <div class="lanes">
        <span class="off">A1 A2 A3 B1</span> <span class="on">B2 C1 C2</span>
      </div>
    </div>
  </div>

  <h3>Režimy testovania</h3>
  <table>
    <thead><tr><th>Režim</th><th>Popis</th><th>Kroky</th></tr></thead>
    <tbody>
      <tr><td>3</td><td>Dopravná špička zo smeru C</td><td>150</td></tr>
      <tr><td>4</td><td>Dopravná špička zo smeru B</td><td>150</td></tr>
      <tr><td>5</td><td>Dopravná špička zo smeru A</td><td>150</td></tr>
      <tr><td>6</td><td>Kombinovaná dopravná špička</td><td>500</td></tr>
    </tbody>
  </table>
</section>

<!-- ===== 2. PEVNE RIADENIE ===== -->
<section>
  <h2>2. Pevné riadenie</h2>
  <p>
    Pri pevnom riadení sú dĺžky všetkých troch konfigurácií nastavené rovnako:
    <code>intervaly = [10 10 10]</code>. Každá konfigurácia trvá 10 krokov, celý cyklus má 30 krokov.
  </p>
  <p>Nastavenie programu:</p>
  <div class="fuzzy-box">
    vlastne_intervaly = 1<br>
    fuzzy_volba = 0<br>
    intervaly = [10 10 10]
  </div>

  <div class="graph-section">
    <div class="graph-row">
      <div class="graph-card">
        <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/rezim3_fuzzy0.png" alt="Režim 3 pevné">
        <div class="caption">
          <span>Režim 3 — Pevné [10 10 10]</span>
          <span>Koniec: <span class="stat">17</span> &nbsp; Max: <span class="stat">25</span></span>
        </div>
      </div>
      <div class="graph-card">
        <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/rezim4_fuzzy0.png" alt="Režim 4 pevné">
        <div class="caption">
          <span>Režim 4 — Pevné [10 10 10]</span>
          <span>Koniec: <span class="stat">18</span> &nbsp; Max: <span class="stat">27</span></span>
        </div>
      </div>
    </div>
    <div class="graph-row">
      <div class="graph-card">
        <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/rezim5_fuzzy0.png" alt="Režim 5 pevné">
        <div class="caption">
          <span>Režim 5 — Pevné [10 10 10]</span>
          <span>Koniec: <span class="stat worse">38</span> &nbsp; Max: <span class="stat worse">39</span></span>
        </div>
      </div>
      <div class="graph-card">
        <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/rezim6_fuzzy0.png" alt="Režim 6 pevné">
        <div class="caption">
          <span>Režim 6 — Pevné [10 10 10]</span>
          <span>Koniec: <span class="stat worse">57</span> &nbsp; Max: <span class="stat worse">60</span></span>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- ===== 3. FUZZY SYSTEM ===== -->
<section>
  <h2>3. Návrh fuzzy systému</h2>
  <p>
    Fuzzy systém typu Mamdani s defuzzifikáciou metódou centroidu. Obsahuje 2 vstupné premenné,
    1 výstupnú premennú a 9 pravidiel pokrývajúcich všetky kombinácie vstupov.
  </p>

  <div class="mf-grid">
    <div class="mf-card">
      <div class="mf-title">Vstup 1: Autá na zelenej [0–100]</div>
      <div class="mf-item"><span>Malo</span> — trapmf [-1 -1 0 8]</div>
      <div class="mf-item"><span>Stredne</span> — trimf [4 12 22]</div>
      <div class="mf-item"><span>Veľa</span> — trapmf [16 28 100 100]</div>
    </div>
    <div class="mf-card">
      <div class="mf-title">Vstup 2: Autá na červenej [0–150]</div>
      <div class="mf-item"><span>Malo</span> — trapmf [-1 -1 3 15]</div>
      <div class="mf-item"><span>Stredne</span> — trimf [8 25 45]</div>
      <div class="mf-item"><span>Veľa</span> — trapmf [30 55 150 150]</div>
    </div>
    <div class="mf-card">
      <div class="mf-title">Výstup: Doba trvania [5–30]</div>
      <div class="mf-item"><span>Krátko</span> — trimf [5 5 12]</div>
      <div class="mf-item"><span>Normálne</span> — trimf [10 18 25]</div>
      <div class="mf-item"><span>Dlho</span> — trapmf [20 28 30 30]</div>
    </div>
  </div>

  <h3>Pravidlá</h3>
  <div class="fuzzy-box">
    <div class="rule-header">9 pravidiel (AND = min, OR = max)</div>
    <div class="rule">1. IF zelená=<em>Malo</em> AND červená=<em>Malo</em> THEN <strong>Normálne</strong></div>
    <div class="rule">2. IF zelená=<em>Malo</em> AND červená=<em>Stredne</em> THEN <strong>Krátko</strong></div>
    <div class="rule">3. IF zelená=<em>Malo</em> AND červená=<em>Veľa</em> THEN <strong>Krátko</strong></div>
    <div class="rule">4. IF zelená=<em>Stredne</em> AND červená=<em>Malo</em> THEN <strong>Normálne</strong></div>
    <div class="rule">5. IF zelená=<em>Stredne</em> AND červená=<em>Stredne</em> THEN <strong>Normálne</strong></div>
    <div class="rule">6. IF zelená=<em>Stredne</em> AND červená=<em>Veľa</em> THEN <strong>Krátko</strong></div>
    <div class="rule">7. IF zelená=<em>Veľa</em> AND červená=<em>Malo</em> THEN <strong>Dlho</strong></div>
    <div class="rule">8. IF zelená=<em>Veľa</em> AND červená=<em>Stredne</em> THEN <strong>Dlho</strong></div>
    <div class="rule">9. IF zelená=<em>Veľa</em> AND červená=<em>Veľa</em> THEN <strong>Normálne</strong></div>
  </div>

  <h3>Princíp fungovania</h3>
  <p>
    Fuzzy systém dynamicky prispôsobuje dobu trvania zelenej aktuálnej situácii na križovatke.
    Keď je na červenej veľa áut a na zelenej málo, systém rýchlo prepne konfiguráciu (krátka zelená).
    Keď je na zelenej veľa áut, ktoré treba pustiť, systém drží zelenú dlhšie. Tento prístup
    zabezpečuje, že žiadny smer nie je dlhodobo zablokovaný, aj počas dopravných špičiek.
  </p>
  <p>
    Kľúčovým zistením pri ladení bolo, že minimálna doba zelenej musí byť aspoň 5 krokov,
    pretože vodič v simulácii potrebuje 3 kroky na reakciu a odchod. Príliš krátke intervaly
    (pod 3 kroky) spôsobia, že žiadne auto neodíde a križovatka sa úplne zablokuje.
  </p>

  <p>Nastavenie programu:</p>
  <div class="fuzzy-box">
    fuzzy_volba = 1<br>
    vlastne_intervaly = 0<br>
    fuzzy_meno = 'kllemo_fuzzy.fis'
  </div>
</section>

<!-- ===== 4. FUZZY VYSLEDKY ===== -->
<section>
  <h2>4. Výsledky fuzzy riadenia</h2>

  <div class="graph-section">
    <div class="graph-row">
      <div class="graph-card">
        <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/rezim3_fuzzy1.png" alt="Režim 3 fuzzy">
        <div class="caption">
          <span>Režim 3 — Fuzzy</span>
          <span>Koniec: <span class="stat better">10</span> &nbsp; Max: <span class="stat better">21</span></span>
        </div>
      </div>
      <div class="graph-card">
        <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/rezim4_fuzzy1.png" alt="Režim 4 fuzzy">
        <div class="caption">
          <span>Režim 4 — Fuzzy</span>
          <span>Koniec: <span class="stat better">7</span> &nbsp; Max: <span class="stat better">20</span></span>
        </div>
      </div>
    </div>
    <div class="graph-row">
      <div class="graph-card">
        <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/rezim5_fuzzy1.png" alt="Režim 5 fuzzy">
        <div class="caption">
          <span>Režim 5 — Fuzzy</span>
          <span>Koniec: <span class="stat better">8</span> &nbsp; Max: <span class="stat better">23</span></span>
        </div>
      </div>
      <div class="graph-card">
        <img src="https://raw.githubusercontent.com/klemo-j/UMINT/CV9/rezim6_fuzzy1.png" alt="Režim 6 fuzzy">
        <div class="caption">
          <span>Režim 6 — Fuzzy</span>
          <span>Koniec: <span class="stat better">9</span> &nbsp; Max: <span class="stat better">33</span></span>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- ===== 5. POROVNANIE ===== -->
<section>
  <h2>5. Porovnanie výsledkov</h2>

  <table>
    <thead>
      <tr>
        <th>Režim</th>
        <th>Pevné — koniec</th>
        <th>Pevné — max</th>
        <th>Fuzzy — koniec</th>
        <th>Fuzzy — max</th>
        <th>Zlepšenie koniec</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>3 (špička C)</td>
        <td>17</td>
        <td>25</td>
        <td class="better">10</td>
        <td class="better">21</td>
        <td class="better">−41 %</td>
      </tr>
      <tr>
        <td>4 (špička B)</td>
        <td>18</td>
        <td>27</td>
        <td class="better">7</td>
        <td class="better">20</td>
        <td class="better">−61 %</td>
      </tr>
      <tr>
        <td>5 (špička A)</td>
        <td class="worse">38</td>
        <td class="worse">39</td>
        <td class="better">8</td>
        <td class="better">23</td>
        <td class="better">−79 %</td>
      </tr>
      <tr>
        <td>6 (kombinácia)</td>
        <td class="worse">57</td>
        <td class="worse">60</td>
        <td class="better">9</td>
        <td class="better">33</td>
        <td class="better">−84 %</td>
      </tr>
    </tbody>
  </table>

  <h3>Splnenie limitov — Režim 6 (fuzzy)</h3>
  <div class="limits-grid">
    <div class="limit-card">
      <div class="limit-label">Max v pruhoch</div>
      <div class="limit-value">≤ 10</div>
      <div class="limit-max">limit: 10 &nbsp; <span class="check">✓</span></div>
    </div>
    <div class="limit-card">
      <div class="limit-label">Max v A2</div>
      <div class="limit-value">≤ 14</div>
      <div class="limit-max">limit: 15 &nbsp; <span class="check">✓</span></div>
    </div>
    <div class="limit-card">
      <div class="limit-label">Max celkovo</div>
      <div class="limit-value">33</div>
      <div class="limit-max">limit: 40 &nbsp; <span class="check">✓</span></div>
    </div>
    <div class="limit-card">
      <div class="limit-label">Koniec scenára</div>
      <div class="limit-value">9</div>
      <div class="limit-max">limit: 20 &nbsp; <span class="check">✓</span></div>
    </div>
  </div>
</section>

<!-- ===== 6. DISKUSIA ===== -->
<section>
  <h2>6. Diskusia</h2>
  <p>
    Fuzzy riadenie dosiahlo výrazne lepšie výsledky vo všetkých testovaných režimoch.
    Najväčší rozdiel je viditeľný v režimoch 5 a 6, kde pevné riadenie nedokázalo zvládnuť
    dopravné špičky — počet áut neustále narastal a na konci scenára bolo 38 resp. 57 áut.
    Fuzzy riadenie tieto scenáre zvládlo s koncovým počtom 8 resp. 9 áut.
  </p>
  <p>
    Hlavná výhoda fuzzy prístupu spočíva v jeho schopnosti dynamicky reagovať na aktuálnu
    dopravnú situáciu. Keď sa na červenej nahromadí veľa áut, fuzzy systém skráti zelenú
    a rýchlejšie prepne konfiguráciu. Naopak, keď je na zelenej veľa áut a na červenej málo,
    systém ponechá zelenú dlhšie, aby sa stihli odbaviť.
  </p>
  <p>
    Pri ladení sa ukázalo, že kľúčovým parametrom je rozsah výstupnej premennej. Príliš krátke
    intervaly (pod 3 kroky) sú kontraproduktívne — vodič v simulácii má reakčný čas 3 kroky,
    takže pri veľmi krátkej zelenej žiadne auto neodíde. Optimálny rozsah bol 5–30 krokov,
    kde sa fuzzy systém pohyboval väčšinou okolo 12–18 krokov podľa situácie.
  </p>
  <p>
    Pevné riadenie je obmedzené tým, že nemá žiadnu spätnú väzbu — ignoruje aktuálny stav
    križovatky. Pri rovnomernej premávke funguje prijateľne (režim 3: 17 áut na konci), ale
    pri silných špičkách z jedného smeru úplne zlyháva (režim 5: 38 áut).
  </p>
</section>

</div>

<div class="footer">
  UMINT 2026 — Laboratórne cvičenie č. 9 — Fuzzy logika — STU FEI
</div>

</body>
</html>
