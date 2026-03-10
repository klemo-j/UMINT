% Zadanie3_UMINT.m - Optimalizácia trasy pomocou GA
clc; clear; close all;

% --- 1. Definícia bodov (Súradnice miestností/bodov) ---
B = [0,0; 17,100; 51,15; 70,62; 42,25; 32,17; 51,64; 39,45; 68,89; 20,19; ...
     12,87; 80,37; 35,82; 2,15; 38,95; 33,50; 85,52; 97,27; 99,10; 37,67; ...
     20,82; 49,0; 62,14; 7,60; 0,0];

% --- 2. Parametre Genetického Algoritmu ---
NIND = 200;          % Veľkosť populácie
MAXGEN = 2000;       % Maximálny počet generácií
NVAR = 23;           % Počet premenných (vnútorné body medzi štartom a cieľom)
GGAP = 0.9;          % Generational gap
PM = 0.5;            % Pravdepodobnosť mutácie
pocet_behov = 10;    % Počet opakovaní experimentu

% Predalokácia polí pre výsledky
vsetky_najlepsie_fitness = zeros(MAXGEN, pocet_behov);
konecne_dlzky = zeros(pocet_behov, 1);
najlepsi_genom_celkovo = [];
najlepsia_dlzka_celkovo = inf;

% Príprava farieb pre graf (10 rôznych farieb)
farby = lines(pocet_behov); 
disp('Spúšťam 10 behov Genetického Algoritmu...');

% --- 3. Hlavný cyklus pre 10 behov ---
for beh = 1:pocet_behov
    % Inicializácia populácie: Náhodné permutácie čísel 2 až 24
    Chrom = zeros(NIND, NVAR);
    for i = 1:NIND
        Chrom(i, :) = randperm(NVAR) + 1; 
    end
    
    % Výpočet dĺžky trasy pre začiatočnú populáciu
    ObjV = zeros(NIND, 1);
    for i = 1:NIND
        trasa = [1, Chrom(i, :), 25]; 
        dlzka = 0;
        for j = 1:24
            bod1 = trasa(j); bod2 = trasa(j+1);
            dx = B(bod2, 1) - B(bod1, 1);
            dy = B(bod2, 2) - B(bod1, 2);
            dlzka = dlzka + sqrt(dx^2 + dy^2);
        end
        ObjV(i) = dlzka;
    end
    
    best_fit = zeros(MAXGEN, 1);
    
    for gen = 1:MAXGEN
        FitnV = 1 ./ (ObjV + 1e-6); % Fitness funkcia
        
        Nsel = max(2, round(NIND * GGAP));
        if mod(Nsel, 2) ~= 0, Nsel = Nsel + 1; end
        
        SelCh = seltourn(Chrom, FitnV, Nsel);   % Selekcia
        SelCh = crosord(SelCh, 1);              % Kríženie
        SelCh = invord(SelCh, PM);               % Mutácia
        
        % Výpočet fitness pre potomkov
        pocet_potomkov = size(SelCh, 1);
        ObjVSel = zeros(pocet_potomkov, 1);
        for i = 1:pocet_potomkov
            trasa = [1, SelCh(i, :), 25]; 
            dlzka = 0;
            for j = 1:24
                bod1 = trasa(j); bod2 = trasa(j+1);
                dx = B(bod2, 1) - B(bod1, 1);
                dy = B(bod2, 2) - B(bod1, 2);
                dlzka = dlzka + sqrt(dx^2 + dy^2);
            end
            ObjVSel(i) = dlzka;
        end
        
        % Reinzercia a elitizmus
        [Chrom, ObjV] = selsort([Chrom; SelCh], [ObjV; ObjVSel], NIND);
        best_fit(gen) = ObjV(1);
    end
    
    % Uloženie dát
    vsetky_najlepsie_fitness(:, beh) = best_fit;
    konecne_dlzky(beh) = best_fit(end);
    
    if best_fit(end) < najlepsia_dlzka_celkovo
        najlepsia_dlzka_celkovo = best_fit(end);
        najlepsi_genom_celkovo = [1, Chrom(1, :), 25]; 
    end
    
    fprintf('Beh %2d ukončený, finálna dĺžka: %.4f\n', beh, konecne_dlzky(beh));
end

% --- 4. GRAF KONVERGENCIE (VŠETKO V JEDNOM) ---
figure('Name', 'Analýza konvergencie 10 behov GA', 'Position', [100, 100, 950, 650]);
hold on; grid on;
h_behy = zeros(pocet_behov, 1);
popis_legendy = cell(pocet_behov + 1, 1);

% Vykreslenie jednotlivých farebných behov
for i = 1:pocet_behov
    h_behy(i) = plot(1:MAXGEN, vsetky_najlepsie_fitness(:, i), ...
        'Color', farby(i,:), 'LineWidth', 1.2);
    popis_legendy{i} = sprintf('Beh %2d: %.2f', i, konecne_dlzky(i));
end

% Vykreslenie PRIEMERU (Hrubá čierna čiara navrchu)
priemerna_krivka = mean(vsetky_najlepsie_fitness, 2);
h_priemer = plot(1:MAXGEN, priemerna_krivka, 'k-', 'LineWidth', 4);
popis_legendy{pocet_behov + 1} = sprintf('PRIEMER: %.2f', mean(konecne_dlzky));

% Formátovanie grafu
title('Závislosť dĺžky trasy od generácií (10 behov)', 'FontSize', 14);
xlabel('Generácia', 'FontWeight', 'bold');
ylabel('Dĺžka trasy', 'FontWeight', 'bold');

% Legenda vľavo hore (NorthWest) s fixným písmom pre zarovnanie
legend([h_behy; h_priemer], popis_legendy, ...
    'Location', 'northwest', 'FontSize', 10, 'FontName', 'Consolas');

% --- 5. Vykreslenie najlepšej nájdenej trasy ---
figure('Name', 'Najlepšia nájdená trasa', 'Position', [150, 150, 800, 600]);
pos = B(najlepsi_genom_celkovo, :)'; 
plot(pos(1,:), pos(2,:), '-o', 'LineWidth', 2, 'MarkerSize', 7, ...
     'MarkerFaceColor', 'w', 'Color', [0 0.447 0.741]);
hold on; grid on; axis equal;

% Zvýraznenie štartu a cieľa
plot(B(1,1), B(1,2), 'gs', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
plot(B(25,1), B(25,2), 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r');

for i = 1:size(B,1)
    text(B(i,1)+1.5, B(i,2)+1.5, num2str(i), 'FontSize', 9, 'FontWeight', 'bold');
end
title(sprintf('Najlepšia nájdená dráha (Dĺžka = %.4f)', najlepsia_dlzka_celkovo));

% --- ZÁVEREČNÉ ZHRNUTIE ---
disp('================================================');
disp(['Úplne najkratšia nájdená dĺžka: ', num2str(najlepsia_dlzka_celkovo)]);

% Vypísanie trasy pekne so šípkami
trasa_text = strjoin(cellstr(num2str(najlepsi_genom_celkovo(:))), ' -> ');
disp(['Najlepšia nájdená trasa: ', trasa_text]);
disp('================================================');