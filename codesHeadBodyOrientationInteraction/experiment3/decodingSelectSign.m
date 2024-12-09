clear all;
dataFolderS1 = ('E:\plexonData\nexData\VP\results\P1\VP\signAZK\mat\');
dataFolderS2 = ('E:\plexonData\nexData\VP\results\P2\VP\signAZK\mat\');
dataFolderD1 = ('E:\plexonData\nexData\VP\results\P1\decoding\strAll\');
dataFolderD2 = ('E:\plexonData\nexData\VP\results\P2\decoding\strAll\');
outFolder1 = ('E:\plexonData\nexData\VP\results\P1\decoding\strSign\');
outFolder2 = ('E:\plexonData\nexData\VP\results\P2\decoding\strSign\');
addpath(dataFolderS1); addpath(dataFolderS2); addpath(dataFolderD1); addpath(dataFolderD2);
filesS1 = dir([dataFolderS1, '*.mat']);
filesS2 = dir([dataFolderS2, '*.mat']);
filesD1 = dir([dataFolderD1, '*.mat']);
filesD2 = dir([dataFolderD2, '*.mat']);
num = numel(filesS1);
%%
for a = 1:num
    str = load(filesS1(a).name);
    spl = split(filesS1(a).name, '_');
    ss = [strjoin(spl(1:2), '_'), '_VP3'];
    fn = fieldnames(str.(ss));
    if isempty(fn) == 0
    s1Names{a} = fn;       
    end
end
%%
for a = 1:num
    str = load(filesS2(a).name);
    spl = split(filesS2(a).name, '_');
    ss = [strjoin(spl(1:2), '_'), '_VP3'];
    fn = fieldnames(str.(ss));
    if isempty(fn) == 0
    s2Names{a} = fn;       
    end
end   
%%
for a = 1:num
    str = load(filesD1(a).name);
    spl = split(filesD1(a).name, '_');
    ss = strjoin(spl(1:3), '_');
    fn = fieldnames(str.(ss));
    if isempty(fn) == 0
    excl = setdiff(fn, s1Names{a});
    newD1 = rmfield(str.(ss), excl);
    for s = 1:numel(s1Names{a})
        newD1Name = fullfile(outFolder1, strcat(ss, '_', s1Names{a}{s}));
        newStr = newD1.(s1Names{a}{s});
%         save(newD1Name, '-struct', 'newStr');
    end
    end
end
%%
for a = 1:num
    str = load(filesD2(a).name);
    spl = split(filesD2(a).name, '_');
    ss = strjoin(spl(1:3), '_');
    fn = fieldnames(str.(ss));
    if isempty(fn) == 0
    excl = setdiff(fn, s2Names{a});
    newD2 = rmfield(str.(ss), excl);
    for s = 1:numel(s2Names{a})
        newD2Name = fullfile(outFolder2, strcat(ss, '_', s2Names{a}{s}));
        newStr = newD2.(s2Names{a}{s});
%         save(newD2Name, '-struct', 'newStr');
    end
    end
end
