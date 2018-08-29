function h = initSessionData(h,frameInfo)
% init with freshly loaded h.dat
% h = initSessionData(h,frameInfo)
% h = initSessionData(h)

% get IsCell from input data
T = struct2table(h.dat.stat);
h.IsCell = table2array(T(:,28));

% for pre-curated input data (Suite2p output but not *proc.mat)
if length(find(h.IsCell))==0 %#ok<ISMT>
    h.IsCell = ones(size(h.IsCell));
end

% parse frameInfo (extract stimCode; TODO: add behavior)
if exist('frameInfo','var')
    h.ops.haveFrameInfo = 1;
    [stimCode,stimCodeNameArray] = get_stimCode_from_frameInfo_API(frameInfo);    
    h = parseStimCode(h,stimCode);
    h.timeInfo.stimCodeNameArray = stimCodeNameArray;
else
    h.ops.haveFrameInfo = 0;
    % make dummy stimCode
    % get number of frames from functional trace
    F = [];
    for j = 1:numel(h.dat.Fcell)
        F = cat(2, F, h.dat.Fcell{j}(1, :));
    end
    nFrames = length(F);
    h = parseStimCode(h,[],nFrames);
end

% init time point info for GUI
if ~isempty(h.hfig)
    set(h.gui.framerange,'ToolTipString',['1-',num2str(h.timeInfo.nFrames)]);
    set(h.gui.elementrange,'ToolTipString',['1-',num2str(h.timeInfo.nElm),', for stim-avg only']);
    set(h.gui.blockrange,'ToolTipString',['1-',num2str(h.timeInfo.nBlocks)]);
end

% init current selection to display (see ImageClass classdef)
cellvsROI = 1;
cIX = (1:length(find(h.IsCell)))';
gIX = (1:length(cIX))';
numK = max(gIX);
tIX = getTimeIndex(h);

% manually set indices to init caching
h.cIX = cIX;
h.gIX = gIX;
h.numK = numK;
h.tIX = tIX;
h.cellvsROI = cellvsROI;

% update
h = setCellvsROI(h);
h = updateIndices(h,cellvsROI,cIX,gIX,numK,tIX);
