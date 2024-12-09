clear all;
decUnits = 230; % the min number of units per mon per site (M1A 233 units)
testName = 'A1-UP-460';
outFolder = ('E:\plexonData\nexData\VP\results\decoding\A1\decodingPerLocation\UP\');
str1 = load('OA1_250ms_degBFPos.mat');
str2 = load('NA1_250ms_degBFPos.mat');
lbl = unique(str1.binnedLabels.diffBFPos{1});
train = {{lbl{2}}, {lbl{8}}, {lbl{4}}, {lbl{6}}};
test = {{lbl{1}}, {lbl{7}}, {lbl{3}}, {lbl{5}}};
trainL = {{train{1} train{2}}, {train{1} train{3}}, {train{1} train{4}}; ...
    {train{2} train{3}}, {train{2} train{4}}, {train{2} train{1}}; ...
    {train{3} train{4}}, {train{3} train{1}}, {train{3} train{2}}; ...
    {train{4} train{1}}, {train{4} train{2}}, {train{4} train{3}}};
testL = {{test{1} test{2}}, {test{1} test{3}}, {test{1} test{4}}; ...
    {test{2} test{3}}, {test{2} test{4}}, {test{2} test{1}}; ...
    {test{3} test{4}}, {test{3} test{1}}, {test{3} test{2}}; ...
    {test{4} test{1}}, {test{4} test{2}}, {test{4} test{3}}};
vp = {'vp1', 'vp2', 'vp3', 'vp4', 'vp5', 'vp6', 'vp7', 'vp8'};
%%
for c = 1:size(trainL, 1)
    mValues = []; stdValues = [];
    for x = 1:size(trainL, 2)
%         % for the UP2INV
%     trL1 = trainL{c, x}{1}; trL2 = trainL{c, x}{2};
%     testL1 = testL{c, x}{1}; testL2 = testL{c, x}{2};
%         % for the INV2UP
%     trL1 = testL{c, x}{1}; trL2 = testL{c, x}{2};
%     testL1 = trainL{c, x}{1}; testL2 = trainL{c, x}{2};
        % for the UP
    trL1 = trainL{c, x}{1}; trL2 = trainL{c, x}{2};
    testL1 = trainL{c, x}{1}; testL2 = trainL{c, x}{2};
%      %   for the INV
%     trL1 = testL{c, x}{1}; trL2 = testL{c, x}{2};
%     testL1 = testL{c, x}{1}; testL2 = testL{c, x}{2};
 
    for s = 1:100 % choose resampling number
        ind1 = randperm(length(str1.binnedData), decUnits);
        ind2 = randperm(length(str2.binnedData), decUnits);
        sD1 = str1.binnedData(ind1);
        sL1 = str1.binnedLabels.degVp(ind1);
        sD2 = str2.binnedData(ind2);
        sL2 = str2.binnedLabels.degVp(ind2);
        binnedData = [sD1, sD2];
        binnedLabels = [sL1, sL2];
        for a = 1:length(binnedData) % for each cell
            cellLbl = binnedLabels{a};
            cond1 = cellLbl(:, strmatch(trL1, cellLbl));
            cond2 = cellLbl(:, strmatch(trL2, cellLbl));
            condA{a} = cond1(randperm(length(cond1))); condB{a} = cond2(randperm(length(cond2))); % shuffle  
            condAtest{a} = strrep(condA{a}, trL1, testL1); condBtest{a} = strrep(condB{a}, trL2, testL2); 
            for n = 1:length(vp)
                rowsA{n} = find(contains(condA{a}, vp{n}));
                rowsB{n} = find(contains(condB{a}, vp{n}));
            end
            RA = cell2mat(rowsA); RB = cell2mat(rowsB);
            cellRowsA{a} = RA; cellRowsB{a} = RB;
            clear cellLbl;
        end
        % condB{3}(cellRowsB{3})
        %%
        for t = 1:8
            trNum = t:8:length(cond1);
            for a = 1:length(cellRowsA)
                cellData = binnedData{a};
                cellLbl = binnedLabels{a};
                testTrA = cellRowsA{a}(trNum); testTrB = cellRowsB{a}(trNum); % condA{a}(testTrA)
                testLblA = condAtest{a}(testTrA); testLblB = condBtest{a}(testTrB);
                testLblAR = find(ismember(cellLbl, testLblA)); testLblBR = find(ismember(cellLbl, testLblB));
                trainTrA = setdiff(cellRowsA{a}, testTrA); trainTrB = setdiff(cellRowsB{a}, testTrB); % condA{a}(trainTrA); find(contains(trainLblA, 'vp1_4'))
                trainLblA = condA{a}(trainTrA); trainLblB = condB{a}(trainTrB);
                trainLblAR = find(ismember(cellLbl, trainLblA)); trainLblBR = find(ismember(cellLbl, trainLblB));
                %
                trainDataA{a} = cellData(trainLblAR); trainDataB{a} = cellData(trainLblBR);
                testDataA{a} = cellData(testLblAR); testDataB{a} = cellData(testLblBR);
            end
            trainDataALbl = repmat({extractBefore(trL1{:}, '_')}, 1, length(trainLblA)); 
            trainDataBLbl = repmat({extractBefore(trL2{:}, '_')}, 1, length(trainLblB));
            testDataALbl = repmat({extractBefore(testL1{:}, '_')}, 1, length(testLblA)); 
            testDataBLbl = repmat({extractBefore(testL2{:}, '_')}, 1, length(testLblB));
            trainData = [cell2mat(trainDataA); cell2mat(trainDataB)]; trainDataLbls = [trainDataALbl, trainDataBLbl];
            testData = [cell2mat(testDataA); cell2mat(testDataB)]; testDataLbls = [testDataALbl, testDataBLbl];
            Mdl = fitcsvm(trainData, trainDataLbls, 'standardize', true);
            predLbl = predict(Mdl, testData);
            accTr{t} = sum(cellfun(@strcmp, predLbl, testDataLbls'))/length(predLbl);
            mdlTr{t} = Mdl;
            clear trainData; clear testData; clear trainDataLbls; clear testDataLbls; 
        end
    accRs{s} = accTr;
    mdl{s} = mdlTr;
    meanAccRs{s} = mean(cell2mat(accTr));
    end
    accAll = mean(cell2mat(meanAccRs));
    stdAll = std(cell2mat(meanAccRs));
    str.accAll = accAll;
    str.stdAll = stdAll;
    str.accRs = accRs;
    str.meanAccRs = meanAccRs;
    str.mdl = mdl;
    nm1 = split(trainL{c, x}{1}, '_');
    nm2 = split(trainL{c, x}{2}, '_');
    name = [nm1{1}, 'x', nm2{1}];
    fileName = fullfile(outFolder, [testName '_' name]);
    save(fileName, '-struct', 'str');
    
    xValues{x} = name;
    mValues = [mValues, accAll];
    stdValues = [stdValues, stdAll];
    end
%%     
    fig = figure; errorbar(mValues, stdValues*2, 'k', 'lineWidth', 2); 
    hold all
    set(gca, 'FontSize', 12, 'FontWeight','bold', 'yLim', [0, 1], 'yTick', [0:0.1:1], 'xLim', [0, 4], 'xTick', [1:3], 'xticklabel', {xValues{:}});
    ylabel('Accuracy', 'FontSize', 12, 'FontWeight','bold');
    yline(0.5, '--');
    h = title([testName, '-', nm1{1}]);
    set(h, 'FontSize', 14, 'FontWeight', 'bold');
    figName1 = fullfile(outFolder, [testName, '_', nm1{1}, 'Ref.png']);
    figName2 = fullfile(outFolder, [testName, '_', nm1{1}, 'Ref.svg']);
    saveas(fig, figName1); saveas(fig, figName2); 
    close all;
end