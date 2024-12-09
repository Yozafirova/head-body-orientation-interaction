clear all;
outFolder = ('E:\plexonData\nexData\VP\results\P1\NU\signAZK_B\');
dataDir = ('E:\plexonData\nexData\VP\results\P1\NU\signAZK_B\mat\');
addpath(dataDir);
allFiles = dir([dataDir, '*.mat']);
files2 = allFiles(26:38); % Nacho A
% files2 = allFiles(1:25); % Nacho P
files1 = allFiles(39:52); % Odin A
% files1 = allFiles(53:end); % Odin P
testName = ('P1_BA');
m1 = load('M1A_bestRows.mat');
m2 = load('M2A_bestRows.mat');
baseline = 20;
latency = 5; 
stimWin = 25;
%%
m1R = cell2mat(m1.bestRows); 
m1Inv = m1R(1:2:numel(m1R)); m1Up = m1R(2:2:numel(m1R));
m2R = cell2mat(m2.bestRows); 
m2Inv = m2R(1:2:numel(m2R)); m2Up = m2R(2:2:numel(m2R));
%%
for a = 1:numel(files1)
    str = load(files1(a).name);
    spl = split(files1(a).name, '_');
    ss = [strjoin(spl(1:2), '_'), '_VP3'];
    fn = fieldnames(str.(ss));
    if isempty(fn) == 0
    sNames1{a} = fn;       
    end
end 
for a = 1:numel(files2)
    str = load(files2(a).name);
    spl = split(files2(a).name, '_');
    ss = [strjoin(spl(1:2), '_'), '_VP3'];
    fn = fieldnames(str.(ss));
    if isempty(fn) == 0
    sNames2{a} = fn;       
    end
end
%%
M1Upstr = []; M1Invstr = []; M2Upstr = []; M2Invstr = [];
m1Units = []; m2Units = [];
for f = 1:numel(files1)
    str = load(files1(f).name);
    spl = split(files1(f).name, '_');
    ss = [strjoin(spl(1:2), '_'), '_VP3'];
    fn1 = fieldnames(str.(ss));
    if isempty(fn1) == 0
    excl = setdiff(fn1, sNames1{f});
    newD = rmfield(str.(ss), excl);
    fn = fieldnames(newD);
    for s = 1:numel(sNames1{f})
        newDName = strcat(ss, '_', fn{s});
        m1Units = [m1Units; newD.(fn{s})];
    end
    end
end
for f = 1:numel(files2)
    str = load(files2(f).name);
    spl = split(files2(f).name, '_');
    ss = [strjoin(spl(1:2), '_'), '_VP3'];
    fn1 = fieldnames(str.(ss));
    if isempty(fn1) == 0
    excl = setdiff(fn1, sNames2{f});
    newD = rmfield(str.(ss), excl);
    fn = fieldnames(newD);
    for s = 1:numel(sNames2{f})
        newDName = strcat(ss, '_', fn{s});
        m2Units = [m2Units; newD.(fn{s})];
    end
    end
end
for ff = 1:size(m1Units, 1)
    stimRespU = m1Units(ff).binMeanTrialFR{m1Up(ff)};
    netStimRU = stimRespU - (mean(stimRespU(11:baseline)));
    netWRU1{ff} = mean(netStimRU((baseline+latency+1):(baseline+latency+stimWin)));
    stimRespI = m1Units(ff).binMeanTrialFR{m1Inv(ff)};
    netStimRI = stimRespI - (mean(stimRespI(11:baseline)));
    netWRI1{ff} = mean(netStimRI((baseline+latency+1):(baseline+latency+stimWin)));
end
for ff = 1:size(m2Units, 1)
    stimRespU = m2Units(ff).binMeanTrialFR{m2Up(ff)};
    netStimRU = stimRespU - (mean(stimRespU(11:baseline)));
    netWRU2{ff} = mean(netStimRU((baseline+latency+1):(baseline+latency+stimWin)));
    stimRespI = m2Units(ff).binMeanTrialFR{m2Inv(ff)};
    netStimRI = stimRespI - (mean(stimRespI(11:baseline)));
    netWRI2{ff} = mean(netStimRI((baseline+latency+1):(baseline+latency+stimWin)));
end
%%
netWRU1 = cell2mat(netWRU1);
netWRI1 = cell2mat(netWRI1);
netWRU2 = cell2mat(netWRU2);
netWRI2 = cell2mat(netWRI2);
up = [netWRU1'; netWRU2'];
inv = [netWRI1'; netWRI2'];
[p, h, stats]=signrank(up, inv);
%%
% for the scatter!
medUp1 = median(netWRU1); medInv1 = median(netWRI1);
medUp2 = median(netWRU2); medInv2 = median(netWRI2);
medUp = median([netWRU1, netWRU2]);
medInv = median([netWRI1, netWRI2]);
% colO = [0, 0.8, 0; 0, 0, 0.8; 0.8, 0, 0];
% colN = [0.6, 1, 0.6;  0.6, 0.6, 1; 1, 0.6, 0.6]; % choose colors
% maxX1 = ceil((max([netWRU1, netWRU2])/10))*10;
% maxY1 = ceil((max([netWRI1, netWRI2])/10))*10;
% minX1 = floor((min([netWRU1, netWRU2])/10))*10;
% minY1 = floor((min([netWRI1, netWRI2])/10))*10;
% maxP = max(maxX1, maxY1);
% maxN = min(minX1, minY1);
% txt = '\diamondsuit';
% %%
% fig1 =  figure; %set(gcf, 'visible', 'on', 'Position', get(0, 'Screensize'));
% hold all;
% axis equal;
% scatter(netWRU1, netWRI1, 30, colO(2, :), 'filled', 'markeredgecolor', colO(2, :));
% scatter(netWRU2, netWRI2, 30, colN(2, :), 'filled', 'markeredgecolor', colO(2, :));
% set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'xlim', [maxN, maxP], 'xtick', -60:20:140, 'ylim', [maxN, maxP], 'ytick', -60:20:140);
% plot([maxN maxP], [maxN maxP]);
% scatter(medUp1, maxN, 150, colO(2, :), 'filled', 'd', 'markeredgecolor', colO(2, :));
% scatter(medUp2, maxN, 140, colN(2, :), 'filled', 'd', 'markeredgecolor', colO(2, :));
% scatter(maxN, medInv1, 150, colO(2, :), 'filled', 'd', 'markeredgecolor', colO(2, :));
% scatter(maxN, medInv2, 140, colN(2, :), 'filled', 'd', 'markeredgecolor', colO(2, :));
% text(maxP, 0, ['p=' num2str(p)], 'horizontalAlignment', 'right', 'color','red', 'FontSize', 10);
% text(maxP, 10, ['n2 ' num2str(numel(netWRU2))], 'horizontalAlignment', 'right', 'color', colN(2, :),  'FontSize', 10);
% text(maxP, 18, ['n1 ' num2str(numel(netWRU1))], 'horizontalAlignment', 'right', 'color', colO(2, :), 'FontSize', 10);
% xlabel('UPRIGHT (spikes/s)', 'FontSize', 10, 'FontWeight','bold'), ylabel('INVERTED (spikes/s)', 'FontSize', 10, 'FontWeight','bold');
% title('BODY: Pose 1 pSTS');
% lgd = legend('M1', 'M2');
% lgd.Location = 'northwest';
% %%
% figName1 = fullfile(outFolder, [testName '.png']);
% figName2 = fullfile(outFolder, [testName '.svg']);
% saveas(fig1, figName1);  
% saveas(fig1, figName2); 

