function [CONFIG] = config
    CONFIG.faultTypeNum = 3;
    CONFIG.tlag = 50;
    CONFIG.samples = 1200;
    CONFIG.dataPath = "./Data/linear.mat";
    CONFIG.faultStart = 600;
    CONFIG.obsIndex = [CONFIG.tlag + 1, CONFIG.samples + 50; CONFIG.tlag + 1, CONFIG.faultStart + CONFIG.tlag; CONFIG.faultStart + CONFIG.tlag + 1, CONFIG.samples + 50];
    CONFIG.faultNum = CONFIG.samples - CONFIG.faultStart;
    CONFIG.numVx = 4;
    CONFIG.numVy = 3;
    CONFIG.statisticalIndex = [1, CONFIG.samples; CONFIG.samples + 1 CONFIG.samples + CONFIG.faultStart; CONFIG.samples + CONFIG.faultStart + 1 2 * CONFIG.samples];
    CONFIG.lag = 3;
    CONFIG.lDCCA = 10;
    CONFIG.batch = 100;
    CONFIG.k_windows = 3;
end