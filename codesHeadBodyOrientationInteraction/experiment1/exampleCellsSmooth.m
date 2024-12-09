clear all;
outFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\strMS_best\exampleCells1\');
if ~exist(outFolder)
    mkdir(outFolder);
end
load('cellPoses');
load('a1bcnu'); load('a2bcnu'); load('p1bcnu'); load('p2bcnu');
load('a1fcnu'); load('a2fcnu'); load('p1fcnu'); load('p2fcnu');
str = [a1bcnu; a2bcnu; p1bcnu; p2bcnu; a1fcnu; a2fcnu; p1fcnu; p2fcnu];
nfbm0 = [2 1 3]; nfbm90 = [7 6 8]; nfbm180 = [12 11 13]; nfbm270 = [17 16 18]; % face, body, monkey, no f-b angle
ufbm0 = [4 1 5]; ufbm90 = [9 6 10]; ufbm180 = [14 11 15]; ufbm270 = [19 16 20]; 
resp = [{nfbm0}, {nfbm90}, {nfbm180}, {nfbm270}, {ufbm0}, {ufbm90}, {ufbm180}, {ufbm270}];
%%
% to get the cellNum per ss per area per pose
a1bcO = find(contains(str(1).mon, 'o'));
a1bcN = find(contains(str(1).mon, 'n'));
a2bcO = find(contains(str(2).mon, 'o'));
a2bcN = find(contains(str(2).mon, 'n'));
p1bcO = find(contains(str(3).mon, 'o'));
p1bcN = find(contains(str(3).mon, 'n'));
p2bcO = find(contains(str(4).mon, 'o'));
p2bcN = find(contains(str(4).mon, 'n'));
a1fcO = find(contains(str(5).mon, 'o'));
a1fcN = find(contains(str(5).mon, 'n'));
a2fcO = find(contains(str(6).mon, 'o'));
a2fcN = find(contains(str(6).mon, 'n'));
p1fcO = find(contains(str(7).mon, 'o'));
p1fcN = find(contains(str(7).mon, 'n'));
p2fcO = find(contains(str(8).mon, 'o'));
p2fcN = find(contains(str(8).mon, 'n'));
cellRows = [{a1bcO, a1bcN}; {a2bcO, a2bcN}; {p1bcO, p1bcN}; {p2bcO, p2bcN}; ...
    {a1fcO, a1fcN}; {a2fcO, a2fcN}; {p1fcO, p1fcN}; {p2fcO, p2fcN}];
%%
% for the plotting of the distributions; get resp per ss
for k = 1:length(ss.areaOrder)
    respFo = []; respBo = []; respMo = []; respFn = []; respBn = []; respMn = [];
    respFoPl = []; respBoPl = []; respMoPl = []; respFnPl = []; respBnPl = []; respMnPl = [];
    exclCells = ss.nonRespCells{k};
    respCells = ss.netBC{k};
    respCellsPl = ss.netRespPl{k};
    for a = 1:length(exclCells)
        if exclCells(a) < length(cellRows{k, 1})
            exclRows = find(ismember(cellRows{k, 1}, exclCells(a)));
            cellRows{k, 1}(exclRows) = [];
        else
            exclRows = find(ismember(cellRows{k, 2}, exclCells(a)));
            cellRows{k, 2}(exclRows) = [];
        end
    end
    respCellsO = respCells(cellRows{k, 1}, :);
    respCellsN = respCells(cellRows{k, 2}, :);
    respCellsOPl = respCellsPl(cellRows{k, 1}, :);
    respCellsNPl = respCellsPl(cellRows{k, 2}, :);
    respPoses = ss.bestPoses{k}';
    respPosesO = respPoses(cellRows{k, 1}, :);
    respPosesN = respPoses(cellRows{k, 2}, :);
    for a = 1:length(respCellsO)
        for i = 1:length(respPosesO{a})
            poseNum = respPosesO{a}(i);
            faceRo = respCellsO(a, resp{poseNum}(1));
            bodyRo = respCellsO(a, resp{poseNum}(2));
            monRo = respCellsO(a, resp{poseNum}(3));
            faceRoPl = respCellsOPl(a, resp{poseNum}(1));
            bodyRoPl = respCellsOPl(a, resp{poseNum}(2));
            monRoPl = respCellsOPl(a, resp{poseNum}(3));
            respFo = [respFo; faceRo]; respBo = [respBo; bodyRo]; respMo = [respMo; monRo];
            respFoPl = [respFoPl; faceRoPl]; respBoPl = [respBoPl; bodyRoPl]; respMoPl = [respMoPl; monRoPl];
        end
    end
    for a = 1:length(respCellsN)
        for i = 1:length(respPosesN{a})
            poseNum = respPosesN{a}(i);
            faceRn = respCellsN(a, resp{poseNum}(1));
            bodyRn = respCellsN(a, resp{poseNum}(2));
            monRn = respCellsN(a, resp{poseNum}(3));
            faceRnPl = respCellsNPl(a, resp{poseNum}(1));
            bodyRnPl = respCellsNPl(a, resp{poseNum}(2));
            monRnPl = respCellsNPl(a, resp{poseNum}(3));
            respFn = [respFn; faceRn]; respBn = [respBn; bodyRn]; respMn = [respMn; monRn];
            respFnPl = [respFnPl; faceRnPl]; respBnPl = [respBnPl; bodyRnPl]; respMnPl = [respMnPl; monRnPl];
        end
    end
