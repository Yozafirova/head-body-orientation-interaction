clear all;
baseline = 20; 
latency = 5; % 50 ms latency
stimWin = 25; % 250 stim duration
outFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\corr\corrected100rs\');
fname1 = 'corr_an1.mat'; fname2 = 'corr_an2.mat'; fname3 = 'corr_pn1.mat'; fname4 = 'corr_pn2.mat';
fname5 = 'corr_ao1.mat'; fname6 = 'corr_ao2.mat'; fname7 = 'corr_po1.mat'; fname8 = 'corr_po2.mat';
fname = {fname1, fname2, fname3, fname4, fname5, fname6, fname7, fname8};
dataDir1 = ('C:\Users\u0137276\Desktop\epDATA\expVP\Nacho\asb\VP1\resultsVP1\');
dataDir2 = ('C:\Users\u0137276\Desktop\epDATA\expVP\Nacho\asb\VP2\resultsVP2\');
dataDir3 = ('C:\Users\u0137276\Desktop\epDATA\expVP\Nacho\msb\VP1\resultsVP1\');
dataDir4 = ('C:\Users\u0137276\Desktop\epDATA\expVP\Nacho\msb\VP2\resultsVP2\');
dataDir5 = ('C:\Users\u0137276\Desktop\epDATA\expVP\Odin\asb\VP1\resultsVP1\');
dataDir6 = ('C:\Users\u0137276\Desktop\epDATA\expVP\Odin\asb\VP2\resultsVP2\');
dataDir7 = ('C:\Users\u0137276\Desktop\epDATA\expVP\Odin\msb\VP1\resultsVP1\');
dataDir8 = ('C:\Users\u0137276\Desktop\epDATA\expVP\Odin\msb\VP2\resultsVP2\');
dataDirAll = {dataDir1, dataDir2, dataDir3, dataDir4, dataDir5, dataDir6, dataDir7, dataDir8};
%%
for s = 1:numel(dataDirAll)
    addpath(dataDirAll{s});
    dataDir = dataDirAll{s};
    filesBC = dir([dataDir, '*StrBC_*.mat']);
    filesListBC = {filesBC.name}; % take the names of the files
    nBC = regexp(filesListBC, '\d*', 'match'); % take the number from the name into cell array
    for a = 1:length(nBC)
        numBC{a} = nBC{a}(2);
    end
    outBC = str2double(cat(1, numBC{:})); % take the numbers only
    [~, indBC] = sort(outBC); % sort the numbers and take the index
    filesBC = filesBC(indBC); % sort the file list according to index

    filesFC = dir([dataDir, '*StrFC_*.mat']);
    filesListFC = {filesFC.name}; % take the names of the files
    nFC = regexp(filesListFC, '\d*', 'match'); % take the number from the name into cell array
    for a = 1:length(nFC)
        numFC{a} = nFC{a}(2);
    end
    outFC = str2double(cat(1, numFC{:})); % take the numbers only
    [~, indFC] = sort(outFC); % sort the numbers and take the index
    filesFC = filesFC(indFC); % sort the file list according to index

    cellNumBC = length(filesBC);
    cellNumFC = length(filesFC);
    clear numBC; clear numFC; 
    bCells = []; fCells = [];
    for p = 1:cellNumBC
        spl1 = split(filesBC(p).name, '_');
        spl2 = split(spl1(2), '.');
        nmB = regexp(spl2, '\d*', 'match');
        nB = cell2mat(nmB{1});
        bCells = [bCells; str2num(nB)];  
    end
    for p = 1:cellNumFC
        spl1 = split(filesFC(p).name, '_');
        spl2 = split(spl1(2), '.');
        nmF = regexp(spl2, '\d*', 'match');
        nF = cell2mat(nmF{1});
        fCells = [fCells; str2num(nF)];  
    end
    bfCells = intersect(bCells, fCells);

    for p = 1:cellNumBC
        spl1 = split(filesBC(p).name, '_');
        spl2 = split(spl1(2), '.');
        nmB = regexp(spl2, '\d*', 'match');
        nB = str2num(cell2mat(nmB{1}));
        if ismember(nB, bfCells)
            sharedBC{p} = filesBC(p).name;
        end
    end
    for p = 1:cellNumFC
        spl1 = split(filesFC(p).name, '_');
        spl2 = split(spl1(2), '.');
        nmF = regexp(spl2, '\d*', 'match');
        nF = str2num(cell2mat(nmF{1}));
        if ismember(nF, bfCells)
            sharedFC{p} = filesFC(p).name;
        end
    end
    sharedBC = sharedBC';
    sharedFC = sharedFC';
    sharedBC =  sharedBC(~cellfun('isempty', sharedBC));
    sharedFC =  sharedFC(~cellfun('isempty', sharedFC));
    %%
    corrR = []; corrP = []; corrBRsb = []; corrFRsb = []; corrRcorrected = [];
    bResp = []; fResp = []; bRespOdd = []; fRespOdd = []; bRespEv = []; fRespEv = []; 
    for a = 1:length(bfCells)
        bc = load(sharedBC{a});
        fc = load(sharedFC{a});
        respB = bc.strBC.binMeanTrialFR;
        respF = fc.strFC.binMeanTrialFR;
        respBTr = bc.strBC.binAllTrialsFR;
        respFTr = fc.strFC.binAllTrialsFR;

        cond = length(respB); tr = size(respBTr{1}, 1);
        % for the corr!!
        for ii = 1:cond
            SWBc{ii} = respB{ii}(1, (baseline+latency+1):(baseline+latency+stimWin)); %  resp win, add one for the zero problem
            mSWBc{ii} = mean(SWBc{ii});
            SWFc{ii} = respF{ii}(1, (baseline+latency+1):(baseline+latency+stimWin)); %  resp win, add one for the zero problem
            mSWFc{ii} = mean(SWFc{ii});
            for tt = 1:tr
                SWBTr = respBTr{ii}(:, (baseline+latency+1):(baseline+latency+stimWin)); %  resp win, add one for the zero problem
                mSWBTr = mean(SWBTr, 2);
                SWFTr = respFTr{ii}(:, (baseline+latency+1):(baseline+latency+stimWin)); %  resp win, add one for the zero problem
                mSWFTr = mean(SWFTr, 2);
            end
            mSWBcTr{ii} = mSWBTr;
            mSWFcTr{ii} = mSWFTr;
        end

        [cR, cP] = corr(cell2mat(mSWBc)', cell2mat(mSWFc)');
        corrR = [corrR; cR]; corrP = [corrP; cP]; 
        bResp = [bResp; mSWBc]; fResp = [fResp; mSWFc]; 
        % reliability correction
        % split tr odd even, get mean resp;
        corrBR100sb = []; corrFR100sb = [];
        for r = 1:100
            trB1 = []; trB2 = []; trF1 = []; trF2 = [];
            ind = randperm(tr);
            for c = 1:cond
                trB = mSWBcTr{c}(ind);
                trF = mSWFcTr{c}(ind);
                trBa = mean(trB(1:2:tr));
                trBb = mean(trB(2:2:tr));
                trFa = mean(trF(1:2:tr));
                trFb = mean(trF(2:2:tr));
                trB1 = [trB1; trBa]; trB2 = [trB2; trBb]; trF1 = [trF1; trFa]; trF2 = [trF2; trFb];
            end
            [cBR, cBP] = corr(trB1, trB2); 
            [cFR, cFP] = corr(trF1, trF2);
            cBRsb = 2*cBR/(1 + (2-1)*cBR);
            cFRsb = 2*cFR/(1 + (2-1)*cFR);
            corrBR100sb = [corrBR100sb; cBRsb]; corrFR100sb = [corrFR100sb; cFRsb];
        end
        bMean = mean(corrBR100sb); fMean = mean(corrFR100sb);
        corrBRsb = [corrBRsb; bMean]; corrFRsb = [corrFRsb; fMean];
        if bMean <= 0 || fMean <= 0
            cRcorrected = 100;
        else
        % reliability correction
        cRcorrected = cR/sqrt(bMean*fMean);
        end
        corrRcorrected = [corrRcorrected; cRcorrected];
    end
    %%
    ss.corrR = corrR;
    ss.corrP = corrP;
    ss.corrBRsb = corrBRsb;
    ss.corrFRsb = corrFRsb;
    ss.Rcorrected = corrRcorrected;
    ss.bfCells = bfCells;
    ss.bResp = bResp;
    ss.fResp = fResp;
    ss.bRespTr = mSWBcTr;
    ss.fRespTr = mSWFcTr;
    sName = fullfile(outFolder, fname{s});
    save(sName, '-struct', 'ss');
    clear sharedBC; clear sharedFC; 
end
