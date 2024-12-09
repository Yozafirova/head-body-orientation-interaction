clear all;
mpose = 'VP1';
mon = 'M2';
rgm = 'PN1';
baseline = 200; 
latency = 50; 
stimWin = 250;
outFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\Nacho\msb\VP1\resultsVP1\');
dataDir = ('C:\Users\u0137276\Desktop\epDATA\expVP\Nacho\msb\VP1\resultsVP1\');

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

strB = []; strF = []; 
MaxVB = []; MaxVF = []; % net normalized
respSWB = []; respSWF = []; % net resp in the stim window
countSWB = []; countSWF = []; % mean net resp in the stim window
maxSWB = []; maxSWF = []; % mean net normalized in the stim window
sqrBCx = []; sqrFCx = [];% initialize net resp
sqrBC = []; sqrFC = []; 
%%
for k = 1:cellNumBC
    load(filesBC(k).name);
    allRespB = strBC.AllTrials;
    respB = strBC.MeanTrial;
    cond = length(allRespB);
    numTrials = size(allRespB{k}, 1);
    
    % for the plotting
    for ii = 1:cond
        SWBc{ii} = respB{ii}(1, (baseline+latency+1):(baseline+latency+stimWin)); %  resp win, add one for the zero problem
        countSWBc{ii} = sum(SWBc{ii});    
    end
    maxValueB = max(vertcat(countSWBc{:}), [], 'all'); % get the max value from all  responses for that cell
    for ii = 1:cond
        MaxBc{ii} = (countSWBc{ii})/(maxValueB); % normalized response
    end
    maxSWB = [maxSWB; MaxBc];
    respSWB = [respSWB; SWBc]; 
    countSWB = [countSWB; countSWBc];
    MaxVB = [MaxVB; maxValueB];
    
    % for the anova; first get raw normalized
    for ii = 1:cond
        for s = 1:numTrials
            trialRespB = allRespB{ii}(s, :);
            trialSWB{s} = trialRespB((baseline+latency+1):(baseline+latency+stimWin));
            countTrialSWB{s} = sum(trialSWB{s});
            addConstB{s} = countTrialSWB{s}+3/8;
            sqrCountTrialsSWB{s} = sqrt(addConstB{s});
        end
        trialRB{ii} = trialSWB; 
        countSWBc{ii} = countTrialSWB;
        sqrSWB{ii} = sqrCountTrialsSWB;
    end
    
    % to get the max value, per trial
    trBx = [];
    for u = 1:cond
        trRB = cell2mat(sqrSWB{u})';
        trBx = [trBx, trRB];
    end
    trMaxB = max(trBx(:)); 
    trMaxBc = trBx/trMaxB;
    trMaxBc = mat2cell(trMaxBc,8,ones(1,size(trMaxBc,2)));
    
    sqrBC = [sqrBC; sqrSWB];
    sqrBCx = [sqrBCx; trMaxBc];
    clear trialSWB; 
end


for k = 1:cellNumFC
    load(filesFC(k).name);
    allRespF = strFC.AllTrials;
    respF = strFC.MeanTrial;
    cond = length(allRespF);
    numTrials = size(allRespF{k}, 1);
    
    % for the plotting
    for ii = 1:cond
        SWFc{ii} = respF{ii}(1, (baseline+latency+1):(baseline+latency+stimWin)); %  resp win, add one for the zero problem
        countSWFc{ii} = sum(SWFc{ii});    
    end
    maxValueF = max(vertcat(countSWFc{:}), [], 'all'); % get the max value from all  responses for that cell
    for ii = 1:cond
        MaxFc{ii} = (countSWFc{ii})/(maxValueF); % normalized response
    end
    maxSWF = [maxSWF; MaxFc];
    respSWF = [respSWF; SWFc]; 
    countSWF = [countSWF; countSWFc];
    MaxVF = [MaxVF; maxValueF];
    
    % for the anova; first get raw normalized
    for ii = 1:cond
        for s = 1:numTrials
            trialRespF = allRespF{ii}(s, :);
            trialSWF{s} = trialRespF((baseline+latency+1):(baseline+latency+stimWin));
            countTrialSWF{s} = sum(trialSWF{s});
            addConstF{s} = countTrialSWF{s}+3/8;
            sqrCountTrialsSWF{s} = sqrt(addConstF{s});
        end
        trialRF{ii} = trialSWF; 
        countSWFc{ii} = countTrialSWF;
        sqrSWF{ii} = sqrCountTrialsSWF;
    end
    
    % to get the max value, per trial
    trFx = [];
    for u = 1:cond
        trRF = cell2mat(sqrSWF{u})';
        trFx = [trFx, trRF];
    end
    trMaxF = max(trFx(:)); 
    trMaxFc = trFx/trMaxF;
    trMaxFc = mat2cell(trMaxFc,8,ones(1,size(trMaxFc,2)));
    
    sqrFC = [sqrFC; sqrSWF];
    sqrFCx = [sqrFCx; trMaxFc];
    clear trialSWF; 
end

% calculate
pValB = []; pValF = []; omegaB = []; omegaF = []; 
omegaBb = []; omegaFb = []; omegaBf = []; omegaFf = [];
sqrBCcountx = []; sqrBCcount = [];
sqrFCcountx = []; sqrFCcount = [];

for a = 1:cellNumBC
    trNum = size(sqrBCx{a, 1}, 1);
    nm = split(strBC.Stim, '_');
    nameB = []; nameF = []; 
    for b = 1:length(nm)
        nmB = repelem(nm(b, 2), trNum)';
        nameB = [nameB; nmB];
        nmF = repelem(nm(b, 3), trNum)';
        nameF = [nameF; nmF];
    end
    nmTr = {sort(1:trNum)'}; nameTr = num2str(cell2mat(repelem(nmTr, cond)'));
    cellRespBC = []; cellRespBCx = [];
    for c = 1:cond
        trStimB = cell2mat(sqrBC{a, c})'; % not normalized
        trStimBx = cell2mat(sqrBCx(a, c));
        cellRespBC = [cellRespBC; trStimB];
        cellRespBCx = [cellRespBCx; trStimBx];
    end
    
    [pB, tblB] = anovan(cellRespBCx,{nameB nameF}, 'model', 'interaction', 'display', 'off');
