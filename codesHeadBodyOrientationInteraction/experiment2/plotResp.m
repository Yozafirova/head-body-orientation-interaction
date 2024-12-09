clear all;
outFolder = ('E:\plexonData\nexData\P2\results\NU\signAZK\');
dataDir = ('E:\plexonData\nexData\P2\results\NU\signAZK\mat\');
addpath(dataDir);
allFiles = dir([dataDir, '*.mat']);

% files = allFiles(28:45); % Nacho A
% files = allFiles(1:27); % Nacho P
% files = allFiles(46:63); % Odin A
files = allFiles(64:end); % Odin P
mName = 'M1P';
plotBaseline = 200;
%%
str = load(files(2).name);
ss = fieldnames(str);
fn = fieldnames(str.(ss{:}));
stim = str.(ss{:}).(fn{1}).Stim; % reorder stim first 0 diff
rowsB = find(contains(stim, '_B.'))';
rowsF0 = find(contains(stim, 'B0_') & contains(stim, '_F.'))';
rowsM0 = find(contains(stim, 'B0_') & contains(stim, '_M.'))';
rowsF90 = find(contains(stim, 'B90_') & contains(stim, '_F.'))';
rowsM90 = find(contains(stim, 'B90_') & contains(stim, '_M.'))';
rowsF90 = rowsF90([4, 3, 1, 2]); rowsM90 = rowsM90([4, 3, 1, 2]);
rowsF180 = find(contains(stim, 'B180_') & contains(stim, '_F.'))';
rowsM180 = find(contains(stim, 'B180_') & contains(stim, '_M.'))';
rowsF180 = rowsF180([2, 1, 3, 4]); rowsM180 = rowsM180([2, 1, 3, 4]);
rowsF270 = find(contains(stim, 'B270_') & contains(stim, '_F.'))';
rowsM270 = find(contains(stim, 'B270_') & contains(stim, '_M.'))';
rowsF270 = rowsF270([3, 4, 1, 2]); rowsM270 = rowsM270([3, 4, 1, 2]);
rowsFMO = reshape([rowsF0' rowsM0']', [], 1);
rowsFM9O = reshape([rowsF90' rowsM90']', [], 1);
rowsFM18O = reshape([rowsF180' rowsM180']', [], 1);
rowsFM27O = reshape([rowsF270' rowsM270']', [], 1);
rows0 = [rowsB(1); rowsFMO]'; rows90 = [rowsB(4); rowsFM9O]';
rows180 = [rowsB(2); rowsFM18O]'; rows270 = [rowsB(3); rowsFM27O]';
allRows = [rows0, rows180, rows90, rows270];
%% normalize on all stim per un and select best orientation
strResp = []; unNames = [];
for f = 1:numel(files)
    str = load(files(f).name);
    ss = fieldnames(str);
    fn = fieldnames(str.(ss{:}));
    if isempty(fn) == 0
    for ff = 1:numel(fn)
        plotR = str.(ss{:}).(fn{ff}).binMeanTrialFRPlot;
        plotR = plotR(allRows);
        strResp = [strResp; plotR]; 
        fNames{ff} = fn{ff};
        unN = strcat({ss}, '_', fNames');
    end
    unNames = [unNames; unN];
    clear fNames; clear unN;
    end
end
%% % get mean resp
for a = 1:numel(allRows)
    allStim = vertcat(strResp{:, a});
    ciStim = bootci(1000, @mean, allStim);
    uciUp{a} = ciStim(2, :); lciUp{a} = ciStim(1, :);
    meanAllStim = mean(vertcat(strResp{:, a}), 1);
    meanStimAll{a} = meanAllStim;
end
%%    
col = repmat({'b', 'b', 'b', 'r', 'r', 'g', 'g', 'g', 'g'}, 1, 4);

getMaxR = max([meanStimAll{:}]);
getMaxR = round(getMaxR)+5;
xx = 1:35; % set values of x-axis for the shading
x1 = 12.5; x2 = 25; x3 = 10; x4 = 22.5; x5 = 17.5; x6 = getMaxR;% set the response window

fig1 =  figure; set(gcf, 'visible', 'on', 'Position', get(0, 'Screensize'));
for p = 1:numel(allRows)
    subplot(4, 9, p);
    hold all;
    plot(uciUp{p}, 'LineStyle', 'none'); plot(lciUp{p}, 'LineStyle', 'none');
    patch([xx fliplr(xx)], [lciUp{p} fliplr(uciUp{p})], col{p}, 'LineStyle', 'none');
    plot(meanStimAll{p}, 'Color', col{p}, 'LineWidth', 3); 
    set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'xlim', [0, 35], 'xtick', 0:5:35, 'xticklabel', ...
        -plotBaseline:100:500, 'ytick', [0:5:round(getMaxR)], 'ylim', [0, round(getMaxR)]);
    xlabel('Time', 'FontSize', 10, 'FontWeight','bold'), ylabel('Spikes/Second', 'FontSize', 10, 'FontWeight','bold');
    plot([x1 x1], [0 getMaxR-5],':r', 'LineWidth', 1);
    plot([x2 x2], [0 getMaxR-5],':r', 'LineWidth', 1);
    plot([x3 x4], [0.1 0.1], 'k', 'LineWidth', 3);
%     text(x5, x6, '***', 'FontSize', 30, 'FontWeight','bold');
    hold off
    alpha(.2);
    bb = split(stim{allRows(p)}, '_');
    b = split(bb{4}, '.');
    plotName = [bb{2}, ' ', bb{3}, ' ', b{1}];
    title(plotName);
end
sgtitle([mName, ' Mean Resp: ', num2str(numel(unNames)), ' Units'], 'FontSize', 20, 'fontweight', 'bold');
%%
figName1 = fullfile(outFolder, strcat(mName, '_', 'MeanResp', '.png'));
figName2 = fullfile(outFolder, strcat(mName, '_', 'MeanResp', '.svg'));
saveas(fig1, figName1);  
saveas(fig1, figName2); 
% close all;