function h = parseFrameInfo(h,frameInfo)

codes = extractfield(frameInfo, 'EventValue');

%% make time index structure
t = [];

t.codes = codes;
t.nFrames = numel(codes);

% manual input
t.pauseChunks = getElementIndices(codes, 0);
t.stimCodeValueArray = [0.2,0.4,0.6,0.8,1];
t.stimCodeNameArray = {'A','B','C','D','Grey'};

% extract ix
t.stimChunks = [];
for ii = 1:numel(t.stimCodeValueArray)
    t.stimChunks(ii).ix = getElementIndices(codes, t.stimCodeValueArray(ii));
    t.stimChunks(ii).name = t.stimCodeNameArray{ii};
    t.stimChunks(ii).nReps = numel(t.stimChunks(ii).ix);
end

% find Blocks
nPauses = numel(t.pauseChunks);
t.blockStarts = 1;
t.blockStops = [];

if t.pauseChunks(end).ix(end) < numel(codes) % does not end on pause
    for ii = 1:nPauses
        t.blockStarts = [t.blockStarts,t.pauseChunks(ii).ix(end)+1];
    end
    
    for ii = 1:nPauses
        t.blockStops = [t.blockStops,t.pauseChunks(ii).ix(1)];
    end
    
    t.blockStops = [t.blockStops,numel(codes)];
else % ends on pause
    for ii = 1:(nPauses-1)
        t.blockStarts = [t.blockStarts,t.pauseChunks(ii).ix(end)+1];
    end
    t.blockStops = [];
    for ii = 1:nPauses
        t.blockStops = [t.blockStops,t.pauseChunks(ii).ix(1)];
    end
end

t.nBlocks = numel(t.blockStarts);
for ii = 1:t.nBlocks
   t.blockLength(ii) = t.blockStops(ii)-t.blockStarts(ii)+1; 
   
end

h.timeInfo = t;

end