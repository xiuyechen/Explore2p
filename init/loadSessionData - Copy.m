function h = loadSessionData(h)
disp('loading proc data');

%% init (without data)
% h.vis.clrmaptype = 'hsv';
h.ops.plotLines = 1;
h.ops.haveFrameInfo = 0;

h.ops.isZscore = 1;


h.vis.clrmaptype = 'rand'; 

%% load data
root = 'C:\Users\xiuye\Documents\2P_processed\';

global isTesting
if isTesting
    filename1 = 'F_330873-A_2018-05-17_plane1_proc.mat';
    filepath1 = 'C:\Users\xiuye\Documents\2P_processed\Expore2p_demodata\withFrameInfo';
    
    load('C:\Users\xiuye\Documents\2P_processed\Expore2p_demodata\withFrameInfo\frameInfo.mat','frameInfo');
    h.ops.haveFrameInfo = 1;
    %     filename1 = 'F_m011_010918_plane1_proc.mat';
    %     filepath1 = 'C:\Users\xiuye\Documents\2P_processed\Expore2p_demodata\m011_010918_1';
else
    [filename1,filepath1]=uigetfile(fullfile(root, 'F*.mat'), 'Select Data File');
end

h_load = load(fullfile(filepath1, filename1));

if isfield(h_load,'dat') % proc.mat
    h.dat = h_load.dat;

else % this is a stub, not tested
    h.dat = h_load; % not proc...    
    
    %% mean image
    h.dat.maxmap = 2;
    ops = h.dat.ops;
    if isfield(ops, 'mimg1') && ~isempty(ops.mimg1)
        h.dat.mimg(:,:,h.dat.maxmap) = ops.mimg1(ops.yrange, ops.xrange);
        h.dat.mimg_proc(:,:,h.dat.maxmap) = normalize_image(h.dat.mimg(:,:,h.dat.maxmap));
    end
    h.dat.mimg(:,:,5) = 0;
end


%% init with data
% h.hfig = getParentFigure(hObject);
T = struct2table(h.dat.stat);

% h.M_0 = zscore(h.dat.Fcell{1},0,2);
% h.CellResp = prepFuncData(h);


h.IsCell = table2array(T(:,28));
h.absIX = find(h.IsCell);

% time points
h = parseFrameInfo(h,frameInfo);
h.ops.rangeBlocks = 1:h.timeInfo.nBlocks;
h.ops.rangeElm = 1:h.timeInfo.nElm; % this is for ops.isStimAvg = 1;
% default: ops.isStimAvg = 0;
tIX = getTimeIndex(h); % tIX = 1:h.timeInfo.nFrames;

% init cell selection to display
cIX = (1:length(h.absIX))';
gIX = (1:length(cIX))';
numK = max(gIX);

% init: manually set indices so that caching works...
h.cIX = cIX;
h.gIX = gIX;
h.numK = numK;
h.tIX = tIX;
h = updateIndices(h,cIX,gIX,numK,tIX);

end
