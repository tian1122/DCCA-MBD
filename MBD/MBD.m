function Msed = MBD(Msd, M, k, s, Rstd)
    Msed = [];

    npu_std = [];
    for i = k: s + k - 1
        % Nqu baseline neighbor set
        % Npu neighbor set
        Nqu = Msd(i - k + 1: i, :);
        Npu = M(i - k + 1: i, :);
        NRst = Rstd(:, i - k + 1: i);
        for o = 1: size(Npu, 1)
            Npu(o, :) = Npu(o, :) / NRst(o);
        end
        Npu = abs(Npu);
        dsit = 0;
        for j = 1: size(Npu, 1)

            for t = 1: size(Npu, 2)
                dsit = dsit + (Npu(j, t) - Nqu(j, t))^2;
            end
        end
        
        npu_std = [npu_std, std(Npu(:))];
        msed = dsit / k;
        Msed = [Msed, msed];
    end
end