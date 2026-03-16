% Zadanie4_UMINT.m
clc; clear; close all; % Vyčistenie konzoly, pamäte a zatvorenie všetkých grafov

% =========================================================================
% 1. DEFINÍCIA PARAMETROV GENETICKÉHO ALGORITMU (GA)
% =========================================================================
NIND = 200;          % Veľkosť populácie (počet možných riešení v jednej generácii)
MAXGEN = 400;        % Počet generácií (koľkokrát sa bude populácia vyvíjať)
NVAR = 5;            % Počet premenných (máme 5 finančných produktov x1 až x5)
GGAP = 0.8;          % Generational gap (80 % populácie tvoria nové deti, 20 % prežije)
PM = 0.2;            % Pravdepodobnosť mutácie (20 % šanca, že jedinec zmutuje)
pocet_behov = 5;     % Koľkokrát spustíme každú metódu, aby sme mali štatistiku

% Definícia priestoru hľadania (hranice pre premenné x1 až x5 v Eurách)
% Prvý riadok sú minimá (0 EUR), druhý riadok sú maximá (10 000 000 EUR pre každú položku)
Space = [zeros(1, NVAR); 10000000 * ones(1, NVAR)];

% Amplitúda pre aditívnu mutáciu (muta). Keď algoritmus jemne ladí hodnoty, 
% pridá alebo uberie maximálne 5000 EUR. Pomáha to presne sa trafiť na hranicu.
Amp = 5000 * ones(1, NVAR); 

% Názvy metód pre výpisy a legendy v grafoch (4. metóda slúži na ukážku zlyhania bez pokút)
metody_nazvy = {'Mŕtva pokuta', 'Stupňovitá pokuta', 'Úmerná pokuta', 'Bez pokuty'};
vsetky_najlepsie_behy = cell(4, 1); % Sem si uložíme najlepšie krivky pre finálny spoločný graf

disp('Spúšťam optimalizáciu alokácie investícií (čítajte komentáre v kóde)...');

