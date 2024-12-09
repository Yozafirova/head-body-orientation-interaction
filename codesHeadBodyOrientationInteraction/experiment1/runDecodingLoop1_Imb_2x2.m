clear all;
testName = 'A1-FC2-profile';  % 1 is 0x180 or 90x270 frontal (vp1 and vp5); 2 is 0x180 or 90x270 profile (vp3 and vp7); 
outFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\decodingMatlab\A1\decoding2x2\');
% tt = [1 5]; % 1, 5 0-180 frontal VP
tt = [7 3]; % 3, 7 90-270 profile VP
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
load('A1_M_250ms_degBFPos.mat');
train = {{'0_BC'}, {'45_BC'}, {'90_BC'}, {'135_BC'}, {'180_BC'}, {'225_BC'}, {'270_BC'}, {'315_BC'}};
test = {{'0_FC'}, {'45_FC'}, {'90_FC'}, {'135_FC'}, {'180_FC'}, {'225_FC'}, {'270_FC'}, {'315_FC'}};
trainL = {{train{1} train{2}}, {train{1} train{3}}, {train{1} train{4}}, {train{1} train{5}}, ...
    {train{1} train{6}}, {train{1} train{7}}, {train{1} train{8}}; ...
    {train{3} train{4}}, {train{3} train{5}}, {train{3} train{6}}, {train{3} train{7}}, ...
    {train{3} train{8}}, {train{3} train{1}}, {train{3} train{2}};
    {train{5} train{6}}, {train{5} train{7}}, {train{5} train{8}}, {train{5} train{1}}, ...
    {train{5} train{2}}, {train{5} train{3}}, {train{5} train{4}};
    {train{7} train{8}}, {train{7} train{1}}, {train{7} train{2}}, {train{7} train{3}}, ...
    {train{7} train{4}}, {train{7} train{5}}, {train{7} train{6}}};
testL = {{test{1} test{2}}, {test{1} test{3}}, {test{1} test{4}}, {test{1} test{5}}, ...
    {test{1} test{6}}, {test{1} test{7}}, {test{1} test{8}}; ...
    {test{3} test{4}}, {test{3} test{5}}, {test{3} test{6}}, {test{3} test{7}}, ...
    {test{3} test{8}}, {test{3} test{1}}, {test{3} test{2}};
    {test{5} test{6}}, {test{5} test{7}}, {test{5} test{8}}, {test{5} test{1}}, ...
    {test{5} test{2}}, {test{5} test{3}}, {test{5} test{4}};
    {test{7} test{8}}, {test{7} test{1}}, {test{7} test{2}}, {test{7} test{3}}, ...
    {test{7} test{4}}, {test{7} test{5}}, {test{7} test{6}}};
vp = {'vp1', 'vp2', 'vp3', 'vp4', 'vp5', 'vp6', 'vp7', 'vp8'};
% trainL = trainL(1, 4); % 0x180 HB ANGLE
% testL = testL(1, 4);
trainL = trainL(2, 4); % 90x270 HB ANGLE
testL = testL(2, 4);
%%
for c = 1:size(trainL, 1)
    mValues = []; stdValues = [];
    for x = 1:size(trainL, 2)
    %     % for the BC2FC
    % trL1 = trainL{c, x}{1}; trL2 = trainL{c, x}{2};
    % testL1 = testL{c, x}{1}; testL2 = testL{c, x}{2};
    %     % for the FC2BC
    % trL1 = testL{c, x}{1}; trL2 = testL{c, x}{2};
    % testL1 = trainL{c, x}{1}; testL2 = trainL{c, x}{2};
% %         % for the BC
%     trL1 = trainL{c, x}{1}; trL2 = trainL{c, x}{2};
%     testL1 = trainL{c, x}{1}; testL2 = trainL{c, x}{2};
%         % for the FC
    trL1 = testL{c, x}{1}; trL2 = testL{c, x}{2};
    testL1 = testL{c, x}{1}; testL2 = testL{c, x}{2};
    for s = 1:100 % choose resampling number
        for a = 1:length(binnedData) % for each cell
            cellLbl = binnedLabels.degVp{a};
            cond1 = cellLbl(:, strmatch(trL1, cellLbl));
            cond2 = cellLbl(:, strmatch(trL2, cellLbl));
            condA{a} = cond1(randperm(length(cond1))); condB{a} = cond2(randperm(length(cond2))); % shuffle  
            condAtest{a} = strrep(condA{a}, trL1, testL1); condBtest{a} = strrep(condB{a}, trL2, testL2); 
            % for 2x2
            for n = 1:numel(tt)
                rowsA{n} = find(contains(condA{a}, {vp{tt(n)}}));
                rowsB{n} = find(contains(condB{a}, {vp{tt(n)}}));
            end
            RA = cell2mat(rowsA); RB = cell2mat(rowsB);
            cellRowsA{a} = RA; cellRowsB{a} = RB;
            clear cellLbl;
        end
            %%
        for t = 1:8
            trNum = t:8:length(cellRowsA{1});
            for a = 1:length(cellRowsA)
                cellData = binnedData{a};
                cellLbl = binnedLabels.degVp{a};
                testTrA = cellRowsA{a}(trNum); testTrB = cellRowsB{a}(trNum); % condA{a}(testTrA)
                testLblA = condAtest{a}(testTrA); testLblB = condBtest{a}(testTrB);
                %
                [tf1, loc1] = ismember(cellLbl, testLblA); [tf3, loc3] = ismember(cellLbl, testLblB);
                [~, p1] = sort(loc1(tf1)); [~, p3] = sort(loc3(tf3));
                testLblAR = find(tf1); testLblBR = find(tf3);
                testLblAR = testLblAR(p1); testLblBR = testLblBR(p3);
                %
                trainTrA = setdiff(cellRowsA{a}, testTrA); trainTrB = setdiff(cellRowsB{a}, testTrB); % condA{a}(trainTrA); find(contains(trainLblA, 'vp1_4'))
                trainLblA = condA{a}(trainTrA); trainLblB = condB{a}(trainTrB);
                [tf2, loc2] = ismember(cellLbl, trainLblA); [tf4, loc4] = ismember(cellLbl, trainLblB);
                [~, p2] = sort(loc2(tf2)); [~, p4] = sort(loc4(tf4));
                trainLblAR = find(tf2); trainLblBR = find(tf4);
                trainLblAR = trainLblAR(p2); trainLblBR = trainLblBR(p4);
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
    % save(fileName, '-struct', 'str');
    
    xValues{x} = name;
    mValues = [mValues, accAll];
    stdValues = [stdValues, stdAll];
    end
%%     
%     fig = figure; errorbar(mValues, stdValues*2, 'k', 'lineWidth', 2); 
%     hold all
%     set(gca, 'FontSize', 12, 'FontWeight','bold', 'yLim', [0, 1], 'yTick', [0:0.1:1], 'xLim', [0, 4], 'xTick', [1: 3], 'xticklabel', {xValues{:}});
%     ylabel('Accuracy', 'FontSize', 12, 'FontWeight','bold');
%     yline(0.5, '--');
%     h = title([testName, '-', nm1{1}]);
%     set(h, 'FontSize', 14, 'FontWeight', 'bold');
%     figName = fullfile(outFolder, [testName, '_', nm1{1}, 'Ref.jpg']);
%     saveas(fig, figName);
%     close all;
end

