clear all;
outFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\strMS_best\signWilcCases\');
dataDir = ('C:\Users\u0137276\Desktop\epDATA\expVP\strMS_best\');
load('a1bcnu.mat'); load('a2bcnu.mat'); load('p1bcnu.mat'); load('p2bcnu.mat');
load('a1fcnu.mat'); load('a2fcnu.mat'); load('p1fcnu.mat'); load('p2fcnu.mat');
str = [a1bcnu; a2bcnu; p1bcnu; p2bcnu; a1fcnu; a2fcnu; p1fcnu; p2fcnu]; 
baseline = 20;
latency = 5; % 50 ms latency
stimWin = 25; % 250 stim duration
% BC
nfbm0 = [2 1 3]; nfbm90 = [7 6 8]; nfbm180 = [12 11 13]; nfbm270 = [17 16 18]; % face, body, monkey, no f-b angle
ufbm0 = [4 1 5]; ufbm90 = [9 6 10]; ufbm180 = [14 11 15]; ufbm270 = [19 16 20]; % body zero, face 180, 90-270, 180-0, 270-90;
respN0b = []; respN90b = []; respN180b = []; respN270b = []; 
respU0b = []; respU90b = []; respU180b = []; respU270b = []; 
% FC
respN0f = []; respN90f = []; respN180f = []; respN270f = []; 
respU0f = []; respU90f = []; respU180f = []; respU270f = [];
%%
for k = 1:length(str)
    x = str(k).binMeanTrialFR;
    xx = str(k).binAllTrialsFR;
    cellNum = length(xx);
    respN0 = xx(:, nfbm0); respN0x = x(:, nfbm0);
    respN90 = xx(:, nfbm90); respN90x = x(:, nfbm90); 
    respN180 = xx(:, nfbm180); respN180x = x(:, nfbm180);
    respN270 = xx(:, nfbm270); respN270x = x(:, nfbm270);
    respU0 = xx(:, ufbm0); respU0x = x(:, ufbm0);
    respU90 = xx(:, ufbm90); respU90x = x(:, ufbm90);
    respU180 = xx(:, ufbm180); respU180x = x(:, ufbm180);
    respU270 = xx(:, ufbm270); respU270x = x(:, ufbm270);
    resp = [{respN0}; {respN90}; {respN180}; {respN270}; {respU0}; {respU90}; {respU180}; {respU270}]; % all trials
    respMean = [{respN0x}, {respN90x}, {respN180x}, {respN270x}, {respU0x}, {respU90x}, {respU180x}, {respU270x}]; % mean trial
    signP = [];
    for i=1:cellNum 
        signPose = [];
        for a = 1:length(resp)
            faceTR = resp{a}{i, 1};
            fbase = mean(faceTR(:, 1:baseline), 2);
            fwin = mean(faceTR(:, (baseline+latency+1):(baseline+latency+stimWin)), 2);
            meanBaseF = mean(faceTR(:, 1:baseline), 'all');
            meanRespF = mean(faceTR(:, (baseline+latency+1):(baseline+latency+stimWin)), 'all');
            diffF = meanRespF - meanBaseF;
            [pf, ~, ~] = signrank(fbase, fwin, 'tail', 'left', 'method', 'approximate');

            bodyTR = resp{a}{i, 2};
            bbase = mean(bodyTR(:, 1:baseline), 2);
            bwin = mean(bodyTR(:, (baseline+latency+1):(baseline+latency+stimWin)), 2);
            meanBaseB = mean(bodyTR(:, 1:baseline), 'all');
            meanRespB = mean(bodyTR(:, (baseline+latency+1):(baseline+latency+stimWin)), 'all');
            diffB = meanRespB - meanBaseB;
            [pb, ~, ~] = signrank(bbase, bwin, 'tail', 'left', 'method', 'approximate');
 
            monTR = resp{a}{i, 3};
            mbase = mean(monTR(:, 1:baseline), 2);
            mwin = mean(monTR(:, (baseline+latency+1):(baseline+latency+stimWin)), 2);
            meanBaseM = mean(monTR(:, 1:baseline), 'all');
            meanRespM = mean(monTR(:, (baseline+latency+1):(baseline+latency+stimWin)), 'all');
            diffM = meanRespM - meanBaseM;           
            [pm, ~, ~] = signrank(mbase, mwin, 'tail', 'left', 'method', 'approximate');
            
            if (pf <= 0.05 && diffF > 0) || (pb <= 0.05 && diffB > 0) || (pm <= 0.05 && diffM > 0)
                signPose = [signPose; a];
            end    
        end
        signP{i} = signPose; 
        signPoses{k} = signP;
    end
    nonRespCells{k} = find(cellfun(@isempty, signP));
    allPoses = [];
    for d = 1:numel(signP)
        pp = signP{d};
        allPoses = [allPoses; pp];
    end
    Ix = []; poseN = []; fR = []; bR = []; mR = [];
    for ii=1:cellNum
        if isempty(signP{ii})==1
            continue
        else
        for n = 1:numel(signP{ii})
            rr{n} = respMean{signP{ii}(n)}(ii, 1:size(respMean{1}, 2));
        end
        for a = 1:numel(rr)
            faceR = rr{a}{1};
            faceNet = faceR - (mean(faceR(11:baseline)));
            netSWF = faceNet((baseline+latency+1):(baseline+latency+stimWin));
            mNetSWF = mean(netSWF);
            
            bodyR = rr{a}{2};
            bodyNet = bodyR - (mean(bodyR(11:baseline)));
            netSWB = bodyNet((baseline+latency+1):(baseline+latency+stimWin));
            mNetSWB = mean(netSWB);
            
            fbSum = mNetSWF + mNetSWB;
            monR = rr{a}{3};
            monNet = monR - (mean(monR(11:baseline)));
            netSWM = monNet((baseline+latency+1):(baseline+latency+stimWin));
            mNetSWM = mean(netSWM);
            
            indIx = (mNetSWM - fbSum)/(abs(mNetSWM) + abs(fbSum));
            Ix = [Ix; indIx]; poseN = [poseN; signP{ii}(a)];
            fR = [fR; mNetSWF]; bR = [bR; mNetSWB]; mR = [mR; mNetSWM];
        end
        clear rr   
        end
    end
    IIx{k} = Ix; poseNum{k} = poseN; fResp{k} = fR; bResp{k} = bR; mResp{k} = mR;
end
%%
ss.IIx = IIx; 
ss.poseNum = poseNum;
ss.fResp = fResp;
ss.bResp = bResp;
ss.mResp = mResp;
ss.nonRespCells = nonRespCells;
ss.bestPoses = signPoses;
ss.poseOrder = [{'fbmN0'}; {'fbmN90'}; {'fbmN180'}; {'fbmN270'}; {'fbmU0'}; {'fbmU90'}; {'fbmU180'}; {'fbmU270'}];
ss.areaOrder = [{'a1bcnu'}; {'a2bcnu'}; {'p1bcnu'}; {'p2bcnu'}; {'a1fcnu'}; {'a2fcnu'}; {'p1fcnu'}; {'p2fcnu'}];
% save('InteractionIndexSignCases.mat', 'ss');
%% % to check the poses!!!!
% clear all;
% load('InteractionIndexSignCases.mat');
rowsInd1 = find(ss.IIx{1} < -0.9);
rowsInd2 = find(ss.IIx{2} < -0.9);
rowsInd3 = find(ss.IIx{3} < -0.9);
rowsInd4 = find(ss.IIx{4} < -0.9);
rowsInd5 = find(ss.IIx{5} < -0.9);
rowsInd6 = find(ss.IIx{6} < -0.9);
rowsInd7 = find(ss.IIx{7} < -0.9);
rowsInd8 = find(ss.IIx{8} < -0.9);


rowsPose1 = ss.poseNum{1}(rowsInd1);
rowsPose2 = ss.poseNum{2}(rowsInd2);
rowsPose3 = ss.poseNum{3}(rowsInd3);
rowsPose4 = ss.poseNum{4}(rowsInd4);
rowsPose5 = ss.poseNum{5}(rowsInd5);
rowsPose6 = ss.poseNum{6}(rowsInd6);
rowsPose7 = ss.poseNum{7}(rowsInd7);
rowsPose8 = ss.poseNum{8}(rowsInd8);

ant = [rowsPose1; rowsPose2; rowsPose5; rowsPose6];
pos = [rowsPose3; rowsPose4; rowsPose7; rowsPose8];

antU = find(ant > 4); % find the unnatural poses
posU = find(pos > 4); 

antPropU = numel(antU)/numel(ant);
posPropU = numel(posU)/numel(pos);


