% Zadanie4_UMINT.m
clc; clear; close all; % Vyčistenie konzoly, pamäte a zatvorenie všetkých grafov

% =========================================================================
% 1. DEFINÍCIA PARAMETROV GENETICKÉHO ALGORITMU (GA)
% =========================================================================
NIND = 200;          % Veľkosť populácie
MAXGEN = 400;        % Počet generácií 
NVAR = 5;            % Počet premenných (x1 až x5)
GGAP = 0.8;          
PM = 0.2;            % Pravdepodobnosť mutácie
pocet_behov = 5;     

% Rozsah premenných: 0 až 10 000 000 EUR 
Space = [zeros(1, NVAR); 10000000 * ones(1, NVAR)];
Amp = 5000 * ones(1, NVAR); % Jemná mutácia

metody_nazvy = {'Mŕtva pokuta', 'Stupňovitá pokuta', 'Úmerná pokuta', 'Bez pokuty'};
vsetky_najlepsie_behy = cell(4, 1); 

disp('Spúšťam optimalizáciu alokácie investícií (čítajte komentáre v kóde)...');

% =========================================================================
% 2. HLAVNÝ CYKLUS PRE VŠETKY METÓDY POKUTOVANIA
% =========================================================================
for typ_pokuty = 1:4
    
    figure('Name', metody_nazvy{typ_pokuty}, 'Position', [100 + typ_pokuty*50, 100, 700, 400]);
    hold on; grid on;
    title(['Konvergencia - ', metody_nazvy{typ_pokuty}]);
    xlabel('Generácia'); ylabel('Kladná Fitness (Reálny výnos v EUR)');
    
    najlepsi_genom_metody = [];
    najlepsie_fitness_metody = -inf; 
    najlepsi_priebeh_metody = [];
    
    for beh = 1:pocet_behov
        
        Chrom = genrpop(NIND, Space); 
        ObjV = zeros(NIND, 1); 
        
        % --- HODNOTENIE ZAČIATOČNEJ POPULÁCIE ---
        for i = 1:NIND
            x = Chrom(i, :); 
            vynos = 0.04*x(1) + 0.07*x(2) + 0.11*x(3) + 0.06*x(4) + 0.05*x(5);
            
            g1 = sum(x) - 10000000;                       
            g2 = x(1) + x(2) - 2500000;                   
            g3 = x(5) - x(4);                             
            g4 = x(3) + x(4) - 0.5 * sum(x);              
            
            porusenia = (g1 > 0) + (g2 > 0) + (g3 > 0) + (g4 > 0);
            suma_poruseni = max(0, g1) + max(0, g2) + max(0, g3) + max(0, g4);
            
            % --- OPRAVENÁ APLIKÁCIA POKÚT ---
            if typ_pokuty == 1      % 1. MŔTVA POKUTA
                if porusenia > 0
                    ObjV(i) = -5000000; % OPRAVA: Žiadny výnos, len tvrdá fixná pokuta
                else
                    ObjV(i) = vynos;
                end
            elseif typ_pokuty == 2  % 2. STUPŇOVITÁ POKUTA
                pokuta = porusenia * 4000000; % OPRAVA: Trest musí byť vyšší ako max možný výnos (3.3M)
                ObjV(i) = vynos - pokuta;
            elseif typ_pokuty == 3  % 3. ÚMERNÁ POKUTA
                pokuta = suma_poruseni * 2.0; 
                ObjV(i) = vynos - pokuta;
            elseif typ_pokuty == 4  % 4. BEZ POKUTY
                ObjV(i) = vynos; 
            end
        end
        
        best_fit = zeros(MAXGEN, 1); 
        
        for gen = 1:MAXGEN
            Nsel = max(2, round(NIND * GGAP));
            if mod(Nsel, 2) ~= 0, Nsel = Nsel + 1; end 
            
            SelCh = selsus(Chrom, -ObjV, Nsel); 
            SelCh = crossov(SelCh, 2, 0); 
            SelCh = mutx(SelCh, PM, Space);
            SelCh = muta(SelCh, PM, Amp, Space); 
            
            % --- HODNOTENIE POTOMKOV ---
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
                
                if typ_pokuty == 1
                    if porusenia > 0
                        ObjVSel(i) = -5000000;
                    else
                        ObjVSel(i) = vynos;
                    end
                elseif typ_pokuty == 2
                    pokuta = porusenia * 4000000;
                    ObjVSel(i) = vynos - pokuta;
                elseif typ_pokuty == 3
                    pokuta = suma_poruseni * 2.0;
                    ObjVSel(i) = vynos - pokuta;
                elseif typ_pokuty == 4
                    ObjVSel(i) = vynos;
                end
            end
            
            KombinovanaPop = [Chrom; SelCh];
            KombinovaneObjV = [ObjV; ObjVSel];
            
            [Chrom, ZotriedeneObjV] = selsort(KombinovanaPop, -KombinovaneObjV, NIND);
            ObjV = -ZotriedeneObjV; 
            
            best_fit(gen) = ObjV(1);
        end
        
        plot(1:MAXGEN, best_fit, 'LineWidth', 1.5, 'DisplayName', ['Beh ', num2str(beh), ' (Fit: ', num2str(best_fit(end), '%.0f'), ')']);
        
        if best_fit(end) > najlepsie_fitness_metody
            najlepsie_fitness_metody = best_fit(end);
            najlepsi_genom_metody = Chrom(1, :);
            najlepsi_priebeh_metody = best_fit;
        end
    end
    
    legend('Location', 'southeast');
    vsetky_najlepsie_behy{typ_pokuty} = najlepsi_priebeh_metody;
    
    % --- VÝPIS VÝSLEDKOV ---
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
    g1 = sum(najlepsi_genom_metody) - 10000000;
    g2 = najlepsi_genom_metody(1) + najlepsi_genom_metody(2) - 2500000;
    g3 = najlepsi_genom_metody(5) - najlepsi_genom_metody(4);
    g4 = najlepsi_genom_metody(3) + najlepsi_genom_metody(4) - 0.5 * sum(najlepsi_genom_metody);
    
    disp([' 1. Celkový kapitál <= 10M:           ', num2str(g1, '%.2f')]);
    disp([' 2. Akcie <= 2.5M:                    ', num2str(g2, '%.2f')]);
    disp([' 3. Štátne dlhopisy >= Úspory:        ', num2str(g3, '%.2f')]);
    disp([' 4. Dlhopisy <= 50% celkovej sumy:    ', num2str(g4, '%.2f')]);
    
    if typ_pokuty == 4
        disp(' ');
        disp(' !!! UPOZORNENIE: Tu jasne vidieť, že kontrolné hodnoty sú obrovské KLADNÉ čísla,');
        disp(' !!! čo znamená, že limity boli extrémne prekročené. Takéto riešenie je v praxi nepoužiteľné.');
    end
    disp(' ');
end

% =========================================================================
% 4. FINÁLNY SPOLOČNÝ POROVNÁVACÍ GRAF
% =========================================================================
figure('Name', 'Porovnanie metód pokutovania', 'Position', [300, 200, 700, 400]);
plot(1:MAXGEN, vsetky_najlepsie_behy{1}, 'r', 'LineWidth', 2, 'DisplayName', metody_nazvy{1}); hold on;
plot(1:MAXGEN, vsetky_najlepsie_behy{2}, 'g', 'LineWidth', 2, 'DisplayName', metody_nazvy{2});
plot(1:MAXGEN, vsetky_najlepsie_behy{3}, 'b', 'LineWidth', 2, 'DisplayName', metody_nazvy{3});
plot(1:MAXGEN, vsetky_najlepsie_behy{4}, 'k', 'LineWidth', 2, 'DisplayName', metody_nazvy{4}); 
grid on; xlabel('Generácia'); ylabel('Kladná Fitness (Výnos)');
title('Porovnanie najlepších priebehov pre každú metódu pokutovania');
legend('Location', 'southeast');
disp('Všetky výpočty dokončené.');