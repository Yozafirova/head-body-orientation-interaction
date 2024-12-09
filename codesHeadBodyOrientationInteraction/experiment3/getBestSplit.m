clear all;
outFolder = ('E:\plexonData\nexData\VP\results\P1\NU\signAZK_B\');
dataDir = ('E:\plexonData\nexData\VP\results\P1\NU\signAZK_B\mat\');
addpath(dataDir);
allFiles = dir([dataDir, '*.mat']);

files = allFiles(26:38); % Nacho A
% files = allFiles(1:25); % Nacho P
% files = allFiles(39:52); % Odin A
% files = allFiles(53:end); % Odin P
mName = 'M2A';

baseline = 20;
latency = 5; % 50 ms latency
stimWin = 25; % 250 stim duration
%%
str = load(files(2).name);
spl = split(files(2).name, '_');
ss = [strjoin(spl(1:2), '_') '_VP3'];
fn = fieldnames(str.(ss));
rows0 = find(contains(str.(ss).(fn{1}).Stim, '_B0_F0_B'));
rows90 = find(contains(str.(ss).(fn{1}).Stim, '_B90_F90_B'));
rows180 = find(contains(str.(ss).(fn{1}).Stim, '_B180_F180_B'));
rows270 = find(contains(str.(ss).(fn{1}).Stim, '_B270_F270_B'));
stimRows = [rows0; rows90; rows180; rows270];
stim = numel(stimRows);
%% normalize on all nm per un and select best orientation
bestR = []; unNames = [];
for f = 1:numel(files)
    str = load(files(f).name);
    spl = split(files(f).name, '_');
    ss = [strjoin(spl(1:2), '_') '_VP3'];
    fn = fieldnames(str.(ss));
    if isempty(fn) == 0
    bestO = []; 
    for s = 1:numel(fn)
        for a = 1:stim
            stimResp = str.(ss).(fn{s}).binMeanTrialFR{stimRows(a)};
            netStimR = stimResp - (mean(stimResp(11:baseline)));
            netWR{a} = mean(netStimR((baseline+latency+1):(baseline+latency+stimWin)));
        end
        [maxR, indX] = max(cell2mat(netWR));
        indMx = stimRows(indX);
        if ismember (indMx, rows0) == 1
            bestO = [bestO; {rows0}];
        elseif ismember (indMx, rows90) == 1
            bestO = [bestO; {rows90}];
        elseif ismember (indMx, rows180) == 1
            bestO = [bestO; {rows180}];
        elseif ismember (indMx, rows270) == 1
            bestO = [bestO; {rows270}];
        end
        fNames{s} = fn{s};
        unN = strcat({ss}, '_', fNames');
    end
    bestR = [bestR; bestO]; 
    unNames = [unNames; unN];
    clear unN; clear fNames;
    end
end
st.Units = unNames;
st.bestRows = bestR;
% strName = fullfile(dataFolder, 'chUnits_signAZ.mat');
strName = fullfile(outFolder, [mName '_bestRows.mat']);
save(strName, '-struct', 'st');