%     [pB, tblB] = anovan(cellRespBC,{nameB nameF}, 'model', 'interaction', 'display', 'off');
    
    % for the interaction
    dfB = tblB{4, 3};
    msB = tblB{4, 5}; 
    msEb = tblB{5, 5}; 
    obsB = tblB{6, 3}+1;
    
    % for the main effect body and face
    dfBb = tblB{2, 3};
    dfBf = tblB{3, 3}; 
    msBb = tblB{2, 5};
    msBf = tblB{3, 5};
    
    % interaction
    omB = (dfB*(msB-msEb))/(dfB*msB+(obsB-dfB)*msEb);
    % main effects body
    omBb = (dfBb*(msBb-msEb))/(dfBb*msBb+(obsB-dfBb)*msEb);
    % main effects face
    omBf = (dfBf*(msBf-msEb))/(dfBf*msBf+(obsB-dfBf)*msEb);
    % pValues
    pValB = [pValB; pB(1), pB(2), pB(3)];
    
    omegaB = [omegaB; omB];
    omegaBb = [omegaBb; omBb]; omegaBf = [omegaBf; omBf];
    sqrBCcountx = [sqrBCcountx, cellRespBCx]; sqrBCcount = [sqrBCcount, cellRespBC];
    numB = find(pValB(:, 3)<0.05); length(numB);
end

for a = 1:cellNumFC
    trNum = size(sqrFCx{a, 1}, 1);
    nm = split(strFC.Stim, '_');
    nameB = []; nameF = []; 
    for b = 1:length(nm)
        nmB = repelem(nm(b, 2), trNum)';
        nameB = [nameB; nmB];
        nmF = repelem(nm(b, 3), trNum)';
        nameF = [nameF; nmF];
    end
    nmTr = {sort(1:trNum)'}; nameTr = num2str(cell2mat(repelem(nmTr, cond)'));
    cellRespFC = []; cellRespFCx = [];
    for c = 1:cond
        trStimF = cell2mat(sqrFC{a, c})'; % not normalized
        trStimFx = cell2mat(sqrFCx(a, c));
        cellRespFC = [cellRespFC; trStimF];
        cellRespFCx = [cellRespFCx; trStimFx];
    end
    
    [pF, tblF] = anovan(cellRespFCx,{nameB nameF}, 'model', 'interaction', 'display', 'off');
%     [pF, tblF] = anovan(cellRespFC,{nameB nameF}, 'model', 'interaction', 'display', 'off');
    
    % for the interaction
    dfF = tblF{4, 3};
    msF = tblF{4, 5}; 
    msEf = tblF{5, 5};
    obsF = tblF{6, 3}+1;
    
    % for the main effect body and face
    dfFb = tblF{2, 3};
    dfFf = tblF{3, 3};
    msFb = tblF{2, 5};
    msFf = tblF{3, 5};
    
    % interaction
    omF = (dfF*(msF-msEf))/(dfF*msF+(obsF-dfF)*msEf);
    % main effects body
    omFb = (dfFb*(msFb-msEf))/(dfFb*msFb+(obsF-dfFb)*msEf);
    % main effects face
    omFf = (dfFf*(msFf-msEf))/(dfFf*msFf+(obsF-dfFf)*msEf);
    % p values
    pValF = [pValF; pF(1), pF(2), pF(3)];
    
    omegaF = [omegaF; omF];
    omegaFb = [omegaFb; omFb]; omegaFf = [omegaFf; omFf];
    sqrFCcountx = [sqrFCcountx, cellRespFCx]; sqrFCcount = [sqrFCcount, cellRespFC];
    numF = find(pValF(:, 3)<0.05); length(numF);
