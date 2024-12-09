clear all;
n1a=load('corr_an1.mat'); n1ab=n1a.corrBRsb; n1af=n1a.corrFRsb;
o1a=load('corr_ao1.mat'); o1ab=o1a.corrBRsb; o1af=o1a.corrFRsb;
n2a=load('corr_an2.mat'); n2ab=n2a.corrBRsb; n2af=n2a.corrFRsb;
o2a=load('corr_ao2.mat'); o2ab=o2a.corrBRsb; o2af=o2a.corrFRsb;

n1p=load('corr_pn1.mat'); n1pb=n1p.corrBRsb; n1pf=n1p.corrFRsb;
o1p=load('corr_po1.mat'); o1pb=o1p.corrBRsb; o1pf=o1p.corrFRsb;
n2p=load('corr_pn2.mat'); n2pb=n2p.corrBRsb; n2pf=n2p.corrFRsb;
o2p=load('corr_po2.mat'); o2pb=o2p.corrBRsb; o2pf=o2p.corrFRsb;
%%
antB = [n1ab; n2ab; o1ab; o2ab];
posB = [n1pb; n2pb; o1pb; o2pb];
antF = [n1af; n2af; o1af; o2af];
posF = [n1pf; n2pf; o1pf; o2pf];
%%
[p, h, stats] = ranksum(antB, posB);
[p, h, stats] = ranksum(antF, posF);
median(antB)
%%
n1aRC=n1a.Rcorrected; n2aRC=n2a.Rcorrected;
o1aRC=o1a.Rcorrected; o2aRC=o2a.Rcorrected;
n1pRC=n1p.Rcorrected; n2pRC=n2p.Rcorrected;
o1pRC=o1p.Rcorrected; o2pRC=o2p.Rcorrected;

antRC = [n1aRC; n2aRC; o1aRC; o2aRC];
posRC = [n1pRC; n2pRC; o1pRC; o2pRC];
%%
median(antRC)
