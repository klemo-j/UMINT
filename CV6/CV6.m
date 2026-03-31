%% UMINT - Zadanie 6: Klasifikácia CTG dát (Tabuľkový výstup + Všetky grafy)
clc; clear; close all;


% 1. NAČÍTANIE DÁT

load('CTGdata.mat');
inputs = NDATA';               
targets = ind2vec(typ_ochorenia'); 


% 2. DEFINÍCIA ŠTRUKTÚR PRE TABUĽKU 1


struktury = { [30], [40], [30, 15] };
nazvy_M = {'M1', 'M2', 'M3'};

% Príprava dát pre Tabuľku 1 (Zladené s reálnymi štruktúrami!)
t1_data = {
    'M1', 1, '30',     500, 'Auto', 'Full';
    'M2', 1, '40',     500, 'Auto', 'Full';
    'M3', 2, '30, 15', 500, 'Auto', 'Full'
};

pocet_behov = 5;

% Príprava pamäte pre tabuľky a grafy
t2_data = cell(length(struktury) * pocet_behov, 6);
summary_data = cell(length(struktury), 5);

naj_net_struktury = cell(3, 1);
naj_tr_struktury = cell(3, 1);
naj_test_acc_v_strukture = zeros(3, 1);

absolutne_naj_net = [];
absolutne_naj_test_acc = 0;
row_idx = 1;

disp('Trénujem 15 sietí (Agresívny algoritmus). Prosím čakajte...');


% 3. TRÉNOVANIE A ZBER DÁT

for s = 1:length(struktury)
    
    acc_test_pole = zeros(1, pocet_behov);
    loss_test_pole = zeros(1, pocet_behov);
    
    for beh = 1:pocet_behov
        net = patternnet(struktury{s});
        
        net.divideParam.trainRatio = 0.60;
        net.divideParam.valRatio   = 0.20;
        net.divideParam.testRatio  = 0.20;
        
     
        net.trainFcn = 'trainlm';          
      
        
        net.trainParam.epochs = 500;      
        net.trainParam.max_fail = 20;      % 20 je pre trainlm výborná trpezlivosť
        net.trainParam.showWindow = false; 
        
        %trénovanie
        [net, tr] = train(net, inputs, targets);
        
        % Výpočet metrík pre TRAIN
        out_train = net(inputs(:, tr.trainInd));
        targ_train = targets(:, tr.trainInd);
        loss_train = perform(net, targ_train, out_train);
        [c_train, ~] = confusion(targ_train, out_train);
        acc_train = (1 - c_train) * 100;
        
        % Výpočet metrík pre TEST
        out_test = net(inputs(:, tr.testInd));
        targ_test = targets(:, tr.testInd);
        loss_test = perform(net, targ_test, out_test);
        [c_test, ~] = confusion(targ_test, out_test);
        acc_test = (1 - c_test) * 100;
        
        % Uloženie 
        acc_test_pole(beh) = acc_test;
        loss_test_pole(beh) = loss_test;
        
        % Zápis Tabuľky 2
        t2_data(row_idx, :) = {nazvy_M{s}, beh, round(loss_train,4), round(loss_test,4), round(acc_train,2), round(acc_test,2)};
        row_idx = row_idx + 1;
        
        % Zachovanie najlepšej siete 
        if acc_test > naj_test_acc_v_strukture(s)
            naj_test_acc_v_strukture(s) = acc_test;
            naj_net_struktury{s} = net;
            naj_tr_struktury{s} = tr;
        end
        
        %  ABSOLÚTNE NAJLEPŠEJ 
        if acc_test > absolutne_naj_test_acc
            absolutne_naj_test_acc = acc_test;
            absolutne_naj_net = net;
        end
    end
    
    % Výpoče Tabuľku 3
    min_acc = round(min(acc_test_pole), 2);
    max_acc = round(max(acc_test_pole), 2);
    priemer_acc = round(mean(acc_test_pole), 2);
    priemer_loss = round(mean(loss_test_pole), 4);
    
    summary_data(s, :) = {nazvy_M{s}, min_acc, max_acc, priemer_acc, priemer_loss};
end

clc; 


% 4. VYKRESLENIE TABULIEK 

% --- TABUĽKA 1 ---
fprintf('\n==========================================================\n');
fprintf('Tabulka 1: Architektura modelov a Hyperparametre\n');
fprintf('==========================================================\n');
T1 = cell2table(t1_data, 'VariableNames', {'Model', 'Skryte_vrstvy', 'Neurony', 'Epochy', 'LR', 'Batch'});
disp(T1);

% --- TABUĽKA 2 ---
fprintf('\n==========================================================\n');
fprintf('Tabulka 2: Detailne vysledky pre vsetkych 15 behov\n');
fprintf('==========================================================\n');
T2 = cell2table(t2_data, 'VariableNames', {'Model', 'Beh', 'Train_Loss', 'Test_Loss', 'Train_Acc', 'Test_Acc'});
disp(T2);

% --- TABUĽKA 3 ---
fprintf('\n==========================================================\n');
fprintf('Tabulka 3: Finalne porovnanie (Ciel: vsetko nad 92%%)\n');
fprintf('==========================================================\n');
T3 = cell2table(summary_data, 'VariableNames', {'Model', 'Min_Acc', 'Max_Acc', 'Priemer_Acc', 'Priemer_Loss'});
disp(T3);


% 5. DOPLNKOVÉ POŽIADAVKY ZADANIA (Senzitivita a Testovanie vzoriek)

fprintf('\n==========================================================\n');
fprintf('ANALYZA NAJLEPŠEJ SIETE (Senzitivita a Otestovanie vzoriek)\n');
fprintf('==========================================================\n');

outputs_best = absolutne_naj_net(inputs);
[~, cm] = confusion(targets, outputs_best); 
num_classes = size(cm, 1);
total_samples = sum(sum(cm));

for i = 1:num_classes
    TP = cm(i, i);                        
    FN = sum(cm(i, :)) - TP;              
    FP = sum(cm(:, i)) - TP;              
    TN = total_samples - (TP + FN + FP);  
    Senzitivita = (TP / (TP + FN)) * 100;
    Specificita = (TN / (TN + FP)) * 100;
    fprintf('Trieda %d -> Senzitivita: %5.2f%% | Specificita: %5.2f%%\n', i, Senzitivita, Specificita);
end

fprintf('\n--- Odhad 3 konkretnych vzoriek ---\n');
idx_tried = [find(typ_ochorenia == 1, 1), find(typ_ochorenia == 2, 1), find(typ_ochorenia == 3, 1)];
for i = 1:3
    idx = idx_tried(i);
    odhadnuta_trieda = vec2ind(absolutne_naj_net(inputs(:, idx)));
    fprintf('Vzorka zo skutocnej triedy %d bola sietou zaradena do: %d\n', i, odhadnuta_trieda);
end


% 6. VYKRESLENIE GRAFOV PRE NAJLEPŠIU SIEŤ Z KAŽDEJ ŠTRUKTÚRY

for s = 1:length(struktury)
    % Vykreslenie Confusion Matrix
    figure('Name', ['Confusion Matrix - Najlepšia sieť z modelu ' nazvy_M{s}]);
    plotconfusion(targets, naj_net_struktury{s}(inputs));
    title(['Kontingenčná matica - Model ' nazvy_M{s}]);
    
    % Vykreslenie Performance
    figure('Name', ['Performance - Najlepšia sieť z modelu ' nazvy_M{s}]);
    plotperform(naj_tr_struktury{s});
    title(['Priebeh trénovania - Model ' nazvy_M{s}]);
end
disp('Výpočet kompletne ukončený.');
