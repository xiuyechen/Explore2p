function h = parseFrameInfo(h,frameInfo,nFrames)
% parseFrameInfo(h,frameInfo)
% parseFrameInfo(h,[],nFrames): when no frameInfo file exists, create scaffold

if isempty(frameInfo)
    
    stimCode = ones(1,nFrames);
    
    t = [];
    t.nFrames = nFrames;
    t.stimCode = ones(1,nFrames);
    t.pauseChunks = [];
    t.stimCodeValueArray = 1;
    t.stimCodeNameArray = {'all'};
    
    %     t.stimChunks = [];
    %     t.stimChunks(ii).ix = getElementIndices(stimCode, t.stimCodeValueArray(ii));
    %     t.stimChunks(ii).name = t.stimCodeNameArray{ii};
    %     t.stimChunks(ii).nReps = numel(t.stimChunks(ii).ix);
else
    
    rawcodes = extractfield(frameInfo, 'EventValue');
    
    [C,ia,ic] = unique(rawcodes);
    % C = [0,0.2,0.4,0.6,0.8,1]; % for test data
    stimCode = ic'-1; % codes are now integers. new code 0 corresponds to raw 0
    
    %% make time index structure
    t = [];
    
    t.nFrames = numel(stimCode);
    t.stimCode = stimCode;
    
    % manual input
    t.pauseChunks = getElementIndices(stimCode, 0); % codes size 1xn
    t.stimCodeValueArray = 1:(length(unique(stimCode))-1);%[0.2,0.4,0.6,0.8,1];% not counting 0
    if length(t.stimCodeValueArray)==5
        t.stimCodeNameArray = {'A','B','C','D','Grey'}; % manual
    else
        t.stimCodeNameArray = cell(1,length(t.stimCodeValueArray));
        for ii = 1:length(t.stimCodeValueArray)
            t.stimCodeNameArray{ii} = num2str(t.stimCodeValueArray(ii));
        end
    end
end
%%
% extract ix
t.stimChunks = [];
for ii = 1:numel(t.stimCodeValueArray)
    t.stimChunks(ii).ix = getElementIndices(stimCode, t.stimCodeValueArray(ii));
    t.stimChunks(ii).name = t.stimCodeNameArray{ii};
    t.stimChunks(ii).nReps = numel(t.stimChunks(ii).ix);
end

% find Blocks
nPauses = numel(t.pauseChunks);
t.blockStarts = 1;
t.blockStops = [];

if isempty(t.pauseChunks)
    t.blockStarts = 1;
    t.blockStops = nFrames;
else % have pause chunk
    
    if t.pauseChunks(end).ix(end) < numel(stimCode) % does not end on pause
        for ii = 1:nPauses
            t.blockStarts = [t.blockStarts,t.pauseChunks(ii).ix(end)+1];
        end
        
        for ii = 1:nPauses
            t.blockStops = [t.blockStops,t.pauseChunks(ii).ix(1)];
        end
        
        t.blockStops = [t.blockStops,numel(stimCode)];
    else % ends on pause
        for ii = 1:(nPauses-1)
            t.blockStarts = [t.blockStarts,t.pauseChunks(ii).ix(end)+1];
        end
        t.blockStops = [];
        for ii = 1:nPauses
            t.blockStops = [t.blockStops,t.pauseChunks(ii).ix(1)];
        end
    end
end

t.nBlocks = numel(t.blockStarts);
for ii = 1:t.nBlocks
    t.blockLength(ii) = t.blockStops(ii)-t.blockStarts(ii)+1;
    
end

%% trim stimChunks into matrices (trial length varies by one frame...)
t.nElm = length(t.stimChunks);
t.stimmat = cell(1,t.nElm);
for ii = 1:t.nElm
    s = t.stimChunks(ii).ix;
    
    m = zeros(1,length(s));
    for i = 1:length(s)
        m(i) = length(s(i).ix);
    end
    % figure;hist(m);
    elmlen = min(m);
    
    a = zeros(1,elmlen);
    for i = 1:length(s)
        a(i,:) = s(i).ix(1:elmlen);
    end
    
    t.stimmat{ii} = a;
end


%% output
h.timeInfo = t;

% init time ops
h.ops.rangeBlocks = 1:h.timeInfo.nBlocks;
h.ops.rangeElm = 1:h.timeInfo.nElm; % this is for ops.isStimAvg = 1;

end