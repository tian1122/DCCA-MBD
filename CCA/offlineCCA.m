function [A, B, r, R1, R2, train, UCL] = offlineCCA(CONFIG, X, Y, l)
    
    [A, B, r] = cca(X, Y);  % Columns of A and B are eigenvectors
    
    rt = r(1:l);
    At = A(:, 1:l);
    Bt = B(:, 1:l);
    
    S = diag(rt);
    
    Omega = S(1:rank(S),1:rank(S));
    trainT21 = [];
    trainT22 = [];
    train_r1 = [];
    train_r2 = [];
    
    tempinv = (eye(size(Omega,1)) - Omega^2); 
    tempi = diag(tempinv);
    Inv_s = inv(diag(tempi)/(CONFIG.samples-1));
    
    for j = 1:CONFIG.samples
        te1 = (X(j, :) * At)' - S * Bt' * Y(j, :)';
        train_r1 = [train_r1 te1];
        te2 = te1' * Inv_s * te1; % For T2 statistic       
        trainT21 = [trainT21 te2];
    end
    
    for j = 1:CONFIG.samples
        te12 = (Y(j, :) * Bt)' - S * At' * X(j, :)';
        train_r2 = [train_r2 te12];
        te22 = te12' * Inv_s * te12; % For T2 statistic      
        trainT22 = [trainT22 te22];
    end
    R1 = train_r1;
    R2 = train_r2;
    train = [trainT21; trainT22];
    UCL = [ksdensity(trainT21, 0.95, 'Function', 'icdf'); ksdensity(trainT22, 0.95, 'Function', 'icdf')];
end