respFaceO{k} = respFo; respBodyO{k} = respBo; respMonO{k} = respMo;
respFaceN{k} = respFn; respBodyN{k} = respBn; respMonN{k} = respMn;
respFaceOPl{k} = respFoPl; respBodyOPl{k} = respBoPl; respMonOPl{k} = respMoPl;
respFaceNPl{k} = respFnPl; respBodyNPl{k} = respBnPl; respMonNPl{k} = respMnPl;
respFacePl{k} = [respFoPl; respFnPl]; respBodyPl{k} = [respBoPl; respBnPl]; respMonPl{k} = [respMoPl; respMnPl];
end 
%%
% calculate the indices
% do it just for the body centered (names 1-4), interaction index
names = [{'a1bc'}; {'a2bc'}; {'p1bc'}; {'p2bc'}; {'a1fc'}; {'a2fc'}; {'p1fc'}; {'p2fc'}];
for n = 5%:length(names)
    smO = cell2mat(respFaceO{:, n})+cell2mat(respBodyO{:, n}); 
    mxO = max(cell2mat(respFaceO{:, n}), cell2mat(respBodyO{:, n}));
    mnO = cell2mat(respMonO{:, n});
    imxO = (mnO-mxO)./(abs(mnO)+abs(mxO));
    ixO = (mnO-smO)./(abs(mnO)+abs(smO));

    smN = cell2mat(respFaceN{:, n})+cell2mat(respBodyN{:, n}); 
    mxN = max(cell2mat(respFaceN{:, n}), cell2mat(respBodyN{:, n}));
    mnN = cell2mat(respMonN{:, n});
    imxN = (mnN-mxN)./(abs(mnN)+abs(mxN));
    ixN = (mnN-smN)./(abs(mnN)+abs(smN));
    
    % concatinate
    ix = [ixO; ixN];
    medIx = median(ix);
    ixNegRows = find(ix == -1); negSz = numel(ixNegRows);
    ixPosRows = find(ix == 1); posSz = numel(ixPosRows);
    ixMedRows = find(ix < (medIx+0.01) & ix > (medIx-0.01)); medSz = numel(ixMedRows);
    
    fiveNeg = ixNegRows(randperm(negSz, 5));
    fivePos = ixPosRows(randperm(posSz, 5));
    fiveMed = ixMedRows(randperm(medSz, 5));
end
%%
    % plotting
plotBaseline = 200; x = numel(respFacePl{1, 1}{1, 1}); xx  = linspace(1, x, 100); y = numel(xx);
for nn = 1:numel(fiveNeg)
    fig =  figure; set(gcf, 'Visible', 'on', 'Position', [200 700 1100 200]) %, get(0, 'Screensize'))
    plFaceNeg = cell2mat(respFacePl{:, n}(fiveNeg(nn)));
    plBodyNeg = cell2mat(respBodyPl{:, n}(fiveNeg(nn)));
    plMonNeg = cell2mat(respMonPl{:, n}(fiveNeg(nn)));
    
    yy1 = interp1(1:x, plFaceNeg, xx, 'PCHIP');
    yy2 = interp1(1:x, plBodyNeg, xx, 'PCHIP');
    yy3 = interp1(1:x, plMonNeg, xx, 'PCHIP');
    plotXNeg = [yy1',yy2', yy3'];
    
    maxValue = max(plotXNeg(:))+2; minValue = min(plotXNeg(:))-2;
    for p = 1:3
        subplot(1, 3, p);
        if minValue<0
        set(gca, 'FontSize', 10, 'FontWeight','bold', 'XLim', [0, 35], 'XTick', 0:5:numel(plFaceNeg), 'XTickLabel', -plotBaseline:100:500, ...
            'YLim', [round(minValue), round(maxValue)], 'YTick', 0:10:round(maxValue)); %xtick from 0:5:35 and xlabel -200:100:500
        else
        set(gca, 'FontSize', 10, 'FontWeight','bold', 'XLim', [0, 35], 'XTick', 0:5:numel(plFaceNeg), 'XTickLabel', -plotBaseline:100:500, ...
            'YLim', [round(minValue), round(maxValue)]); %, 'YTick', 0:10:round(maxValue));
        end
        hold all
        plot(xx, plotXNeg(:, p), 'k', 'linewidth', 1);
        xlabel('Time', 'FontSize', 10, 'FontWeight','bold'), ylabel('Spikes/Second', 'FontSize', 10, 'FontWeight','bold');
    end
    figName1 = fullfile(outFolder, [names{n}, '_', num2str(nn), '_neg.png']); 
    figName2 = fullfile(outFolder, [names{n}, '_', num2str(nn), '_neg.svg']);
    saveas(fig, figName1); saveas(fig, figName2);
    close;
