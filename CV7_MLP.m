%% UMINT - Zadanie 7: ČASŤ 1 - MLP Siete (cez patternnet)
clc; clear; close all;

volba_modelu = 1; % Nastavené na 2 pre tvoj posledný beh!

%% 1. NASTAVENIE CIEST A NAČÍTANIE DÁT
trainImgPath = 'MNIST_MATLAB/train/images.idx3-ubyte';
trainLblPath = 'MNIST_MATLAB/train/labels.idx1-ubyte';
testImgPath  = 'MNIST_MATLAB/test/images.idx3-ubyte';
testLblPath  = 'MNIST_MATLAB/test/labels.idx1-ubyte';

XTrainAll = loadMNISTImages(trainImgPath); 
YTrainAll = loadMNISTLabels(trainLblPath); 
XTestAll  = loadMNISTImages(testImgPath);
YTestAll  = loadMNISTLabels(testLblPath);

XTrain_flat = reshape(XTrainAll, [28*28, size(XTrainAll, 4)]);
XTest_flat  = reshape(XTestAll, [28*28, size(XTestAll, 4)]);

YTrain_oh = full(ind2vec(YTrainAll' + 1)); 
YTest_oh  = full(ind2vec(YTestAll' + 1));

%% 2. DEFINÍCIA ARCHITEKTÚRY
if volba_modelu == 1
    pocet_neuronov = 128; 
    fprintf('Zvolená štruktúra: MLP 1 (1 skrytá vrstva: 128 neurónov)\n');
else
    pocet_neuronov = [256, 128]; 
    fprintf('Zvolená štruktúra: MLP 2 (2 skryté vrstvy: 256 a 128 neurónov)\n');
end

%% 3. SPUSTENIE 5 OPAKOVANÍ (TRÉNOVANIE)
testAccuracies = zeros(5, 1);
tic; 

for i = 1:5
    fprintf('Spúšťam trénovanie behu č. %d/5...\n', i);
    
    net = patternnet(pocet_neuronov);
    
    net.divideFcn = 'dividerand';
    net.divideParam.trainRatio = 0.85;
    net.divideParam.valRatio   = 0.15;
    net.divideParam.testRatio  = 0;
    
    net.trainParam.goal = 0.000001;     
    net.trainParam.show = 20;           
    net.trainParam.epochs = 100;        
    net.trainParam.max_fail = 12;       
    net.trainParam.showWindow = false;  
    
    [net, tr] = train(net, XTrain_flat, YTrain_oh);
    
    trainLoss = tr.best_perf;  
    valLoss = tr.best_vperf;   
    
    YPredTrain_oh = net(XTrain_flat);
    YPredTrain = vec2ind(YPredTrain_oh) - 1;
    trainAcc = sum(YPredTrain == YTrainAll') / numel(YTrainAll) * 100;
    
    YPred_oh = net(XTest_flat);
    YPred = vec2ind(YPred_oh) - 1;
    testAccuracies(i) = sum(YPred == YTestAll') / numel(YTestAll) * 100;
    
    fprintf('Beh %d | Train Loss: %.4f | Val/Test Loss: %.4f | Train Acc: %.2f%% | Test Acc: %.2f%%\n', ...
        i, trainLoss, valLoss, trainAcc, testAccuracies(i));
end
totalTime = toc;

%% 4. VYHODNOTENIE A NATVRDO VYKRESLENIE GRAFOV
fprintf('\n--- VÝSLEDKY MLP ---\n');
fprintf('Priemerná úspešnosť: %.2f%%\n', mean(testAccuracies));
fprintf('Minimálna úspešnosť: %.2f%%\n', min(testAccuracies));
fprintf('Maximálna úspešnosť: %.2f%%\n', max(testAccuracies));
fprintf('Celkový čas (5 behov): %.2f sekúnd\n', totalTime);

% Vynútené zobrazenie Loss grafu
figure('Name', 'Priebeh učenia MLP (Loss)', 'Visible', 'on');
plotperform(tr);
drawnow;

% Vynútené zobrazenie Matice zámen
figure('Name', 'MLP Matica Zamen', 'Visible', 'on');
plotconfusion(YTest_oh, YPred_oh, 'Finálna MLP matica');
drawnow;

% Vynútené zobrazenie Obrázkov
figure('Name', 'MLP Ukážky klasifikácie (0-9)', 'Visible', 'on');
for i = 1:10
    idx = find(YTestAll == (i-1), 1); 
    subplot(2,5,i); 
    imshow(XTestAll(:,:,:,idx));
    title(sprintf('Real: %d | Odhad: %d', i-1, YPred(idx)));
end
drawnow;

%% POMOCNÉ FUNKCIE PRE NAČÍTANIE MNIST
function images = loadMNISTImages(filename)
    fp = fopen(filename, 'rb');
    if fp == -1, error('Súbor neexistuje!'); end
    fread(fp, 1, 'int32', 0, 'ieee-be'); 
    numImages = fread(fp, 1, 'int32', 0, 'ieee-be');
    numRows = fread(fp, 1, 'int32', 0, 'ieee-be');
    numCols = fread(fp, 1, 'int32', 0, 'ieee-be');
    raw_data = fread(fp, inf, 'unsigned char');
    fclose(fp);
    images = reshape(raw_data, [numCols, numRows, 1, numImages]);
    images = permute(images, [2, 1, 3, 4]); 
    images = double(images) / 255; 
end

function labels = loadMNISTLabels(filename)
    fp = fopen(filename, 'rb');
    if fp == -1, error('Súbor neexistuje!'); end
    fread(fp, 1, 'int32', 0, 'ieee-be'); 
    fread(fp, 1, 'int32', 0, 'ieee-be'); 
    labels = fread(fp, inf, 'unsigned char');
    fclose(fp);
end