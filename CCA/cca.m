function [A_, B_, lambda] = cca(X, Y)

    % Step 1: Calculate covariance matrices
    n = size(X, 1); % Number of samples
    
    % Covariance matrices
    Cxx = (X' * X) / (n - 1);
    Cyy = (Y' * Y) / (n - 1);
    Cxy = (X' * Y) / (n - 1);
    Cyx = Cxy';

    % Step 2: Solve generalized eigenvalue problem
    [A, Dx] = eig(inv(Cxx) * Cxy * inv(Cyy) * Cyx);
    [k, idx] = sort(diag(Dx), 'descend');
    % Sort eigenvalues and eigenvectors
    lambda = sqrt(k(1:min(size(X, 2), size(Y, 2))));

    A_ = A(:, idx(1:min(size(X, 2), size(Y, 2))));
    
    % Calculate B
    B_ = inv(Cyy) * Cyx * A_;
end
