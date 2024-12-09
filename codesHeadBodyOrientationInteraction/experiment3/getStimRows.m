clear all;
outFolder = ('E:\plexonData\nexData\VP\results\');
dataDir = ('E:\plexonData\nexData\VP\results\str\');
files = dir([dataDir, '*VP3_str.mat']);
num = numel(files);
%%
% get condition rows
str = load(files(1).name);
spl = split(files(1).name, '_');
ss = strjoin(spl(1:3), '_');
fn = fieldnames(str.(ss));
nuR1 = find(contains(str.(ss).(fn{1}).Stim, 'P1_B0_F0') | contains(str.(ss).(fn{1}).Stim, 'P1_B0_F180') ...
    | contains(str.(ss).(fn{1}).Stim, 'P1_B90_F90') | contains(str.(ss).(fn{1}).Stim, 'P1_B90_F270') ...
    | contains(str.(ss).(fn{1}).Stim, 'P1_B270_F270') | contains(str.(ss).(fn{1}).Stim, 'P1_B270_F90') ...
    | contains(str.(ss).(fn{1}).Stim, 'P1_B180_F180') | contains(str.(ss).(fn{1}).Stim, 'P1_B180_F0'));
nuR2 = find(contains(str.(ss).(fn{1}).Stim, 'P2_B0_F0') | contains(str.(ss).(fn{1}).Stim, 'P2_B0_F180') ...
    | contains(str.(ss).(fn{1}).Stim, 'P2_B90_F90') | contains(str.(ss).(fn{1}).Stim, 'P2_B90_F270') ...
    | contains(str.(ss).(fn{1}).Stim, 'P2_B270_F270') | contains(str.(ss).(fn{1}).Stim, 'P2_B270_F90') ...
    | contains(str.(ss).(fn{1}).Stim, 'P2_B180_F180') | contains(str.(ss).(fn{1}).Stim, 'P2_B180_F0'));
VPR1 = find(contains(str.(ss).(fn{1}).Stim, 'P1_') & contains(str.(ss).(fn{1}).Stim, '_M'));
VPR2 = find(contains(str.(ss).(fn{1}).Stim, 'P2_') & contains(str.(ss).(fn{1}).Stim, '_M'));
%% 
stimCat = {'NU1', 'NU2', 'VP1', 'VP2'};
rowsNU1 = [{nuR1}];
rowsNU2 = [{nuR2}];
rowsVP1 = [{VPR1}];
rowsVP2 = [{VPR2}];
%%
st.stimCat = stimCat;
st.rowsNU1 = rowsNU1;
st.rowsNU2 = rowsNU2;
st.rowsVP1 = rowsVP1;
st.rowsVP2 = rowsVP2;
strName = ([outFolder, 'stimCatRows.mat']);
save(strName, '-struct', 'st');