end
%%
for nn = 1:numel(fivePos)
    fig =  figure; set(gcf, 'Visible', 'on', 'Position', [200 700 1100 200]) %, get(0, 'Screensize'))
    plFacePos = cell2mat(respFacePl{:, n}(fivePos(nn)));
    plBodyPos = cell2mat(respBodyPl{:, n}(fivePos(nn)));
    plMonPos = cell2mat(respMonPl{:, n}(fivePos(nn)));
    
    yy1 = interp1(1:x, plFacePos, xx, 'PCHIP');
    yy2 = interp1(1:x, plBodyPos, xx, 'PCHIP');
    yy3 = interp1(1:x, plMonPos, xx, 'PCHIP');
    
    plotXPos = [yy1',yy2', yy3'];
    maxValue = max(plotXPos(:))+2; minValue = min(plotXPos(:))-2;
    for p = 1:3
        subplot(1, 3, p);
        if minValue<0
        set(gca, 'FontSize', 10, 'FontWeight','bold', 'XLim', [0, 35], 'XTick', 0:5:numel(plFaceNeg), 'XTickLabel', -plotBaseline:100:500, ...
            'YLim', [round(minValue), round(maxValue)], 'YTick', 0:10:round(maxValue)); %xtick from 0:5:35 and xlabel -200:100:500
        else
        set(gca, 'FontSize', 10, 'FontWeight','bold', 'XLim', [0, 35], 'XTick', 0:5:numel(plFaceNeg), 'XTickLabel', -plotBaseline:100:500, ...
            'YLim', [round(minValue), round(maxValue)]); %, 'YTick', 0:10:round(maxValue));
        end
        hold all
        plot(xx, plotXPos(:, p), 'k', 'linewidth', 1);
        xlabel('Time', 'FontSize', 10, 'FontWeight','bold'), ylabel('Spikes/Second', 'FontSize', 10, 'FontWeight','bold');
    end
    figName1 = fullfile(outFolder, [names{n}, '_', num2str(nn), '_pos.png']); 
    figName2 = fullfile(outFolder, [names{n}, '_', num2str(nn), '_pos.svg']);
    saveas(fig, figName1); saveas(fig, figName2);
    close;
end
%%
for nn = 1:numel(fiveMed)
    fig =  figure; set(gcf, 'Visible', 'on', 'Position', [200 700 1100 200]) %, get(0, 'Screensize'))
    plFaceMed = cell2mat(respFacePl{:, n}(fiveMed(nn)));
    plBodyMed = cell2mat(respBodyPl{:, n}(fiveMed(nn)));
    plMonMed = cell2mat(respMonPl{:, n}(fiveMed(nn)));
    
    yy1 = interp1(1:x, plFaceMed, xx, 'PCHIP');
    yy2 = interp1(1:x, plBodyMed, xx, 'PCHIP');
    yy3 = interp1(1:x, plMonMed, xx, 'PCHIP');
    
    plotXMed = [yy1',yy2', yy3'];
    
    maxValue = max(plotXMed(:))+2; minValue = min(plotXMed(:))-2;
    for p = 1:3
        subplot(1, 3, p);
        if minValue<0
        set(gca, 'FontSize', 10, 'FontWeight','bold', 'XLim', [0, 35], 'XTick', 0:5:numel(plFaceNeg), 'XTickLabel', -plotBaseline:100:500, ...
            'YLim', [round(minValue), round(maxValue)], 'YTick', 0:10:round(maxValue)); %xtick from 0:5:35 and xlabel -200:100:500
        else
        set(gca, 'FontSize', 10, 'FontWeight','bold', 'XLim', [0, 35], 'XTick', 0:5:numel(plFaceNeg), 'XTickLabel', -plotBaseline:100:500, ...
            'YLim', [round(minValue), round(maxValue)]); %, 'YTick', 0:10:round(maxValue));
        end
        hold all
        plot(xx, plotXMed(:, p), 'k', 'linewidth', 1);
        xlabel('Time', 'FontSize', 10, 'FontWeight','bold'), ylabel('Spikes/Second', 'FontSize', 10, 'FontWeight','bold');
    end
    figName1 = fullfile(outFolder, [names{n}, '_', num2str(nn), '_med.png']); 
    figName2 = fullfile(outFolder, [names{n}, '_', num2str(nn), '_med.svg']);
    saveas(fig, figName1); saveas(fig, figName2);
    close;
end