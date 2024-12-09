clear all;
nexFolder = ('E:\plexonData\nexData\VP\sorted\');
nexFiles = dir([nexFolder, '*.nex5']);
matFolder = ('E:\plexonData\matData\VP\');
matFiles = dir([matFolder, '*.mat']);
addpath('J:\GBW-0280_Neuro_Backup\0009_Software\tnsmatlab\');
addpath(nexFolder); addpath(matFolder);
outFolder1 = ('E:\plexonData\nexData\VP\results\P1\decoding\');
outFolder2 = ('E:\plexonData\nexData\VP\results\P2\decoding\');
currChOrder = [31:-1:24 8:23]; currChOrder = cellstr(dec2base(currChOrder,10,3));
newChOrder = [1:24]; newChOrder = cellstr(dec2base(newChOrder,10,3));
trialNum = 8;
%%
for nx = 4:numel(nexFiles) % load mat and nex files
    nexData = nex.LoadAllNeurons(nexFolder, @(p) contains(p, nexFiles(nx).name)); % load the nex5 sorted file
    splitName = split(nexFiles(nx).name, '_'); % get the name to load mat with the same name
    matName = strjoin({splitName{1:3}}, '_');
    load(fullfile(matFolder, matName)); % load the mat file
    
    % create mat struct for correct answers only
    matData = []; 
    for s = 1:numel(tnsTrials)
        if [tnsTrials(s).Answer] == 1 || [tnsTrials(s).Answer] == 500 ...
                || [tnsTrials(s).Answer] == 1000
          matData = [matData, tnsTrials(s)];
        end
    end
    allNames = [matData(:).Stimul]';
    for c = 1:size(matData, 2)   % take only 8 trials per stimulus
        stimRows{c} = find(strcmp([matData.Stimul]', allNames{c}));
    end
    extraTr = []; % you need 8 trials exactly, so delete the excess
    for i = 1:length(stimRows)
        if length(stimRows{i}) > trialNum
            extraTr = [extraTr; stimRows{i}((trialNum+1):end)];
        elseif length(stimRows{i}) < trialNum
            sprintf('not enough trials')
            return
        end
    end
    matData(extraTr) = [];
    clear stimRows;
 %% % make the labels !!! IMPORTANT they have to be strings
    stim = [matData(:).Stimul]'; % take the names for the new data set, only 8 trials each
    stim = regexprep(stim,'B135_F270','B135_F225');
    for a = 1:numel(stim)
        ext = split(stim{a}, '.');
        stimNames{a} = (ext{1}); % without the extension
        nm = split(stimNames{a}, '_');
        stimType_all{a} = nm{4};
        stimLoc_all{a} = nm{5};
        stimPose_all{a} = nm{1};
        degB_all{a} = cell2mat(regexp(nm{2}, '\d*', 'match')); % the degrees for the NU coding
        degF_all{a} = cell2mat(regexp(nm{3}, '\d*', 'match'));
        degBF_all{a} = [cell2mat(degB_all(a)), '_', cell2mat(degF_all(a))];
    end
    dgB = str2double([degB_all]');
    dgF = str2double([degF_all]'); % replace degrees with numbers, solves the 0-360 problem
    dgNew = [1; 2; 3; 4; 5; 6; 7; 8];
    [dB, ~, iB] = unique(dgB);
    [dF, ~, iF] = unique(dgF);
    numB = dgNew(iB);
    numF = dgNew(iF);
    degBF = abs(numB-numF);
    dgBF = numB-numF;
    for n = 1:length(dgBF) % create NU label
        if dgBF(n) == 0
            diffBF_all{n} = '0';
        elseif dgBF(n) == -1 || dgBF(n) == 7
            diffBF_all{n} = '45';
        elseif dgBF(n) == -2 || dgBF(n) == 6
            diffBF_all{n} = '90';
        elseif dgBF(n) == -3 || dgBF(n) == 5
            diffBF_all{n} = '135';
        elseif dgBF(n) == -4 || dgBF(n) == 4
            diffBF_all{n} = '180';
        elseif dgBF(n) == -5 || dgBF(n) == 3
            diffBF_all{n} = '225';
        elseif dgBF(n) == -6 || dgBF(n) == 2
            diffBF_all{n} = '270';
        elseif dgBF(n) == -7 || dgBF(n) == 1
            diffBF_all{n} = '315';
        end
    end
    % create the structure for all labels; SPLIT THE POSES
    ind1all = find(contains(stimPose_all, 'P1')); ind2all = find(contains(stimPose_all, 'P2'));
    labelDataAll1 = {{stimNames(ind1all)}, {degB_all(ind1all)}, {degF_all(ind1all)}, {degBF_all(ind1all)}, {diffBF_all(ind1all)}, ...
        {stimType_all(ind1all)}, {stimLoc_all(ind1all)}, {stimPose_all(ind1all)}};
    labelDataAll2 = {{stimNames(ind2all)}, {degB_all(ind2all)}, {degF_all(ind2all)}, {degBF_all(ind2all)}, {diffBF_all(ind2all)}, ...
        {stimType_all(ind2all)}, {stimLoc_all(ind2all)}, {stimPose_all(ind2all)}};
    labelFieldsAll = {'stimNames_all', 'degB_all', 'degF_all', 'degBF_all', 'diffBF_all', 'stimType_all', 'stimLoc_all', 'stimPose_all'};
    mSAll1 = [labelFieldsAll; labelDataAll1]; mSAll2 = [labelFieldsAll; labelDataAll2];
    rasterLabels_all1 = struct(mSAll1{:}); rasterLabels_all2 = struct(mSAll2{:});
%% % create labels for the split data sets; monkeys only
    indM1 = find(contains(stimType_all, 'M') & contains(stimPose_all, 'P1'));
    indM2 = find(contains(stimType_all, 'M') & contains(stimPose_all, 'P2'));
    stimNames_M1 = stimNames(indM1); degB_M1 = degB_all(indM1); degF_M1 = degF_all(indM1); degBF_M1 = degBF_all(indM1); ...
        diffBF_M1 = diffBF_all(indM1); stimType_M1 = stimType_all(indM1); stimLoc_M1 = stimLoc_all(indM1); stimPose_M1 = stimPose_all(indM1);
    stimNames_M2 = stimNames(indM2); degB_M2 = degB_all(indM2); degF_M2 = degF_all(indM2); degBF_M2 = degBF_all(indM2); ...
        diffBF_M2 = diffBF_all(indM2); stimType_M2 = stimType_all(indM2); stimLoc_M2 = stimLoc_all(indM2); stimPose_M2 = stimPose_all(indM2);
    labelDataM1 = {{stimNames_M1}, {degB_M1}, {degF_M1}, {degBF_M1}, {diffBF_M1}, {stimType_M1}, {stimLoc_M1}, {stimPose_M1}};
    labelDataM2 = {{stimNames_M2}, {degB_M2}, {degF_M2}, {degBF_M2}, {diffBF_M2}, {stimType_M2}, {stimLoc_M2}, {stimPose_M2}};
    labelFieldsM = {'stimNames_M', 'degB_M', 'degF_M', 'degBF_M', 'diffBF_M', 'stimType_M', 'stimLoc_M', 'stimPose_M'};
    mSM1 = [labelFieldsM; labelDataM1]; mSM2 = [labelFieldsM; labelDataM2];
    rasterLabels_M1 = struct(mSM1{:}); rasterLabels_M2 = struct(mSM2{:});
%% % for the Up and and Inv
    indUp1 = find(contains(stimLoc_M1, 'up')); indInv1 = find(contains(stimLoc_M1, 'inv'));
    indUp2 = find(contains(stimLoc_M2, 'up')); indInv2 = find(contains(stimLoc_M2, 'inv'));
    stimNames_M1_up = stimNames_M1(indUp1); degB_M1_up = degB_M1(indUp1); degF_M1_up = degF_M1(indUp1); degBF_M1_up = degBF_M1(indUp1); ...
        diffBF_M1_up = diffBF_M1(indUp1); stimType_M1_up = stimType_M1(indUp1); stimPose_M1_up = stimPose_M1(indUp1); stimLoc_M1_up = stimLoc_M1(indUp1);
    stimNames_M1_inv = stimNames_M1(indInv1); degB_M1_inv = degB_M1(indInv1); degF_M1_inv = degF_M1(indInv1); degBF_M1_inv = degBF_M1(indInv1); ...
        diffBF_M1_inv = diffBF_M1(indInv1); stimType_M1_inv = stimType_M1(indInv1); stimPose_M1_inv = stimPose_M1(indInv1); stimLoc_M1_inv = stimLoc_M1(indInv1);
    stimNames_M2_up = stimNames_M2(indUp2); degB_M2_up = degB_M2(indUp2); degF_M2_up = degF_M2(indUp2); degBF_M2_up = degBF_M2(indUp2); ...
        diffBF_M2_up = diffBF_M2(indUp2); stimType_M2_up = stimType_M2(indUp2); stimPose_M2_up = stimPose_M2(indUp2); stimLoc_M2_up = stimLoc_M2(indUp2);
    stimNames_M2_inv = stimNames_M2(indInv2); degB_M2_inv = degB_M2(indInv2); degF_M2_inv = degF_M2(indInv2); degBF_M2_inv = degBF_M2(indInv2); ...
        diffBF_M2_inv = diffBF_M2(indInv2); stimType_M2_inv = stimType_M2(indInv2); stimPose_M2_inv = stimPose_M2(indInv2); stimLoc_M2_inv = stimLoc_M2(indInv2);   
    labelDataM1_up = {{stimNames_M1_up}, {degB_M1_up}, {degF_M1_up}, {degBF_M1_up}, {diffBF_M1_up}, {stimType_M1_up}, {stimPose_M1_up}, {stimLoc_M1_up}};
    labelDataM1_inv = {{stimNames_M1_inv}, {degB_M1_inv}, {degF_M1_inv}, {degBF_M1_inv}, {diffBF_M1_inv}, {stimType_M1_inv}, {stimPose_M1_inv}, {stimLoc_M1_inv}};
    labelDataM2_up = {{stimNames_M2_up}, {degB_M2_up}, {degF_M2_up}, {degBF_M2_up}, {diffBF_M2_up}, {stimType_M2_up}, {stimPose_M2_up}, {stimLoc_M2_up}};
    labelDataM2_inv = {{stimNames_M2_inv}, {degB_M2_inv}, {degF_M2_inv}, {degBF_M2_inv}, {diffBF_M2_inv}, {stimType_M2_inv}, {stimPose_M2_inv}, {stimLoc_M2_inv}};
    
    labelFieldsM_up = {'stimNames_M_up', 'degB_M_up', 'degF_M_up', 'degBF_M_up', 'diffBF_M_up', 'stimType_up', 'stimPose_M_up', 'stimLoc_M_up'};
    labelFieldsM_inv = {'stimNames_M_inv', 'degB_M_inv', 'degF_M_inv', 'degBF_M_inv', 'diffBF_M_inv', 'stimType_inv', 'stimPose_M_inv', 'stimLoc_M_inv'};
    mSMUp1 = [labelFieldsM_up; labelDataM1_up]; mSMInv1 = [labelFieldsM_inv; labelDataM1_inv];
    mSMUp2 = [labelFieldsM_up; labelDataM2_up]; mSMInv2 = [labelFieldsM_inv; labelDataM2_inv];
    rasterLabels_M1_up = struct(mSMUp1{:}); rasterLabels_M1_inv = struct(mSMInv1{:});
    rasterLabels_M2_up = struct(mSMUp2{:}); rasterLabels_M2_inv = struct(mSMInv2{:});
%% % get the data matrices; getting 200 before and 500-1 after stimulus onset; for all data
    photoEvents = cell2mat({matData.PhotoEvents}');
    baseline = round(mean(photoEvents(:, 2) - photoEvents(:, 1))) - 100; % 100 ms after start of fixation, 200 in this case
    afterOffset = round(mean(photoEvents(:, 4) - photoEvents(:, 3 ))) - 50; % 50 ms before end of trial, 250 in this case
    expo = round(mean(photoEvents(:, 3) - photoEvents(:, 2))); % exposition time as rounded mean difference of photoevents three and two, 250 in this case
    startTr = photoEvents(:, 2) - baseline; 
    stopTr = photoEvents(:, 3) + afterOffset;
    unitData = [];
    for i = 1:numel(nexData)
        for ii = 1:numel(matData)
            unitData(i).trials(ii).spikes = sync.ExtractSpikes(tnsData, intanData, nexData(i), startTr(ii), stopTr(ii));
        end
    end
    for u = 1:numel(unitData)
        for trial = 1:length(stimNames)
            myLength = (floor(photoEvents(trial, 2))-baseline):1:(floor(photoEvents(trial, 2))+expo+afterOffset-1);
            spikeMat = zeros(1, length(myLength));
            spikes = floor(unitData(u).trials(trial).spikes.timestamps);
            spikeRows = find(ismember(myLength, spikes));
            spikeMat(spikeRows) = 1;
            spikeMatAll{trial} = spikeMat;
        end
        spikeData_all = cell2mat(spikeMatAll');    
%         visualize
%         figure; imagesc(~spikeData_all); colormap gray ; saveas(figure,'a.png') 
        spikeData_all = cell2mat(spikeMatAll');
        spikeData1_all = spikeData_all(ind1all, :);
        spikeData2_all = spikeData_all(ind2all, :);
        spikeData_M1 = spikeData_all(indM1, :); spikeData_M1_up = spikeData_M1(indUp1, :); spikeData_M1_inv = spikeData_M1(indInv1, :);
        spikeData_M2 = spikeData_all(indM2, :); spikeData_M2_up = spikeData_M2(indUp2, :); spikeData_M2_inv = spikeData_M2(indInv2, :);
%% % create a structure name
        uName = nexData(u).name;
        chSplit = split(uName, '-');
        currNum = regexp(chSplit{2}, '\d*', 'match');
        currInd = find(contains(currChOrder, currNum));
        chName = newChOrder(currInd);
        unName = chSplit{2}(end);
        ss = ['ch' chName{:} unName];
        sName1 = [strjoin({splitName{1:2}}, '_'), '_P1'];
        sName2 = [strjoin({splitName{1:2}}, '_'), '_P2'];
        %%
        str1.(sName1).(ss).spikeData_all = spikeData1_all; str1.(sName1).(ss).spikeData_M = spikeData_M1; 
        str1.(sName1).(ss).spikeData_M_up = spikeData_M1_up; str1.(sName1).(ss).spikeData_M_inv = spikeData_M1_inv; 
        str1.(sName1).(ss).rasterLabels_all = rasterLabels_all1; str1.(sName1).(ss).rasterLabels_M = rasterLabels_M1;
        str1.(sName1).(ss).rasterLabels_M_up = rasterLabels_M1_up; str1.(sName1).(ss).rasterLabels_M_inv = rasterLabels_M1_inv;
    
        str2.(sName2).(ss).spikeData_all = spikeData2_all; str2.(sName2).(ss).spikeData_M = spikeData_M2; 
        str2.(sName2).(ss).spikeData_M_up = spikeData_M2_up; str2.(sName2).(ss).spikeData_M_inv = spikeData_M2_inv; 
        str2.(sName2).(ss).rasterLabels_all = rasterLabels_all2; str2.(sName2).(ss).rasterLabels_M = rasterLabels_M2;
        str2.(sName2).(ss).rasterLabels_M_up = rasterLabels_M2_up; str2.(sName2).(ss).rasterLabels_M_inv = rasterLabels_M2_inv;
    end
    newName1 = fullfile(outFolder1, [sName1, '_', 'DecStr.mat']);
    newName2 = fullfile(outFolder2, [sName2, '_', 'DecStr.mat']);
    %%
    %save
    save (newName1, '-struct', 'str1');
    save (newName2, '-struct', 'str2');
    clear str1; clear str2; 
end