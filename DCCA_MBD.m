clc;
close all;
clear;
addpath("CCA", "DCCA", "MBD", "CONFIG", "plots")
% Get system parameters dataPath, samples, faultTypeNum, tlag, obsIndex
CONFIG = config();
% Load data
load(CONFIG.dataPath);

MsdR1 = zeros(CONFIG.samples + CONFIG.k_windows - 1, CONFIG.lDCCA);
MsdR2 = zeros(CONFIG.samples + CONFIG.k_windows - 1, CONFIG.lDCCA);

for i = 1: CONFIG.batch
    % Select data
    X = Xtrain(:, 4 * (i - 1) + 1: 4 * i);
    Y = Ytrain(:, 3 * (i - 1) + 1: 3 * i);
    % Preserve observed data
    obsX = X;
    obsY = Y;
    
    [Xp, Xf] = pastMatrix(X, CONFIG.lag, CONFIG.lag, CONFIG.samples + CONFIG.tlag - 2 * CONFIG.lag + 10 + CONFIG.k_windows - 1);
    [Yp, Yf] = pastMatrix(Y, CONFIG.lag, CONFIG.lag, CONFIG.samples + CONFIG.tlag - 2 * CONFIG.lag + 10 + CONFIG.k_windows - 1);
    Z = [Yp Xp Xf];
    
    Z  = Z(CONFIG.tlag - CONFIG.lag: CONFIG.samples + CONFIG.tlag + CONFIG.k_windows  - CONFIG.lag, :);
    Yf = Yf(CONFIG.tlag - CONFIG.lag: CONFIG.samples + CONFIG.tlag + CONFIG.k_windows  - CONFIG.lag, :);
    % Remove mean and normalize
    meanX = mean(Z);
    meanY = mean(Yf);
    stdX = std(Z);
    stdY = std(Yf);
    Z = (Z - meanX) ./ stdX;  % No need to standardize in MATLAB
    Yf = (Yf - meanY) ./ stdY;
    
    [A, B, r, ~, ~, ~, ~] = offlineCCA(CONFIG, Z, Yf, CONFIG.lDCCA);

    rt = r(1:CONFIG.lDCCA);
    At = A(:, 1:CONFIG.lDCCA);
    Bt = B(:, 1:CONFIG.lDCCA);
    
    U = Z * At;
    V = Yf * Bt;
    
    S = diag(rt);
    train_r1 = [];
    train_r2 = [];
    
    for j = 1:CONFIG.samples + CONFIG.k_windows -1
        % Input direction
        te1 = (Z(j, :) * At)' - S * Bt' * Yf(j, :)';
        train_r1 = [train_r1; te1'];
        
        % Output direction
        te12 = (Yf(j, :) * Bt)' - S * At' * Z(j, :)';
        train_r2 = [train_r2; te12'];
    end

    R1(:, CONFIG.lDCCA * (i - 1) + 1: CONFIG.lDCCA * i) = train_r1;
    R2(:, CONFIG.lDCCA * (i - 1) + 1: CONFIG.lDCCA * i) = train_r2;
    % Calculate average baseline
    MsdR1 = MsdR1 + abs(train_r1);
    MsdR2 = MsdR2 + abs(train_r2);
end

MsdR1 = MsdR1 / batch;
MsdR2 = MsdR2 / batch;

% Model using the last data point
trainMBD1 = MBD(MsdR1, train_r1, CONFIG.k_windows, CONFIG.samples, std(R1'));
trainMBD2 = MBD(MsdR2, train_r2, CONFIG.k_windows, CONFIG.samples, std(R2'));

UCL = [ksdensity(trainMBD1, 0.95, 'Function', 'icdf'); ksdensity(trainMBD2, 0.95, 'Function', 'icdf')];

% Online detection
% Three fault types
faultX = [Xtf1, Xtf2, Xtf3];
faultY = [Ytf1, Ytf2, Ytf3];

h = [];
TEST = [];
for i = 1: CONFIG.faultTypeNum
    obsTestX = faultX(:, 4 * (i - 1) + 1: 4 * i);
    obsTestY = faultY(:, 3 * (i - 1) + 1: 3 * i);
    clear Xp Yp Xf Z Yp
    [Xp, Xf] = pastMatrix(obsTestX, CONFIG.lag, CONFIG.lag, CONFIG.samples + CONFIG.tlag - 2 * CONFIG.lag + 10 + CONFIG.k_windows - 1);
    [Yp, Yf] = pastMatrix(obsTestY, CONFIG.lag, CONFIG.lag, CONFIG.samples + CONFIG.tlag - 2 * CONFIG.lag + 10 + CONFIG.k_windows - 1);
    Z = [Yp Xp Xf];
    
    Z  = Z(CONFIG.tlag - CONFIG.lag: CONFIG.samples + CONFIG.tlag + CONFIG.k_windows  - CONFIG.lag, :);
    Yf = Yf(CONFIG.tlag - CONFIG.lag: CONFIG.samples + CONFIG.tlag + CONFIG.k_windows  - CONFIG.lag, :);

    % Remove mean and normalize
    Z = (Z - meanX) ./ stdX;  
    Yf = (Yf - meanY) ./ stdY;
    
    [test_r1, test_r2] = onlineMBD(CONFIG, Z, Yf, A, B, r);
    testMBD1 = MBD(MsdR1, test_r1, CONFIG.k_windows, CONFIG.samples, std(R1'));
    testMBD2 = MBD(MsdR2, test_r2, CONFIG.k_windows, CONFIG.samples, std(R2'));
    testMBD = [testMBD1; testMBD2];

    TEST = [TEST; [test_r1; test_r2]];
    % Plotting
    % Statistics plot
    h = [h; [statisticalPlot(CONFIG, trainMBD1, testMBD(1, :), trainMBD2, testMBD(2, :), UCL, ["MSED_1", "MSED_2", "fault " + i])]];
end
