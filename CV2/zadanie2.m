clc;
clear;

% === Nastavenie parametrov GA ===
dim = 10;                % Počet premenných (10-D úloha) 
popsize = 60;           % Veľkosť populácie
gen_max = 500;           % Maximálny počet generácií 
mut_rate = 0.1;          % Pravdepodobnosť mutácie 
Amp      = ones(1,dim);  % Amplituda pripocitania k muta (Tip: pre rozsah 2000 skús zväčšiť, napr. 50*ones...)
num_runs = 5;            % POČET BEHOV ALGORITMU (Nové)

% Matica ohraničení (Space) - 1. riadok dolné ohraničenia, 2. riadok horne
Space = [-1000 * ones(1, dim); 
          1000 * ones(1, dim)];

% Príprava premenných pre zber dát z viacerých behov
all_fitness_history = zeros(num_runs, gen_max); 
overall_best_fit = inf; % Na začiatku nastavíme "najhoršie" možné minimum
overall_best_ind = [];

% === Vonkajší cyklus pre viacero behov ===
for r = 1:num_runs
    fprintf('Spúšťam beh číslo %d...\n', r);
    
    % 1. Inicializácia počiat. populácie
    Pop = genrpop(popsize, Space); 
    best_fitness_history = zeros(1, gen_max);
    
    % === Hlavný cyklus GA (Generácie) ===
    for g = 1:gen_max
        
        % 2. Vyhodnotenie fitness 
        ObjV = zeros(1, popsize);
        for i = 1:popsize
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
        
        % 6. Nová populácia 
        Pop = MutpopA;
        Pop(1, :) = best_ind; 
        
    end
    
    % Po skončení behu uložíme jeho históriu do celkovej matice
    all_fitness_history(r, :) = best_fitness_history;
    
    % Ak sme v tomto behu našli lepšie globálne minimum, zapamätáme si ho
    if min_fit < overall_best_fit
        overall_best_fit = min_fit;
        overall_best_ind = best_ind;
    end
end


% === Vykreslenie všetkých behov do jedného grafu ===
figure(1);
plot(1:gen_max, all_fitness_history', 'LineWidth', 1.5); 
title('Priebeh fitness funkcie pre viaceré behy GA');
xlabel('Počet generácií');
ylabel('F(x)');
grid on;

% --- VYLEPŠENÁ LEGENDA S NASTAVENIAMI ---
% Vytvorenie zoznamu názvov (Beh 1, Beh 2...)
nazvy_behov = arrayfun(@(x) sprintf('Beh %d', x), 1:num_runs, 'UniformOutput', false);

% Vykreslenie legendy a uloženie jej objektu do premennej
lgd = legend(nazvy_behov);

% Pridanie nadpisu do legendy s aktuálnymi nastaveniami GA
title(lgd, sprintf('Nastavenia GA:\nPopulácia: %d\nGenerácie: %d\nMutácia: %.2f', popsize, gen_max, mut_rate));