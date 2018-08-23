function h = parseStimCode(h,stimCode,nFrames)
% parseFrameInfo(h,frameInfo)
% parseFrameInfo(h,[],nFrames): when no frameInfo file exists, create scaffold
%
% the frameInfo 

if isempty(stimCode)
    
    stimCode = ones(1,nFrames);
    
    t = [];
    t.nFrames = nFrames;
    t.stimCode = ones(1,nFrames);
    t.pauseChunks = [];
    t.stimCodeValueArray = 1;
    t.stimCodeNameArray = {'all'};
     
%     %     t.stimChunks = [];
%     %     t.stimChunks(ii).ix = getElementIndices(stimCode, t.stimCodeValueArray(ii));
%     %     t.stimChunks(ii).name = t.stimCodeNameArray{ii};
%     %     t.stimChunks(ii).nReps = numel(t.stimChunks(ii).ix);

else            
    %% make time index structure
    t = [];
    
    t.nFrames = numel(stimCode);
    t.stimCode = stimCode;
    
    % manual input
    t.pauseChunks = getElementIndices(stimCode, 0); % codes size 1xn % rest period between blocks of stimulation
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

%% find experitental "blocks" (between pauseChunks)
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

%% find stimulus chunks (raw, not trimmed in length)
% extract ix
t.stimChunks = [];
for ii = 1:numel(t.stimCodeValueArray)    
    % get stim chunks for each experimental block
    ix = cell(1,t.nBlocks);
    nReps = zeros(1,t.nBlocks);
    for jj = 1:t.nBlocks
        range = t.blockStarts(jj):t.blockStops(jj);
        x = nan(size(stimCode));
        x(range) = stimCode(range);
        ix{jj} = getElementIndices(x, t.stimCodeValueArray(ii));
        nReps(jj) = numel(ix{jj});
    end
    t.stimChunks(ii).ix = ix;
    t.stimChunks(ii).name = t.stimCodeNameArray{ii};
    t.stimChunks(ii).nReps = nReps;
end

%% trim stimChunks into matrices (trial length varies by one frame...)
t.nElm = length(t.stimChunks);
t.stimmat = cell(t.nBlocks,t.nElm);
for ii = 1:t.nElm
    s = cell2mat(t.stimChunks(ii).ix);
    nReps_total = sum(t.stimChunks(ii).nReps);
    
    % pool element length, and trim to same length across reps
    m = zeros(1,nReps_total);
    for i = 1:nReps_total
        m(i) = length(s(i).ix);
    end
    % figure;hist(m);
    elmlen = min(m); % chose element length here
    
    %%
    a = zeros(t.nBlocks,elmlen);
    for jj = 1:t.nBlocks
        s_ = t.stimChunks(ii).ix{jj};
        
        for i = 1:length(s_)
            a(i,:) = s_(i).ix(1:elmlen); % trim by element length
        end
        t.stimmat{jj,ii} = a;
    end
    
    
    %%
%     a = zeros(1,elmlen);
%     for i = 1:length(s)
%         a(i,:) = s(i).ix(1:elmlen); % trim by element length
%     end
%     
%     t.stimmat{ii} = a;
end


%% output
h.timeInfo = t;

% init time ops
h.ops.rangeBlocks = 1:h.timeInfo.nBlocks;
h.ops.rangeElm = 1:h.timeInfo.nElm; % this is for ops.isStimAvg = 1;

end