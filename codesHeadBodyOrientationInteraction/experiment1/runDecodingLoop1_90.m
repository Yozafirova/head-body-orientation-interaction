clear all;
testName = 'A1-FCBC-180deg';
outFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\decodingMatlab\A1\decoding90\');
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
load('A1_M_250ms_degBFPos.mat');
train = {{'0_BC'}, {'45_BC'}, {'90_BC'}, {'135_BC'}, {'180_BC'}, {'225_BC'}, {'270_BC'}, {'315_BC'}};
test = {{'0_FC'}, {'45_FC'}, {'90_FC'}, {'135_FC'}, {'180_FC'}, {'225_FC'}, {'270_FC'}, {'315_FC'}};
% trainL = {{train{8} train{2}}, {train{2} train{4}}, {train{4} train{6}}, {train{6} train{8}}}; % 90 deg absolute diff
% testL = {{test{8} test{2}}, {test{2} test{4}}, {test{4} test{6}}, {test{6} test{8}}}; 
trainL = {{train{1} train{5}}, {train{2} train{6}}, {train{3} train{7}}, {train{4} train{8}}}; % 180 deg absolute diff
testL = {{test{1} test{5}}, {test{2} test{6}}, {test{3} test{7}}, {test{4} test{8}}};
vp = {'vp1', 'vp2', 'vp3', 'vp4', 'vp5', 'vp6', 'vp7', 'vp8'};
%%
for c = 1:size(trainL, 1)
    mValues = []; stdValues = [];
    for x = 1:size(trainL, 2)
        %     % for the BC2FC
        % trL1 = trainL{c, x}{1}; trL2 = trainL{c, x}{2};
        % testL1 = testL{c, x}{1}; testL2 = testL{c, x}{2};
        %    % for the FC2BC
        trL1 = testL{c, x}{1}; trL2 = testL{c, x}{2};
        testL1 = trainL{c, x}{1}; testL2 = trainL{c, x}{2};
    % %         % for the BC
    %     trL1 = trainL{c, x}{1}; trL2 = trainL{c, x}{2};
    %     testL1 = trainL{c, x}{1}; testL2 = trainL{c, x}{2};
    %         % for the FC
    %     trL1 = testL{c, x}{1}; trL2 = testL{c, x}{2};
    %     testL1 = testL{c, x}{1}; testL2 = testL{c, x}{2};
    for s = 1:100 % choose resampling number
        for a = 1:length(binnedData) % for each cell
            cellLbl = binnedLabels.degVp{a};
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
                cellLbl = binnedLabels.degVp{a};
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
    fig = figure; errorbar(mValues, stdValues*2, 'k', 'lineWidth', 1, 'capsize', 0);
    hold all
    set(gca, 'FontSize', 12, 'FontWeight','bold', 'yLim', [0.4, 1], 'yTick', [0.4:0.1:1], 'xLim', [0, 5], 'xTick', [1: 4], 'xticklabel', {xValues{:}});
    ylabel('Accuracy', 'FontSize', 12, 'FontWeight','bold');
    yline(0.5, '--');
    h = title([testName, '-', nm1{1}]);
    set(h, 'FontSize', 14, 'FontWeight', 'bold');
    figName1 = fullfile(outFolder, [testName, '.png']);
    figName2 = fullfile(outFolder, [testName, '.svg']);
    saveas(fig, figName1); saveas(fig, figName2);
    close all;
end