end

bo = {'B0','B45','B90','B135','B180','B225', 'B270', 'B315'};
fo = {'F0','F45','F90','F135','F180','F225', 'F270', 'F315'};

% to plot!!
fig1 =  figure; fig1.Position = [300 10 810 810]; % set(gcf, 'visible', 'on', 'Position', get(0, 'Screensize'));
for p = 1:cellNumBC
    cellPlot = reshape(horzcat(maxSWB{p, :}), 8, 8);
    subplot(6, 6, p);
    h = heatmap(bo, fo, cellPlot, 'Colormap', winter, 'Colorlimits', [0, 1], 'CellLabelColor', 'None');
    s = ismember(p, numB);
    if s > 0
        h.FontColor = 'red';
    end
    spl1 = split(filesBC(p).name, '_');
    spl2 = split(spl1(2), '.');
    h.Title = [spl2{1},  '; ', 'sCount ' num2str(MaxVB(p))];
    h.XLabel = 'Body Orientation';
    h.YLabel = 'Face Orientation';
    h.FontSize = 6;
    colorbar off; 
end
sgtitle(['Monkey-Centered', ' ', rgm]);  
fig1Name = fullfile(outFolder, strcat(mon, '_', mpose, '_', 'MC', '_', 'sqr', '.pdf'));    

fig2 =  figure; fig2.Position = [300 10 810 810]; % set(gcf, 'visible', 'on', 'Position', get(0, 'Screensize'));
for p = 1:cellNumFC
    cellPlot = reshape(horzcat(maxSWF{p, :}), 8, 8);
    subplot(6, 6, p);
    h = heatmap(bo, fo, cellPlot, 'Colormap', winter, 'Colorlimits', [0, 1], 'CellLabelColor', 'None');
    s = ismember(p, numF);
    if s > 0
        h.FontColor = 'red';
    end
    spl1 = split(filesFC(p).name, '_');
    spl2 = split(spl1(2), '.');
    h.Title = [spl2{1},  '; ', 'sCount ' num2str(MaxVF(p))];
    h.XLabel = 'Body Orientation';
    h.YLabel = 'Face Orientation';
    h.FontSize = 6;
    colorbar off; 
end
sgtitle(['Face-Centered', ' ', rgm]);  
fig2Name = fullfile(outFolder, strcat(mon, '_', mpose, '_', 'FC', '_', 'sqr', '.pdf')); 


BCsqr.pV = pValB;
BCsqr.omegaBF = omegaB; BCsqr.omegaB = omegaBb; BCsqr.omegaF = omegaBf;
BCsqr.namesB = nameB; BCsqr.namesF = nameF;
BCsqr.countx = sqrBCcountx; BCsqr.count = sqrBCcount;

FCsqr.pV = pValF;
FCsqr.omegaBF = omegaF; FCsqr.omegaB = omegaFb; FCsqr.omegaF = omegaFf;
FCsqr.namesB = nameB; FCsqr.namesF = nameF;
FCsqr.countx = sqrFCcountx; FCsqr.count = sqrFCcount;

strBName = fullfile(outFolder, strcat('BC_sqr_', rgm, '.mat'));
strFName = fullfile(outFolder, strcat('FC_sqr_', rgm, '.mat'));

    
% save(strBName, 'BCsqr');  save(strFName, 'FCsqr'); 
% saveas(fig1, fig1Name); saveas(fig2, fig2Name);


%     writetable(struct2table(strB), strBxName); writetable(struct2table(strF), strFxName);

%     save pValBC.mat pValB;
%     save omegaBC.mat omegaB; save omegaBCb.mat omegaBb; save omegaBCf.mat omegaBf;
    
    
%     save pValFC.mat pValF;
%     save omegaFC.mat omegaF; save omegaFCb.mat omegaFb; save omegaFCf.mat omegaFf;    
    
%     save pValFC.mat pValF;
%     save omegaFC.mat omegaF; save omegaFCb.mat omegaFb; save omegaFCf.mat omegaFf;

% horzcat(mMaxSWB{1, :})
% flip(reshape(horzcat(mMaxSWB{1, :}), 8, 8))






