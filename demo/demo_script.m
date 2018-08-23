%%
clear all; close all; clc


%% set MATLAB path
% set the Explore2p code folder as current directory
if true % set the
    scriptName = mfilename('fullpath');
    [code_dir, filename, fileextension]= fileparts(scriptName);
    addpath(genpath(code_dir));
    cd(code_dir)
    
else
    % (hard-coded, customize here)
    folder = 'C:\Users\xiuye\Dropbox\!Research\2Pcode\Explore2p'; %#ok<UNRCH>
    addpath(genpath(folder));
    cd(folder)
end

% %% launch GUI
% hGUI = Explore2p;
% 
% % and load some data (if not automatically loading default session)

%% Create ImageClass object
h = ImageClass(); 

%% Load imaging data
% format: 
% file 1: Suite2p output *proc.mat, curated ROI's from a single session
% file 2(recommended): frameInfo.mat, containing

if true
    % this flag loads the default demo session
    global isDemo; %#ok<TLEV>
    isDemo = true;
else
    % otherwise, customize and load with the following code:
    h_load = load(fullFileName_s2p); %#ok<UNRCH>
    h.dat = h_load.dat;
    load(fullFileName_frameInfo,'frameInfo');
    h = initSessionData(h,frameInfo);
end

% load
h = loadSessionData(h);

%% draw functional traces and anatomy map
% make blank figure
hfig0 = figure('Position',[200,200,1280,648]);
% draw
refreshFigure(h,hfig0);

%% view functional data of all curated cells vs. all segemented ROIs
figure;
subplot(1,2,1);
imagesc(h.M) % all 'selected' cells, initialized to all cells during load
xlabel('frames')
ylabel('cell ID')

subplot(1,2,2);
imagesc(h.M_0) % all segemented ROIs
xlabel('frames')
ylabel('ROI ID')

%% select subset of cells
cIX = h.cIX; % currently selected indices (originally named for Cell Indices, now also used when selecting ROI's)
gIX = h.gIX; % group index (originally used to assign cluster id; used to show different clusters in different colors)

cIX = cIX(1:5:end);
gIX = gIX(1:5:end);

h = updateIndices(h,h.cellvsROI,cIX,gIX);

hfig1 = figure('Position',[200,200,1280,648]);
refreshFigure(h,hfig1);

%% select subset of time-frames
tIX = h.tIX; % time indices, frame by frame

tIX = tIX(1:round(length(tIX)/10));

h = updateIndices(h,h.cellvsROI,tIX);
hfig2 = figure('Position',[200,200,1280,648]);
refreshFigure(h,hfig2);

