% Zadanie3_UMINT.m
clc; clear; close all;

% --- 1. Definícia bodov (Súradnice miestností/bodov) ---
B = [0,0; 17,100; 51,15; 70,62; 42,25; 32,17; 51,64; 39,45; 68,89; 20,19; ...
     12,87; 80,37; 35,82; 2,15; 38,95; 33,50; 85,52; 97,27; 99,10; 37,67; ...
     20,82; 49,0; 62,14; 7,60; 0,0];

% --- 2. Parametre Genetického Algoritmu ---
NIND = 200;          % Veľkosť populácie
MAXGEN = 2000;       % Maximálny počet generácií
NVAR = 23;          % Počet premenných - permutujeme iba vnútorné body (2 až 24)
GGAP = 0.9;         % Generational gap (80 % populácie sa nahradí potomkami)
PM = 0.5;           % Pravdepodobnosť mutácie
pocet_behov = 10;   % Požadovaný počet behov podľa zadania

% Predalokácia polí pre výsledky
vsetky_najlepsie_fitness = zeros(MAXGEN, pocet_behov);
konecne_dlzky = zeros(pocet_behov, 1);
najlepsi_genom_celkovo = [];
najlepsia_dlzka_celkovo = inf;

figure('Name', 'Priebeh fitness vs. generácie', 'Position', [100, 100, 800, 500]); 
hold on; grid on;

disp('Spúšťam 10 behov Genetického Algoritmu (bez pouzitia function)...');

% --- 3. Hlavný cyklus pre 10 behov ---
for beh = 1:pocet_behov
    % Inicializácia populácie: Náhodné permutácie čísel 2 až 24
    Chrom = zeros(NIND, NVAR);
    for i = 1:NIND
        Chrom(i, :) = randperm(NVAR) + 1; 
    end
    
    % =====================================================================
    % VÝPOČET DĹŽKY TRASY PRE ZAČIATOČNÚ POPULÁCIU (bez funkcie)
    % =====================================================================
    ObjV = zeros(NIND, 1);
    for i = 1:NIND
        trasa = [1, Chrom(i, :), 25]; % Pridáme štart (1) a cieľ (25)
        dlzka = 0;
        for j = 1:24
            bod1 = trasa(j);
            bod2 = trasa(j+1);
            % Pytagorova veta: vzdialenost = sqrt((x2 - x1)^2 + (y2 - y1)^2)
            dx = B(bod2, 1) - B(bod1, 1);
            dy = B(bod2, 2) - B(bod1, 2);
            dlzka = dlzka + sqrt(dx^2 + dy^2);
        end
        ObjV(i) = dlzka;
    end
    
    best_fit = zeros(MAXGEN, 1);
    
    for gen = 1:MAXGEN
        % Prevod dĺžky na Fitness pre selekciu (čím kratšia, tým lepšia)
        FitnV = 1 ./ (ObjV + 1e-6); 
        
        % Počet jedincov, ktorí sa budú krížiť
        Nsel = max(2, round(NIND * GGAP));
        if mod(Nsel, 2) ~= 0, Nsel = Nsel + 1; end % Musí byť párne
        
        % 1. Selekcia (Stochastic Universal Sampling z toolboxu)
        SelCh = seltourn(Chrom, FitnV, Nsel); 
        
        % 2. Kríženie (Order Crossover z toolboxu, mód 1 = susedia)
        SelCh = crosord(SelCh, 1); 
        
        % 3. Mutácia (Inverzia poradia z toolboxu)
        SelCh = invord(SelCh, PM); 
        
        % =================================================================
        % VÝPOČET DĹŽKY TRASY PRE NOVÝCH POTOMKOV (bez funkcie)
        % =================================================================
        pocet_potomkov = size(SelCh, 1);
        ObjVSel = zeros(pocet_potomkov, 1);
        for i = 1:pocet_potomkov
            trasa = [1, SelCh(i, :), 25]; 
            dlzka = 0;
            for j = 1:24
                bod1 = trasa(j);
                bod2 = trasa(j+1);
                dx = B(bod2, 1) - B(bod1, 1);
                dy = B(bod2, 2) - B(bod1, 2);
                dlzka = dlzka + sqrt(dx^2 + dy^2);
            end
            ObjVSel(i) = dlzka;
        end
        
        % 4. Elitizmus a reinzercia (pomocou selsort z toolboxu)
        KombinovanaPop = [Chrom; SelCh];
        KombinovaneObjV = [ObjV; ObjVSel];
        [Chrom, ObjV] = selsort(KombinovanaPop, KombinovaneObjV, NIND);
        
        % Uloženie najlepšieho jedinca v generácii
        best_fit(gen) = ObjV(1);
    end
    
    % Uloženie dát z aktuálneho behu
    vsetky_najlepsie_fitness(:, beh) = best_fit;
    konecne_dlzky(beh) = best_fit(end);
    
    % Kontrola úplne najlepšieho riešenia zo všetkých behov
    if best_fit(end) < najlepsia_dlzka_celkovo
        najlepsia_dlzka_celkovo = best_fit(end);
        najlepsi_genom_celkovo = [1, Chrom(1, :), 25]; 
    end
    
    % Vykreslenie čiary pre aktuálny beh
    plot(1:MAXGEN, best_fit, 'Color', [0.7 0.7 0.7], 'HandleVisibility', 'off'); 
    fprintf('Beh %2d/%d ukončený, finálna dĺžka: %.4f\n', beh, pocet_behov, konecne_dlzky(beh));
end

% --- 4. Priemerná krivka a grafika ---
priemerna_krivka = mean(vsetky_najlepsie_fitness, 2);
plot(1:MAXGEN, priemerna_krivka, 'k-', 'LineWidth', 2.5, 'DisplayName', 'Priemerná konvergencia');
xlabel('Generácia'); ylabel('Dĺžka trasy');
title('Závislosť dĺžky trasy od generácií (10 behov)');
legend('Location', 'northeast'); 

% --- 5. Vykreslenie najlepšej trasy v rovine ---
figure('Name', 'Najlepšia nájdená trasa', 'Position', [150, 150, 700, 500]);
pos = B(najlepsi_genom_celkovo, :)'; 
plot(pos(1,:), pos(2,:), '-o', 'LineWidth', 1.5, 'MarkerSize', 6, ...
     'MarkerFaceColor', 'w', 'Color', [0 0.4470 0.7410]);
hold on;
scatter(B(:,1), B(:,2), 36, 'k', 'filled'); 
for i = 1:size(B,1)
    text(B(i,1)+1.5, B(i,2)+1.5, num2str(i), 'FontSize', 9, 'FontWeight', 'bold');
end
axis equal; grid on;
xlabel('Súradnica X'); ylabel('Súradnica Y');
title(sprintf('Najlepšia nájdená dráha\nDĺžka = %.4f', najlepsia_dlzka_celkovo));

% Výpis výsledkov do konzoly 
disp('================================================');
disp('                  ZHRNUTIE                      ');
disp('================================================');
disp(['Úplne najkratšia nájdená dĺžka: ', num2str(najlepsia_dlzka_celkovo)]);
uspesne_behy = sum(konecne_dlzky <= 480);
disp(['Počet behov s dĺžkou <= 480: ', num2str(uspesne_behy), ' z ', num2str(pocet_behov), ...
      ' (', num2str((uspesne_behy/pocet_behov)*100), ' %)']);
disp('Najlepší genóm (poradie uzlov):');
disp(najlepsi_genom_celkovo);
disp('================================================');