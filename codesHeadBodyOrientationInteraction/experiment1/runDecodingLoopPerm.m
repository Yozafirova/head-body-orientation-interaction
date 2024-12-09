clear all;
testName = 'A1_BC2FC';
outFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\decodingMatlab\A1\binned\decoding\BC2FC\shuff\');
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
tr = {'1', '2', '3', '4', '5', '6', '7', '8'};
%%
for c = 1:size(trainL, 1)
    for x = 1:size(trainL, 2)
%         % for the BC2FC
        trL1 = trainL{c, x}{1}; trL2 = trainL{c, x}{2};
        testL1 = testL{c, x}{1}; testL2 = testL{c, x}{2};
    %         % for the FC2BC
    %     trL1 = testL{c, x}{1}; trL2 = testL{c, x}{2};
    %     testL1 = trainL{c, x}{1}; testL2 = trainL{c, x}{2};
    %         % for the BC
    %     trL1 = trainL{c, x}{1}; trL2 = trainL{c, x}{2};
    %     testL1 = trainL{c, x}{1}; testL2 = trainL{c, x}{2};
    %         % for the FC
%         trL1 = testL{c, x}{1}; trL2 = testL{c, x}{2};
%         testL1 = testL{c, x}{1}; testL2 = testL{c, x}{2};
        for shuffNum = 1:2
            for s = 1:5 % choose resampling number
                for a = 1:length(binnedData) % for each cell
                    cellLbl = binnedLabels.degVp{a};
                    cond1 = cellLbl(:, strmatch(trL1, cellLbl));
                    cond2 = cellLbl(:, strmatch(trL2, cellLbl));
                    condA{a} = cond1(randperm(length(cond1))); condB{a} = cond2(randperm(length(cond2))); % shuffle to break trial order
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
                    trainDataLbls = trainDataLbls(randperm(length(trainDataLbls))); % !!!!!!!!!! shuffle the training labels
                    testData = [cell2mat(testDataA); cell2mat(testDataB)]; testDataLbls = [testDataALbl, testDataBLbl];
                    Mdl = fitcsvm(trainData, trainDataLbls, 'standardize', true);
                    predLbl = predict(Mdl, testData);
                    accTr{t} = sum(cellfun(@strcmp, predLbl, testDataLbls'))/length(predLbl);
                    clear trainData; clear testData; clear trainDataLbls; clear testDataLbls; 
                end
            accRs{s} = accTr;
            meanAccRs{s} = mean(cell2mat(accTr));
            end
        accAll = mean(cell2mat(meanAccRs));
        stdAll = std(cell2mat(meanAccRs));
        str.accAll = accAll;
        str.stdAll = stdAll;
        str.accRs = accRs;
        str.meanAccRs = meanAccRs;
        nm1 = split(trainL{c, x}{1}, '_');
        nm2 = split(trainL{c, x}{2}, '_');
        name = [nm1{1}, 'x', nm2{1}];
        outFolderSh = ([outFolder, name, '\']);
        if ~exist(outFolderSh, 'dir')
            mkdir(outFolderSh);
        end
        fileName = fullfile(outFolderSh, [testName, '_' name, '_shuffRun_', num2str(shuffNum, '%03d')]);
        save(fileName, '-struct', 'str');
        end
    end
end


