function [TESTT2, test_r1, test_r2] = onlineCCA(CONFIG, testX, testY, A, B, r, l)
    testT21 = [];
    testT22 = [];
    test_r1 = [];
    test_r2 = [];

    rt = r(1: l);
    At = A(:, 1: l);
    Bt = B(:, 1: l);

    S = diag(rt);
    
    Omega = S(1:rank(S),1:rank(S));

    tempinv = (eye(size(Omega,1))-Omega^2); 
    tempi = diag(tempinv);
    Inv_s = inv(diag(tempi)/(CONFIG.samples-1));

    for j = 1:CONFIG.samples
        te1 = (testX(j, :) * At)' - S * Bt' * testY(j, :)';
        test_r1 = [test_r1 te1];
        te2 = te1'*Inv_s*te1; % for T2       
        testT21=[testT21 te2];
    end
    
    for j = 1:CONFIG.samples
        te12 = (testY(j, :) * Bt)' - S * At' * testX(j, :)';
        test_r2 = [test_r2 te12];
        te22 = te12'*Inv_s*te12; % for T2       
        testT22=[testT22 te22];
    end

    TESTT2 = [testT21; testT22];
end
