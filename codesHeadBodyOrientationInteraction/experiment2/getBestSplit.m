clear all;
outFolder = ('E:\plexonData\nexData\P2\results\NU\signAZK\plotBest\');
dataDir = ('E:\plexonData\nexData\P2\results\NU\signAZK\mat\');
addpath(dataDir);
allFiles = dir([dataDir, '*.mat']);

% files = allFiles(28:45); % Nacho A
% files = allFiles(1:27); % Nacho P
% files = allFiles(46:63); % Odin A
files = allFiles(64:end); % Odin P
mName = 'M1P';

baseline = 20;
latency = 5; % 50 ms latency
stimWin = 25; % 250 stim duration
%%
str = load(files(2).name);
ss = fieldnames(str);
fn = fieldnames(str.(ss{:}));
stim = str.(ss{:}).(fn{1}).Stim; 
rows0 = find(contains(stim, '_B0_'));
rows90 = find(contains(stim, '_B90_'));
rows180 = find(contains(stim, '_B180_'));
rows270 = find(contains(stim, '_B270_'));
num = numel(stim);
%% select best orientation
bestR = []; unNames = [];
for f = 1:numel(files)
    str = load(files(f).name);
    ss = fieldnames(str);
    fn = fieldnames(str.(ss{:}));
    if isempty(fn) == 0
    bestO = []; 
    for s = 1:numel(fn)
        for a = 1:num
            stimResp = str.(ss{:}).(fn{s}).binMeanTrialFR{a};
            netStimR = stimResp - (mean(stimResp(11:baseline)));
            netWR{a} = mean(netStimR((baseline+latency+1):(baseline+latency+stimWin)));
        end
        [maxR, indMx] = max(cell2mat(netWR));
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
        unN = strcat(ss, '_', fNames');
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
