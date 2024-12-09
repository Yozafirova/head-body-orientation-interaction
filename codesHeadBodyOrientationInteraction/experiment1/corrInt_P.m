clear all;
bs1=load('p1bc_stats.mat'); bs1=bs1.raw;
fs1=load('p1fc_stats.mat'); fs1=fs1.raw;
b1=load('p1bc.mat'); b1=b1.p1bc;
f1=load('p1fc.mat'); f1=f1.p1fc;
%
bs2=load('p2bc_stats.mat'); bs2=bs2.raw;
fs2=load('p2fc_stats.mat'); fs2=fs2.raw;
b2=load('p2bc.mat'); b2=b2.p2bc;
f2=load('p2fc.mat'); f2=f2.p2fc;
%
n1=load('corrR_pn1.mat'); n1=n1.corrR;
o1=load('corrR_po1.mat'); o1=o1.corrR;
n2=load('corrR_pn2.mat'); n2=n2.corrR;
o2=load('corrR_po2.mat'); o2=o2.corrR;
%%
intBC1 = b1.cells(bs1.Int, :); intFC1 = f1.cells(fs1.Int, :); 
cCellsBCo1 = length(find(contains(b1.mon(bs1.Int), 'o'))); 
cCellsFCo1 = length(find(contains(f1.mon(fs1.Int), 'o')));
intO1 = union(intBC1(1:cCellsBCo1), intFC1(1:cCellsFCo1));
comIntO1 = intersect(intBC1(1:cCellsBCo1), intFC1(1:cCellsFCo1));
intN1 = union(intBC1((cCellsBCo1+1):end), intFC1((cCellsFCo1+1):end));
comIntN1 = intersect(intBC1((cCellsBCo1+1):end), intFC1((cCellsFCo1+1):end));
%%
intBC2 = b2.cells(bs2.Int, :); intFC2 = f2.cells(fs2.Int, :); 
cCellsBCo2 = length(find(contains(b2.mon(bs2.Int), 'o'))); 
cCellsFCo2 = length(find(contains(f2.mon(fs2.Int), 'o')));
intO2 = union(intBC2(1:cCellsBCo2), intFC2(1:cCellsFCo2));
comIntO2 = intersect(intBC2(1:cCellsBCo2), intFC2(1:cCellsFCo2));
intN2 = union(intBC2((cCellsBCo2+1):end), intFC2((cCellsFCo2+1):end));
comIntN2 = intersect(intBC2((cCellsBCo2+1):end), intFC2((cCellsFCo2+1):end));
%%
allCellsBCo1 = length(find(contains(b1.mon, 'o'))); 
allCellsBCn1 = length(find(contains(b1.mon, 'n')));
allCellsFCo1 = length(find(contains(f1.mon, 'o'))); 
allCellsFCn1 = length(find(contains(f1.mon, 'n')));
allCellsBCo2 = length(find(contains(b2.mon, 'o'))); 
allCellsBCn2 = length(find(contains(b2.mon, 'n')));
allCellsFCo2 = length(find(contains(f2.mon, 'o'))); 
allCellsFCn2 = length(find(contains(f2.mon, 'n')));

comCellsO1 = length(intersect(b1.cells(1:allCellsBCo1), f1.cells(1:allCellsFCo1)));
comCellsO2 = length(intersect(b2.cells(1:allCellsBCo2), f2.cells(1:allCellsFCo2)));
% comCellsN1 = length(intersect(b1.cells((allCellsBCo1+1):end), f1.cells((allCellsFCo1+1):end)));
% comCellsN2 = length(intersect(b2.cells((allCellsBCo2+1):end), f2.cells((allCellsFCo2+1):end)));
%%
corrRowsO1 = find(ismember(b1.commonCells(1:comCellsO1), intO1));
corrRowsO2 = find(ismember(b2.commonCells(1:comCellsO2), intO2));
corrRowsN1 = find(ismember(b1.commonCells((comCellsO1+1):end), intN1));
corrRowsN2 = find(ismember(b2.commonCells((comCellsO2+1):end), intN2));

corrComRowsO1 = find(ismember(b1.commonCells(1:comCellsO1), comIntO1));
corrComRowsO2 = find(ismember(b2.commonCells(1:comCellsO2), comIntO2));
corrComRowsN1 = find(ismember(b1.commonCells((comCellsO1+1):end), comIntN1));
corrComRowsN2 = find(ismember(b2.commonCells((comCellsO2+1):end), comIntN2));
%%
allCorr = [o1; o2; n1; n2];
intCorr = [o1(corrRowsO1); o2(corrRowsO2); n1(corrRowsN1); n2(corrRowsN2)];
comIntCorr = [o1(corrComRowsO1); o2(corrComRowsO2); n1(corrComRowsN1); n2(corrComRowsN2)];
%%
% save('corrAll_P.mat', 'allCorr');
% save('corrInt_P.mat', 'intCorr');
% save('corrComInt_P.mat', 'comIntCorr');

