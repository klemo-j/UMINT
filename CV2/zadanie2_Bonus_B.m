clc;
clear;

% === Nastavenie parametrov GA ===
dim = 10;                % Počet premenných (10-D úloha) 
popsize = 2000;           % Veľkosť populácie
gen_max = 5000;          % Maximálny počet generácií 
mut_rate = 0.3;          % Pravdepodobnosť mutácie 
Amp      = ones(1,dim);  % Amplituda pripocitania k muta 
num_runs = 5;            % POČET BEHOV ALGORITMU

% Matica ohraničení (Space) - pre Eggholder sa štandardne používa -512 až 512
Space = [-500 * ones(1, dim); 
          500 * ones(1, dim)];
 
% Príprava premenných pre zber dát z viacerých behov
all_fitness_history = zeros(num_runs, gen_max); 
overall_best_fit = inf; 
overall_best_ind = [];

% === Vonkajší cyklus pre viacero behov ===
for r = 1:num_runs
    fprintf('--- Spúšťam beh číslo %d ---\n', r);
    
    % 1. Inicializácia počiat. populácie pre daný beh
    Pop = genrpop(popsize, Space); 
    best_fitness_history = zeros(1, gen_max);
    
    % === Hlavný cyklus GA ===
    for g = 1:gen_max
        
        % 2. Vyhodnotenie fitness 
        ObjV = zeros(1, popsize);
        for i = 1:popsize
            ObjV(i) = eggholder(Pop(i, :)); 
        end
        
        % Uloženie najlepšieho jedinca generácie
        [min_fit, min_idx] = min(ObjV);
        best_fitness_history(g) = min_fit;
        best_ind = Pop(min_idx, :);
        
        % 3. Výber (Selekcia) 
        %čím nižšia fitness, tým lepšie pre minimalizáciu
        SelPop = selsus(Pop, ObjV, popsize);
        
        % 4. Kríženie
        CrossPop = intmedx(SelPop,1);
        
        % 5. Mutácie
        MutPop = mutx(CrossPop, mut_rate, Space);
        MutpopA = muta(MutPop, mut_rate, Amp, Space);
        
        % 6. Nová populácia a Elitizmus
        Pop = MutpopA;
        Pop(1, :) = best_ind; 
        
    end
    
    % Uloženie histórie aktuálneho behu do celkovej matice
    all_fitness_history(r, :) = best_fitness_history;
    
    % Aktualizácia celkového najlepšieho riešenia
    if min_fit < overall_best_fit
        overall_best_fit = min_fit;
        overall_best_ind = best_ind;
    end
end

% === Vykreslenie všetkých behov do jedného grafu ===
figure;
plot(1:gen_max, all_fitness_history', 'LineWidth', 1.5);
title('Konvergencia GA: Eggholder 10-D (Viac behov)');
xlabel('Počet generácií');
ylabel('Hodnota účelovej funkcie F(x)');
grid on;

% Vylepšená legenda s nastaveniami
nazvy_behov = arrayfun(@(x) sprintf('Beh %d', x), 1:num_runs, 'UniformOutput', false);
lgd = legend(nazvy_behov);
title(lgd, sprintf('Nastavenia GA:\nPopulácia: %d\nGenerácie: %d\nMutácia: %.2f', popsize, gen_max, mut_rate));

% === Výpis celkových výsledkov ===
fprintf('\n--- BONUS B: VÝSLEDKY OPTIMALIZÁCIE (zo všetkých %d behov) ---\n', num_runs);
fprintf('Nájdená globálna minimálna hodnota (fitness): %.4f\n', overall_best_fit); 
fprintf('Súradnice optimálneho jedinca (gény):\n');
disp(overall_best_ind);