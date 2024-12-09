clear all;
dataFolderS = ('E:\plexonData\nexData\P2\results\NU\signAZK\mat\');
dataFolderD = ('E:\plexonData\nexData\P2\results\NU\decoding\mat\');
outFolder = ('E:\plexonData\nexData\P2\results\NU\decoding\sign\');
addpath(dataFolderS); addpath(dataFolderD); 
filesS = dir([dataFolderS, '*.mat']);
filesD = dir([dataFolderD, '*.mat']);
num = numel(filesS);
%%
for a = 1:num
    str = load(filesS(a).name);
    spl = split(filesS(a).name, '_');
    ss = [strjoin(spl(1:2), '_'), '_P2'];
    fn = fieldnames(str.(ss));
    if isempty(fn) == 0
    sNames{a} = fn;       
    end
end  
%%
for a = 1:num
    str = load(filesD(a).name);
    ss = fieldnames(str);
    fn = fieldnames(str.(ss{:}));
    if isempty(fn) == 0
    excl = setdiff(fn, sNames{a});
    newD = rmfield(str.(ss{:}), excl);
    for s = 1:numel(sNames{a})
        newDName = fullfile(outFolder, strcat(ss{:}, '_', sNames{a}{s}));
        newStr = newD.(sNames{a}{s});
        save(newDName, '-struct', 'newStr');
    end
    end
end
