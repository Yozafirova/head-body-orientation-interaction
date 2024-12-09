clear all;
decUnits = 30; 
testName1 = 'P1-0-60-UP-1000';
testName2 = 'P1-0-60-INV-1000';
outFolder = ('E:\plexonData\nexData\VP\results\decoding\A1\decoding0x8\decodingResults\');
str1 = load('OA2_250ms_degBFPos.mat');
str2 = load('NA2_250ms_degBFPos.mat');
lbl = unique(str1.binnedLabels.diffBFPos{1});
trainL = {'0_up_vp1', '0_up_vp2', '0_up_vp3', '0_up_vp4', '0_up_vp5', '0_up_vp6' ...
    '0_up_vp7', '0_up_vp8'}; 
testL = {'0_inv_vp1', '0_inv_vp2', '0_inv_vp3', '0_inv_vp4', '0_inv_vp5', '0_inv_vp6' ...
    '0_inv_vp7', '0_inv_vp8'}; 
vp = {'vp1', 'vp2', 'vp3', 'vp4', 'vp5', 'vp6', 'vp7', 'vp8'};
%%
mValuesA = []; stdValuesA = []; mValuesB = []; stdValuesB = [];
    % for the UP
trL1 = trainL;
     %   for the INV
ttL1 = testL;
%%
for s = 1:1000 % choose resampling number
    ind1 = randperm(length(str1.binnedData), decUnits);
    ind2 = randperm(length(str2.binnedData), decUnits);
    sD1 = str1.binnedData(ind1);
    sL1 = str1.binnedLabels.degVp(ind1);
    sL1Tr = str1.binnedLabels.degVpTr(ind1);
    sD2 = str2.binnedData(ind2);
    sL2 = str2.binnedLabels.degVp(ind2);
    sL2Tr = str2.binnedLabels.degVpTr(ind2);
    binnedData = [sD1, sD2];
    binnedLabels = [sL1, sL2];
    binnedLabelsTr = [sL1Tr, sL2Tr];
    for a = 1:length(binnedData) % for each cell
        cellLbl = binnedLabels{a};
        cellLblTr = binnedLabelsTr{a};
        condInd1 = find(ismember(cellLbl, trL1));
        condInd2 = find(ismember(cellLbl, ttL1));
        cond1 = cellLblTr(condInd1);
        cond2 = cellLblTr(condInd2);
        ind = randperm(length(cond1));
        condR1 = cond1(ind); 
        condR2 = cond2(ind); 
        for n = 1:length(vp)
            rowsA{n} = find(contains(condR1, vp{n}));
            rowsB{n} = find(contains(condR2, vp{n}));
        end
        condA{a} = condR1(cell2mat(rowsA));
        condB{a} = condR2(cell2mat(rowsB));
    end
    % condB{3}(cellRowsB{3})
    %%
    for t = 1:8
        trNum = t:8:length(cond1);
        testNum = setdiff(1:length(cond1), trNum);
        for a = 1:length(condA)
            cellData = binnedData{a};
            cellLblTr = binnedLabelsTr{a};
            testTrA = condA{a}(trNum); testTrB = condB{a}(trNum);
            [tf1, loc1] = ismember(cellLblTr, testTrA);
            [tf3, loc3] = ismember(cellLblTr, testTrB);
            [~, p1] = sort(loc1(tf1)); [~, p3] = sort(loc3(tf3));
            testLblAR = find(tf1); testLblBR = find(tf3);
            testLblAR = testLblAR(p1); testLblBR = testLblBR(p3);
            
            trainTrA = condA{a}(testNum); trainTrB = condB{a}(testNum);
            [tf2, loc2] = ismember(cellLblTr, trainTrA);
            [tf4, loc4] = ismember(cellLblTr, trainTrB);
            [~, p2] = sort(loc2(tf2)); [~, p4] = sort(loc4(tf4));
            trainLblAR = find(tf2); trainLblBR = find(tf4);
            trainLblAR = trainLblAR(p2); trainLblBR = trainLblBR(p4);
            
            trainDataA{a} = cellData(trainLblAR); trainDataB{a} = cellData(trainLblBR);
            testDataA{a} = cellData(testLblAR); testDataB{a} = cellData(testLblBR);
        end
        trainDataALbl = repelem(vp, numel(trainTrA)/numel(vp));
        testDataALbl = vp; 
        trainDataA = cell2mat(trainDataA); trainDataB = cell2mat(trainDataB);
        trainDataLbls = trainDataALbl';
        testDataA = cell2mat(testDataA); testDataB = cell2mat(testDataB);
        testDataLbls = testDataALbl';
        tt = templateSVM('standardize', true, 'KernelFunction', 'linear', 'BoxConstraint', 1);
        
        MdlA = fitcecoc(trainDataA, trainDataLbls, 'Learners', tt);
        MdlB = fitcecoc(trainDataB, trainDataLbls, 'Learners', tt);
        predLblA = predict(MdlA, testDataA);
        predLblB = predict(MdlB, testDataB);
        accTrA{t} = cellfun(@strcmp, predLblA, testDataLbls);
        accTrB{t} = cellfun(@strcmp, predLblB, testDataLbls);
        mdlTrA{t} = MdlA; mdlTrB{t} = MdlB;
        clear trainDataA; clear testDataA; clear trainDataB; clear testDataB; clear trainDataLbls; clear testDataLbls; 
    end
accRsA{s} = accTrA;
mdlA{s} = mdlTrA;
meanAccRsA{s} = mean(cell2mat(accTrA), 2);
accRsB{s} = accTrB;
mdlB{s} = mdlTrB;
meanAccRsB{s} = mean(cell2mat(accTrB), 2);
end
% accAllA = mean(cell2mat(meanAccRsA), 2)';
% stdAllA = std(cell2mat(meanAccRsA), 0, 2)';
% accAllB = mean(cell2mat(meanAccRsB), 2)';
% stdAllB = std(cell2mat(meanAccRsB), 0, 2)';
% 
% str3.accAll = accAllA;
% str3.stdAll = stdAllA;
% str3.accRs = accRsA;
% str3.meanAccRs = meanAccRsA;
% str3.mdl = mdlA;
% str4.accAll = accAllB;
% str4.stdAll = stdAllB;
% str4.accRs = accRsB;
% str4.meanAccRs = meanAccRsB;
% str4.mdl = mdlB;
% name = vp;
% fileName1 = fullfile(outFolder, testName1);
% fileName2 = fullfile(outFolder, testName2);
% save(fileName1, '-struct', 'str3');
% save(fileName2, '-struct', 'str4');

% mValuesA = [mValuesA, accAllA]; mValuesB = [mValuesB, accAllB];
% stdValuesA = [stdValuesA, stdAllA]; stdValuesB = [stdValuesB, stdAllB];
%%     
% fig1 = figure; errorbar(mValuesA, stdValuesA*2, 'k', 'lineWidth', 2); 
% hold all
% set(gca, 'FontSize', 12, 'FontWeight','bold', 'yLim', [0, 1], 'yTick', [0:0.1:1], 'xLim', [0, 9], 'xTick', [1:8], 'xticklabel', vp);
% ylabel('Accuracy', 'FontSize', 12, 'FontWeight','bold');
% yline(0.125, '--');
% h = title(testName1);
% set(h, 'FontSize', 14, 'FontWeight', 'bold');
% figName1 = fullfile(outFolder, [testName1 '.png']);
% figName2 = fullfile(outFolder, [testName1 '.svg']);
% saveas(fig1, figName1); saveas(fig1, figName2); 
% 
% fig2 = figure; errorbar(mValuesB, stdValuesB*2, 'k', 'lineWidth', 2); 
% hold all
% set(gca, 'FontSize', 12, 'FontWeight','bold', 'yLim', [0, 1], 'yTick', [0:0.1:1], 'xLim', [0, 9], 'xTick', [1:8], 'xticklabel', vp);
% ylabel('Accuracy', 'FontSize', 12, 'FontWeight','bold');
% yline(0.125, '--');
% h = title(testName2);
% set(h, 'FontSize', 14, 'FontWeight', 'bold');
% figName3 = fullfile(outFolder, [testName2 '.png']);
% figName4 = fullfile(outFolder, [testName2 '.svg']);
% saveas(fig2, figName3); saveas(fig2, figName4); 

% close all;
