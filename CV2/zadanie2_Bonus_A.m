% === BONUS A: Nastavenie parametrov GA pre 100-D úlohu (VIAC BEHOV) ===
clc;
clear;

dim = 100;               % Počet premenných (100-D úloha) 
popsize = 1000;           % Veľkosť populácie
gen_max = 2000;          % Maximálny počet generácií 
mut_rate = 0.1;          % Pravdepodobnosť mutácie 
Amp      = ones(1,dim);  % Amplituda pripocitania k muta 
num_runs = 5;            % POČET BEHOV ALGORITMU (Pridané pre graf s legendou)

% Matica ohraničení (Space)
Space = [-1000 * ones(1, dim); 
          1000 * ones(1, dim)];

% Príprava premenných pre zber dát z viacerých behov
all_fitness_history = zeros(num_runs, gen_max); 
overall_best_fit = inf; 
overall_best_ind = [];

% === Vonkajší cyklus pre viacero behov ===
for r = 1:num_runs
    fprintf('--- Spúšťam beh číslo %d ---\n', r);
    
    % 1. Inicializácia počiat. populácie (musí byť vnútri pre každý nový beh)
    Pop = genrpop(popsize, Space); 
    best_fitness_history = zeros(1, gen_max);
    
    % === Hlavný cyklus GA ===
    for g = 1:gen_max
        
        % 2. Vyhodnotenie fitness
        ObjV = zeros(1, popsize);
        for i = 1:popsize
            % SPRÁVNE VOLANIE FITNESS FUNKCIE:
            ObjV(i) = testfn3c(Pop(i, :)); 
        end
        
        % Uloženie najlepšieho jedinca generácie
        [min_fit, min_idx] = min(ObjV);
        best_fitness_history(g) = min_fit;
        best_ind = Pop(min_idx, :);
        
        % 3. Výber (Selekcia)
        SelPop = selsus(Pop, ObjV, popsize);
        
        % 4. Kríženie (Crossover)
        CrossPop = crossov(SelPop, 1, 0);
        
        % 5. Mutácie 
        MutPop = mutx(CrossPop, mut_rate, Space);
        MutpopA = muta(MutPop, mut_rate, Amp, Space);
        
        % 6. Nová populácia a Elitizmus
        Pop = MutpopA;
        Pop(1, :) = best_ind; % Zachovanie najlepšieho jedinca
        
        % Výpis progresu do konzoly
        if mod(g, 500) == 0
            fprintf('Beh %d - Generácia: %d / %d, Najlepšia fitness: %.4f\n', r, g, gen_max, min_fit);
        end
        
    end
    
    % Po skončení jedného behu uložíme jeho históriu do celkovej matice
    all_fitness_history(r, :) = best_fitness_history;
    
    % Ak sme našli celkovo najlepšie globálne minimum, zapamätáme si ho
    if min_fit < overall_best_fit
        overall_best_fit = min_fit;
        overall_best_ind = best_ind;
    end
    
end

% === Vykreslenie všetkých behov do jedného grafu ===
figure(1);
plot(1:gen_max, all_fitness_history', 'LineWidth', 1.5); 
title('Konvergencia GA: Schwefel 100-D (Viac behov)');
xlabel('Počet generácií');
ylabel('Hodnota účelovej funkcie F(x)');
grid on;

% Vylepšená legenda s nastaveniami
nazvy_behov = arrayfun(@(x) sprintf('Beh %d', x), 1:num_runs, 'UniformOutput', false);
lgd = legend(nazvy_behov);
title(lgd, sprintf('Nastavenia GA:\nPopulácia: %d\nGenerácie: %d\nMutácia: %.2f', popsize, gen_max, mut_rate));

% === Výpis celkových výsledkov ===
fprintf('\n--- BONUS A: VÝSLEDKY (zo všetkých %d behov) ---\n', num_runs);
fprintf('Nájdená globálna minimálna hodnota (fitness): %.4f (Teoretické je cca -79272)\n', overall_best_fit);