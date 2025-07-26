function [test_r1, test_r2] = onlineMBD(CONFIG, testX, testY, A, B, r)
    test_r1 = [];
    test_r2 = [];
    
    rt = r(1: CONFIG.lDCCA);
    S = diag(rt);

    At = A(:, 1: CONFIG.lDCCA);
    Bt = B(:, 1: CONFIG.lDCCA);

    for j = 1:CONFIG.samples + CONFIG.k_windows - 1
        te1 = (testX(j, :) * At)' - S * Bt' * testY(j, :)';
        test_r1 = [test_r1; te1'];
        
        te12 = (testY(j, :) * Bt)' - S * At' * testX(j, :)';
        test_r2 = [test_r2; te12'];
    end
end