% =========================================================================
% 2. HLAVNÝ CYKLUS PRE VŠETKY METÓDY POKUTOVANIA
% =========================================================================
for typ_pokuty = 1:4
    
    % Vytvorenie grafu pre aktuálnu metódu
    figure('Name', metody_nazvy{typ_pokuty}, 'Position', [100 + typ_pokuty*50, 100, 700, 400]);
    hold on; grid on;
    title(['Konvergencia - ', metody_nazvy{typ_pokuty}]);
    xlabel('Generácia'); ylabel('Kladná Fitness (Reálny výnos v EUR)');
    
    najlepsi_genom_metody = [];
    najlepsie_fitness_metody = -inf; % Začíname od najhoršieho (mínus nekonečno), lebo hľadáme maximum
    najlepsi_priebeh_metody = [];
    
    % Cyklus pre spustenie 5 nezávislých behov pre aktuálnu metódu
    for beh = 1:pocet_behov
        
        % Vytvorenie počiatočnej (nultej) populácie náhodných čísel v hraniciach Space
        Chrom = genrpop(NIND, Space); 
        ObjV = zeros(NIND, 1); % Príprava prázdneho poľa pre fitness (výnos)
        
        % --- HODNOTENIE ZAČIATOČNEJ POPULÁCIE ---
        for i = 1:NIND
            x = Chrom(i, :); % Vyberieme i-teho jedinca (vektor 5 investovaných súm)
            
            % Výpočet SKUTOČNÉHO VÝNOSU na základe úrokov z tabuľky
            vynos = 0.04*x(1) + 0.07*x(2) + 0.11*x(3) + 0.06*x(4) + 0.05*x(5);
            
            % --- OHRANIČENIA ---
            % Rovnice sú upravené tak, že ak je výsledok g > 0, pravidlo je PORUŠENÉ.
            g1 = sum(x) - 10000000;                       % Max rozpočet 10 miliónov
            g2 = x(1) + x(2) - 2500000;                   % Max 2.5 milióna do akcií (x1+x2)
            g3 = x(5) - x(4);                             % Úspory (x5) musia byť <= Štátne dlh.(x4)
            g4 = x(3) + x(4) - 0.5 * sum(x);              % Dlhopisy (x3+x4) nesmú presiahnuť 50% celku
            
            % Pomocné premenné pre výpočet pokút
            % (gX > 0) vráti 1 ak je pravidlo porušené, inak 0. Súčet nám dá počet porušení.
            porusenia = (g1 > 0) + (g2 > 0) + (g3 > 0) + (g4 > 0);
            
            % max(0, gX) vezme buď nulu (ak sme pod limitom), alebo priamo sumu, o ktorú sme limit prekročili.
            suma_poruseni = max(0, g1) + max(0, g2) + max(0, g3) + max(0, g4);
            
            % --- APLIKÁCIA POKUTY PODĽA METÓDY ---
            pokuta = 0;
            if typ_pokuty == 1      % 1. MŔTVA POKUTA
                if porusenia > 0
                    pokuta = 5000000; % Stačí chyba o 1 cent a hneď dostane 5 miliónov pokutu
                end
            elseif typ_pokuty == 2  % 2. STUPŇOVITÁ POKUTA
                pokuta = porusenia * 500000; % Dostane pol milióna ZA KAŽDÉ porušené pravidlo
            elseif typ_pokuty == 3  % 3. ÚMERNÁ POKUTA
                pokuta = suma_poruseni * 2.0; % Pokuta je presne 2-násobok sumy, o ktorú prekročil limit
            elseif typ_pokuty == 4  % 4. BEZ POKUTY
                pokuta = 0; % Slepý algoritmus, povolí čokoľvek
            end
            
            % Fitness hodnota je Reálny výnos MÍNUS pokuta
            ObjV(i) = vynos - pokuta;
        end
        
        best_fit = zeros(MAXGEN, 1); % Pole pre ukladanie najlepšieho jedinca v každej generácii
        
        % =================================================================
        % CYKLUS GENERÁCIÍ (Vývoj populácie)
        % =================================================================
        for gen = 1:MAXGEN
            
            % Výpočet koľko jedincov sa ide krížiť (80 % z 200 = 160 jedincov)
            Nsel = max(2, round(NIND * GGAP));
            if mod(Nsel, 2) ~= 0, Nsel = Nsel + 1; end % Počet rodičov musí byť párny
            
            % --- SELEKCIA ---
            % DÔLEŽITÝ TRIK: Funkcia selsus (a všetky v toolboxe) hľadajú MINIMUM. 
            % My ale chceme MAXIMALIZOVAŤ náš výnos. Preto pošleme toolboxu naše 
            % kladné výnosy so znamienkom MÍNUS (-ObjV). Pre toolbox bude najlepší
            % ten, kto má napr. -724 000 (lebo je to menšie ako -10 000). 
            SelCh = selsus(Chrom, -ObjV, Nsel); 
            
            % --- KRÍŽENIE ---
            % crossov - viacbodové kríženie dvoch rodičov (parameter 2 = dvojbodové)
            SelCh = crossov(SelCh, 2, 0); 
            
            % --- MUTÁCIA ---
            % mutx - hrubá mutácia, prepíše hodnotu na úplne iné číslo v rámci Space
            SelCh = mutx(SelCh, PM, Space);
            % muta - jemná aditívna mutácia, k existujúcej hodnote priráta drobnú sumu určenú v Amp
            SelCh = muta(SelCh, PM, Amp, Space); 
            
            % --- HODNOTENIE POTOMKOV (Rovnaký postup ako pre rodičov hore) ---
            pocet_potomkov = size(SelCh, 1);
            ObjVSel = zeros(pocet_potomkov, 1);
            for i = 1:pocet_potomkov
                x = SelCh(i, :);
                vynos = 0.04*x(1) + 0.07*x(2) + 0.11*x(3) + 0.06*x(4) + 0.05*x(5);
                
                g1 = sum(x) - 10000000;
                g2 = x(1) + x(2) - 2500000;
                g3 = x(5) - x(4);
                g4 = x(3) + x(4) - 0.5 * sum(x);
                
                porusenia = (g1 > 0) + (g2 > 0) + (g3 > 0) + (g4 > 0);
                suma_poruseni = max(0, g1) + max(0, g2) + max(0, g3) + max(0, g4);
                
                pokuta = 0;
                if typ_pokuty == 1
                    if porusenia > 0, pokuta = 5000000; end
                elseif typ_pokuty == 2
                    pokuta = porusenia * 500000;
                elseif typ_pokuty == 3
                    pokuta = suma_poruseni * 2.0;
                elseif typ_pokuty == 4
                    pokuta = 0; 
                end
                
                ObjVSel(i) = vynos - pokuta;
            end
            
            % --- ELITIZMUS A REINZERCIA ---
            % Spojíme všetkých rodičov a všetky nové deti do jednej veľkej zmesi (200 + 160 = 360)
            KombinovanaPop = [Chrom; SelCh];
            KombinovaneObjV = [ObjV; ObjVSel];
            
            % Pomocou selsort z nich vyberieme 200 najlepších. 
            % OPÄŤ TRIK S MÍNUSOM: Aby funkcia vybrala najlepších (najvyššie zisky), 
            % pošleme jej -KombinovaneObjV. Ona ich zoradí a vráti v ZotriedeneObjV.
            [Chrom, ZotriedeneObjV] = selsort(KombinovanaPop, -KombinovaneObjV, NIND);
            
            % Vrátime im späť ich reálnu KLADNÚ hodnotu výnosu (odstránime mínus)
            ObjV = -ZotriedeneObjV; 
            
            % Uložíme si najlepšieho z generácie (vďaka selsort je zaručene na prvej pozícii)
            best_fit(gen) = ObjV(1);
        end
        
        % Vykreslíme tenkú čiaru pre aktuálny beh
        plot(1:MAXGEN, best_fit, 'LineWidth', 1.5, 'DisplayName', ['Beh ', num2str(beh), ' (Fit: ', num2str(best_fit(end), '%.0f'), ')']);
        
        % Ak tento beh našiel celkovo najlepší výsledok metódy, zapamätáme si ho
        if best_fit(end) > najlepsie_fitness_metody
            najlepsie_fitness_metody = best_fit(end);
            najlepsi_genom_metody = Chrom(1, :);
            najlepsi_priebeh_metody = best_fit;
        end
    end
    
    % Ukončenie grafu pre danú metódu
    legend('Location', 'southeast');
    vsetky_najlepsie_behy{typ_pokuty} = najlepsi_priebeh_metody;
    
    % =========================================================================
    % 3. VÝPIS VÝSLEDKOV DO KONZOLY PRE DANÚ METÓDU
    % =========================================================================
    disp('================================================================');
    disp([' METÓDA POKUTOVANIA: ', metody_nazvy{typ_pokuty}]);
    disp('================================================================');
    disp(['Najvyššia dosiahnutá Fitness / Výnos: ', num2str(najlepsie_fitness_metody, '%.2f'), ' EUR']);
    
    disp(' ');
    disp('Optimálna alokácia investícií (v EUR):');
    disp([' x1 (Bežné akcie):      ', num2str(najlepsi_genom_metody(1), '%.2f')]);
    disp([' x2 (Preferov. akcie):  ', num2str(najlepsi_genom_metody(2), '%.2f')]);
    disp([' x3 (Podnikov. dlh.):   ', num2str(najlepsi_genom_metody(3), '%.2f')]);
    disp([' x4 (Štátne dlh.):      ', num2str(najlepsi_genom_metody(4), '%.2f')]);
    disp([' x5 (Úspory v banke):   ', num2str(najlepsi_genom_metody(5), '%.2f')]);
    
    disp(' ');
    disp('Kontrola ohraničení (Záporné čísla sú správne = rezerva, kladné = porušenie!):');
    % Znovu dosadíme najlepšie riešenie do rovníc pre ohraničenia, aby sme ich vypísali
    g1 = sum(najlepsi_genom_metody) - 10000000;
    g2 = najlepsi_genom_metody(1) + najlepsi_genom_metody(2) - 2500000;
    g3 = najlepsi_genom_metody(5) - najlepsi_genom_metody(4);
    g4 = najlepsi_genom_metody(3) + najlepsi_genom_metody(4) - 0.5 * sum(najlepsi_genom_metody);
    
    disp([' 1. Celkový kapitál <= 10M:           ', num2str(g1, '%.2f')]);
    disp([' 2. Akcie <= 2.5M:                    ', num2str(g2, '%.2f')]);
    disp([' 3. Štátne dlhopisy >= Úspory:        ', num2str(g3, '%.2f')]);
    disp([' 4. Dlhopisy <= 50% celkovej sumy:    ', num2str(g4, '%.2f')]);
    
    % Špeciálne varovanie pri metóde bez pokuty pre obhajobu
    if typ_pokuty == 4
        disp(' ');
        disp(' !!! UPOZORNENIE: Tu jasne vidieť, že kontrolné hodnoty sú obrovské KLADNÉ čísla,');
        disp(' !!! čo znamená, že limity boli extrémne prekročené. Takéto riešenie je v praxi nepoužiteľné.');
    end
    disp(' ');
end

% =========================================================================
% 4. FINÁLNY SPOLOČNÝ POROVNÁVACÍ GRAF (Na ukážku rozdielov)
% =========================================================================
figure('Name', 'Porovnanie metód pokutovania', 'Position', [300, 200, 700, 400]);
plot(1:MAXGEN, vsetky_najlepsie_behy{1}, 'r', 'LineWidth', 2, 'DisplayName', metody_nazvy{1}); hold on;
plot(1:MAXGEN, vsetky_najlepsie_behy{2}, 'g', 'LineWidth', 2, 'DisplayName', metody_nazvy{2});
plot(1:MAXGEN, vsetky_najlepsie_behy{3}, 'b', 'LineWidth', 2, 'DisplayName', metody_nazvy{3});
plot(1:MAXGEN, vsetky_najlepsie_behy{4}, 'k', 'LineWidth', 2, 'DisplayName', metody_nazvy{4}); % Čierna pre metódu bez pokuty
grid on; xlabel('Generácia'); ylabel('Kladná Fitness (Výnos)');
title('Porovnanie najlepších priebehov pre každú metódu pokutovania');
legend('Location', 'southeast');
disp('Všetky výpočty dokončené.');