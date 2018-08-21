function h = loadSessionData(h)
disp('loading proc data');

%% load data
root = 'C:\Users\xiuye\Documents\2P_processed\';

global isTesting
if isTesting
    % load suite2p output data
    filename1 = 'F_330873-A_2018-05-17_plane1_proc.mat';
    filepath1 = 'C:\Users\xiuye\Documents\2P_processed\Expore2p_demodata\withFrameInfo';
    h_load = load(fullfile(filepath1, filename1));
    
    % load frameInfo
    load('C:\Users\xiuye\Documents\2P_processed\Expore2p_demodata\withFrameInfo\frameInfo.mat','frameInfo');
    h.ops.haveFrameInfo = 1;
else
    % UI choose session
    [filename1,filepath1]=uigetfile(fullfile(root, 'F*.mat'), 'Select Data File');
    if isequal(filename1,0)
        disp('(File selection cancelled)')
        return;
    end

    % load suite2p output data
    h_load = load(fullfile(filepath1, filename1));
    
    % load frameInfo (if applicable)
    try
        load(fullfile(filepath1, 'frameInfo.mat'),'frameInfo');
        h.ops.haveFrameInfo = 1;
    catch
        [filename1,filepath1]=uigetfile(fullfile(root, '*.mat'), 'Select frameInfo File');
        if isequal(filename1,0)
            h.ops.haveFrameInfo = 0;
        else
            try
                load(fullfile(filepath1, filename1),'frameInfo.mat','frameInfo');
            catch
                errordlg('frameInfo invalid, no stimulus/motor information loaded');
                h.ops.haveFrameInfo = 0;
            end
        end
    end
end
%% save to GUI data
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
T = struct2table(h.dat.stat);
h.IsCell = table2array(T(:,28));
% h.absIX = find(h.IsCell);
h.IsChosen = h.IsCell;
h.ops.cellvsROI = 1;
set(h.gui.cellRange,'BackgroundColor',[1,1,0.8]);
set(h.gui.ROIrange,'BackgroundColor',[1,1,1]);

% time points
if h.ops.haveFrameInfo
    h = parseFrameInfo(h,frameInfo);
else
    % get number of frames from functional trace
    F = [];
    for j = 1:numel(h.dat.Fcell)
        F = cat(2, F, h.dat.Fcell{j}(1, :));
    end
    nFrames = length(F);    
    h = parseFrameInfo(h,[],nFrames);
end

set(h.gui.framerange,'ToolTipString',['1-',num2str(h.timeInfo.nFrames)]);
set(h.gui.elementrange,'ToolTipString',['1-',num2str(h.timeInfo.nElm)]);
set(h.gui.blockrange,'ToolTipString',['1-',num2str(h.timeInfo.nBlocks)]);

% default: ops.isStimAvg = 0;
tIX = getTimeIndex(h); % tIX = 1:h.timeInfo.nFrames;

% init cell selection to display
cIX = (1:length(h.absIX))';
gIX = (1:length(cIX))';
numK = max(gIX);
cellvsROI = 1;

% init: manually set indices so that caching works...
h.cIX = cIX;
h.gIX = gIX;
h.numK = numK;
h.tIX = tIX;
h.cellvsROI = cellvsROI;
h = updateIndices(h,cellvsROI,cIX,gIX,numK,tIX);

end
