%% UMINT - Zadanie 7: ČASŤ 2 - CNN Siete
clc; clear; close all;

volba_modelu = 1;    % Zmeň na 1, 2, alebo 3
volba_dropout = 0.7; % Zmeň na 0.0, 0.3, alebo 0.5 pre testovanie dropoutu

%% 1. NASTAVENIE CIEST A NAČÍTANIE DÁT
trainImgPath = 'MNIST_MATLAB/train/images.idx3-ubyte';
trainLblPath = 'MNIST_MATLAB/train/labels.idx1-ubyte';
testImgPath  = 'MNIST_MATLAB/test/images.idx3-ubyte';
testLblPath  = 'MNIST_MATLAB/test/labels.idx1-ubyte';

XTrainAll = loadMNISTImages(trainImgPath);
YTrainAll = categorical(loadMNISTLabels(trainLblPath));
XTest = loadMNISTImages(testImgPath);
YTest = categorical(loadMNISTLabels(testLblPath));

% Rozdelenie tréningových dát na Train (85%) a Validation (15%)
numTrain = size(XTrainAll, 4);
idx = randperm(numTrain);
splitIdx = floor(0.85 * numTrain);
XTrain = XTrainAll(:,:,:,idx(1:splitIdx));
YTrain = YTrainAll(idx(1:splitIdx));
XVal = XTrainAll(:,:,:,idx(splitIdx+1:end));
YVal = YTrainAll(idx(splitIdx+1:end));

%% 2. DEFINÍCIA ARCHITEKTÚRY (3 rôzne CNN modely - vylepšené)
if volba_modelu == 1
    layers = [
        imageInputLayer([28 28 1])
        convolution2dLayer(3, 32, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        maxPooling2dLayer(2, 'Stride', 2)
        convolution2dLayer(3, 64, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        maxPooling2dLayer(2, 'Stride', 2)
        fullyConnectedLayer(128)
        reluLayer()
        dropoutLayer(volba_dropout) 
        fullyConnectedLayer(10)
        softmaxLayer()
        classificationLayer()
    ];
    fprintf('Zvolená štruktúra: Ľahká CNN (2 vrstvy: 32-64 filtrov, 128 FC)\n');

elseif volba_modelu == 2
    layers = [
        imageInputLayer([28 28 1])
        convolution2dLayer(3, 32, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        convolution2dLayer(3, 32, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        maxPooling2dLayer(2, 'Stride', 2)
        convolution2dLayer(3, 64, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        maxPooling2dLayer(2, 'Stride', 2)
        fullyConnectedLayer(256)
        reluLayer()
        dropoutLayer(volba_dropout) 
        fullyConnectedLayer(10)
        softmaxLayer()
        classificationLayer()
    ];
    fprintf('Zvolená štruktúra: Stredná CNN (3 vrstvy: 32-32-64 filtrov, 256 FC)\n');

else
    layers = [
        imageInputLayer([28 28 1])
        convolution2dLayer(3, 32, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        convolution2dLayer(3, 32, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        maxPooling2dLayer(2, 'Stride', 2)
        convolution2dLayer(3, 64, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        convolution2dLayer(3, 64, 'Padding', 'same')
        batchNormalizationLayer()
        reluLayer()
        maxPooling2dLayer(2, 'Stride', 2)
        fullyConnectedLayer(512)
        reluLayer()
        dropoutLayer(volba_dropout) 
        fullyConnectedLayer(10)
        softmaxLayer()
        classificationLayer()
    ];
    fprintf('Zvolená štruktúra: Hlboká CNN (4 vrstvy: 32-32-64-64 filtrov, 512 FC)\n');
end

%% 3. NASTAVENIE TRÉNOVANIA
options = trainingOptions('adam', ...
    'MaxEpochs', 30, ...
    'MiniBatchSize', 128, ...
    'InitialLearnRate', 0.001, ...
    'ValidationData', {XVal, YVal}, ...
    'ValidationFrequency', 50, ...
    'ValidationPatience', 30, ...
    'Plots', 'training-progress', ...
    'Verbose', false, ...
    'ExecutionEnvironment', 'gpu'); % Zmeň na 'cpu' pre meranie času

%% 4. SPUSTENIE 5 OPAKOVANÍ
testAccuracies = zeros(5, 1);
overtrainEpochs = zeros(5, 1); 
tic; 

for i = 1:5
    fprintf('Spúšťam trénovanie behu č. %d/5...\n', i);
    
    [net, info] = trainNetwork(XTrain, YTrain, layers, options);
    
    % Zistenie epochy pretrénovania a Validation Loss
    valLosses = info.ValidationLoss(~isnan(info.ValidationLoss));
    if isempty(valLosses)
        minEpoch = options.MaxEpochs;
        bestValLoss = NaN;
    else
        [bestValLoss, minEpoch] = min(valLosses); 
    end
    overtrainEpochs(i) = minEpoch;
    
    % Extrakcia Training Loss
    trainLoss = info.TrainingLoss(end); 
    
    % Klasifikácia TRÉNOVACÍCH dát
    YPredTrain = classify(net, XTrain);
    trainAcc = sum(YPredTrain == YTrain)/numel(YTrain) * 100;
    
    % Klasifikácia TESTOVACÍCH dát
    YPred = classify(net, XTest);
    testAccuracies(i) = sum(YPred == YTest)/numel(YTest) * 100;
    
    % Výpis pre PDF Tabuľky
    fprintf('Beh %d | Train Loss: %.4f | Val/Test Loss: %.4f | Train Acc: %.2f%% | Test Acc: %.2f%% | Overtrain Ep: %d\n', ...
        i, trainLoss, bestValLoss, trainAcc, testAccuracies(i), minEpoch);
end
totalTime = toc;

%% 5. VYHODNOTENIE
fprintf('\n--- VÝSLEDKY CNN ---\n');
fprintf('Priemerná úspešnosť: %.2f%%\n', mean(testAccuracies));
fprintf('Minimálna úspešnosť: %.2f%%\n', min(testAccuracies));
fprintf('Maximálna úspešnosť: %.2f%%\n', max(testAccuracies));
fprintf('Priemerný bod pretrénovania: %.1f. iterácia\n', mean(overtrainEpochs));
fprintf('Celkový čas (5 behov): %.2f sekúnd\n', totalTime);

% Kontingenčná matica
figure('Name', 'CNN Matica Zamen');
plotconfusion(YTest, YPred, 'Finálna CNN');

% Vizualizácia 10 číslic
figure('Name', 'CNN Ukážky klasifikácie (0-9)');
triedy = categories(YTest);
for i = 1:10
    idx = find(YTest == triedy{i}, 1); 
    subplot(2,5,i); 
    imshow(XTest(:,:,:,idx));
    title(sprintf('Real: %c | Odhad: %c', char(YTest(idx)), char(YPred(idx))));
end

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