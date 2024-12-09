% open the function, you need to change things there too 
clear all;
dataFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\decoding\A2\');
addpath(dataFolder);
outFolder = ('C:\Users\u0137276\Desktop\epDATA\expVP\decodingMatlab\A2\bins\A2_M'); % the last letters are part of the name
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
% IMPORTANT! 
%%% Go to the function and add raster_data and raster_labels;change accordingly %%%% row 176;

% binWidth = 250; % can be different bins e.g. [50 40 100]
% samplingInt = 250; % start times of bins [10 50 40]
% startTime = 251; % start and end time are normally optional; use it if you want one bin
% endTime = 500;

startTime = 201; % from stim onset to 350 ms
endTime = 550;
binWidth = 40; % can be different bins e.g. [50 40 100]
samplingInt = 10; % start times of bins [10 50 40]

% binWidth = 10; % can be different bins e.g. [50 40 100]
% samplingInt = 10; % start times of bins [10 50 40]

create_binned_data_from_raster_data(dataFolder, outFolder, binWidth, samplingInt, startTime, endTime);
% create_binned_data_from_raster_data(dataFolder, outFolder, binWidth, samplingInt);