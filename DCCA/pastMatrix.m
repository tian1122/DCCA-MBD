function [Mp, Mf] = pastMatrix(X, p, f, targetDimension)
    Mp = [];
    Mf = [];
    for k = 1: targetDimension + p
        if k >= p + 1
           mp = [];
           for i = p:-1:1
               mp = [mp X(k-i, :)];
           end
           Mp = [Mp; mp]; 
        end
        
        if k > f
           mf = [X(k, :)];
           for j = 1: f
               mf = [mf X(k + j, :)];
           end
            Mf = [Mf; mf]; 
        end
    end
end