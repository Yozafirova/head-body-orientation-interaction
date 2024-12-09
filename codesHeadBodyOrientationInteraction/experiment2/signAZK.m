clear all;
baseline = 20; % adjust baseline in the net resp
latency = 5; % 50 ms latency
stimWin = 25; % 250 stim duration
trNum = 8;
kwP = 0.05;
outFolderAZK = ('E:\plexonData\nexData\P2\results\NU\signAZK\mat\');
% outFolderA = ('E:\plexonData\nexData\P1\results\col\signA\mat\');
% outFolderZ = ('E:\plexonData\nexData\P1\results\col\signZ\mat\');
% outFolderK = ('E:\plexonData\nexData\P1\results\col\signK\mat\');
dataDir = ('E:\plexonData\nexData\P2\results\NU\mat\');
addpath(dataDir);
files = dir([dataDir, '*_str.mat']);
num = length(files);
str = load(files(1).name);
spl = split(files(1).name, '_');
test = spl{4};
ss = strjoin(spl(1:3), '_');
fn = fieldnames(str.(ss));
stim = numel(str.(ss).(fn{1}).Stim);
%%
for k = 1:num
    str = load(files(k).name);
    spl = split(files(k).name, '_');
    ss = strjoin(spl(1:3), '_');
    fn = fieldnames(str.(ss));
    signA = []; notSignA = []; signZ = []; notSignZ = []; sZ = []; nsZ = []; signKW = []; notSignKW = [];
    for a = 1:length(fn)
        trialStr = [];
        trialStr = [trialStr; str.(ss).(fn{a}).binTrialsFRAnova]; % one row str of 40 columns and trialx70 cells
        for i = 1:stim
            oneStim = vertcat(trialStr{i}(1:trNum, :)); % unpack for each stim
            base{i} = mean(oneStim(:, 1:baseline), 2); % take mean baseline
            win{i} = mean(oneStim(:, (baseline+latency+1):(baseline+latency+stimWin)), 2); % take mean resp in the window
            trialNum{i} = repelem(i, size(oneStim, 1))'; % repeat the number of the condition as many times as the trials
        end
        % ANOVA
        trialMat = horzcat(vertcat(trialNum{:}), vertcat(base{:}), vertcat(win{:})); % get the concatinated matrix for each cell
        structStat = splitplotANOVA(trialMat);
        if structStat.significant == 1
            signA = [signA; fn{a}];
        else
            notSignA = [notSignA; fn{a}];
        end
        for z = 1:stim
            stimRows = find((trialMat(:, 1) == z) == 1);
            bM{z} = mean(trialMat(stimRows, 2));
        end
        % Z SCORE
        baseM = mean(cell2mat(bM));
        baseSD = std(cell2mat(bM));
        for r = 1:stim
            stimRows = find((trialMat(:, 1) == r) == 1);
            respM = mean(trialMat(stimRows, 3));
            respZ = (respM-baseM)/baseSD;
            if respZ > 3
                sZ = [sZ, respZ];
            else
                nsZ = [nsZ, respZ];
            end
        end
        sg = isempty(sZ);
        if sg == 0
            signZ = [signZ; fn{a}];
        else
            notSignZ = [notSignZ; fn{a}];
        end
        sZ = []; nsZ = [];
        % KRUSKAL WALLIS
        matKW = reshape(trialMat(:, 3), [trNum, stim]);
        pKW = kruskalwallis(matKW, [], 'off');
        if pKW > kwP
            notSignKW = [notSignKW; fn{a}];
        else
            signKW = [signKW; fn{a}];
        end      
    end
%     sign = intersect(signA, signZ, 'rows');
%     nonSign = unique([notSignA; notSignZ], 'rows');
    
    nonSign = unique([notSignA; notSignZ; notSignKW], 'rows');
    if isempty(nonSign) == 0
        sAZK.(ss) = rmfield(str.(ss), nonSign);
    else
        sAZK.(ss) = str.(ss);
    end
    if isempty(notSignA) == 0
        sA.(ss) = rmfield(str.(ss), notSignA);
    else
        sA.(ss) = str.(ss);
    end
    if isempty(notSignZ) == 0
        sZ.(ss) = rmfield(str.(ss), notSignZ);
    else
        sZ.(ss) = str.(ss);
    end
    if isempty(notSignKW) == 0
        sK.(ss) = rmfield(str.(ss), notSignKW);
    else
        sK.(ss) = str.(ss);
    end
    sName = strjoin(spl(1:2), '_');
    strAZKname = fullfile(outFolderAZK, [sName, '_', test, '_signAZK.mat']);
%     strAname = fullfile(outFolderA, [ss, '_signA.mat']);
%     strZname = fullfile(outFolderZ, [ss, '_signZ.mat']);
%     strKname = fullfile(outFolderK, [ss, '_signK.mat']);
    
    
    save(strAZKname, '-struct', 'sAZK');
%     save(strAname, '-struct', 'sA');
%     save(strZname, '-struct', 'sZ');
%     save(strKname, '-struct', 'sK');
    clear sAZ; clear sA; clear sZ; clear sK; clear str; clear sAZK; clear sA; clear sZ; clear sK; 
end
