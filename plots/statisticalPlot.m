function h = statisticalPlot(CONFIG, trainT2, testT2, trainSPE, testSPE, UCL, text)
    %% Calculate detection rates
    testnum = size(testT2, 2) - CONFIG.faultNum;
    
    tdFalut1 = size(find(testT2(CONFIG.faultStart + 1: end) > UCL(1, :)), 2);
    tdFalut2 = size(find(testSPE(CONFIG.faultStart + 1: end) > UCL(2, :)), 2);
    
    FDR = [tdFalut1 / CONFIG.faultNum * 100; tdFalut2 / CONFIG.faultNum * 100]; % Fault Detection Rate (FDR)

    fdFalut1 = size(find(testT2(1: CONFIG.faultStart) > UCL(1, :)), 2);
    fdFalut2 = size(find(testSPE(1: CONFIG.faultStart) > UCL(2, :)), 2);
    
    FAR = [fdFalut1 / testnum * 100; fdFalut2 / testnum * 100]; % False Alarm Rate (FAR)

    h = figure;
    temp = [trainT2; trainSPE; testT2; testSPE];
    
    for i = 1: 2
        subplot(2, 1, i)
        plot(CONFIG.statisticalIndex(1, 1): CONFIG.statisticalIndex(1, 2), temp(i, :), 'bsquare');
        hold on
        plot(CONFIG.statisticalIndex(2, 1): CONFIG.statisticalIndex(2, 2), temp(i + 2, 1: CONFIG.faultStart), 'go');
        plot(CONFIG.statisticalIndex(3, 1): CONFIG.statisticalIndex(3, 2), temp(i + 2, CONFIG.faultStart + 1: end), 'rx');
        line([1, CONFIG.statisticalIndex(3, 2) + 50], [UCL(i, :), UCL(i, :)], 'color', '0.64,0.08,0.18', 'LineStyle', '--', 'LineWidth', 2)
        
        set(gca, 'YScale', 'log');
        ylabel(text(i))
        xlabel("Samples")
        title(text(3) + " Detection Rate: " + num2str(FDR(i)) + "%, False Alarm Rate: " + num2str(FAR(i)) + "%")
    end
    legend("Training data", "Validation data", "Fault data", "Threshold")
end
