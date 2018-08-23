function tIX = getTimeIndex(h)
% when time-relevant options are updated, this function computes the new tIX 
% options include: 
% - whether averaging based on stimulus repetitions
% - range of elements selected
% - range of experimental blocks selected
% 
% this can be further adapted to suit particular stimulus paradigms

%% inputs
t = h.timeInfo;
isStimAvg = h.ops.isStimAvg;
rangeElm = h.ops.rangeElm;
rangeBlocks = h.ops.rangeBlocks;

%% set tIX
if isStimAvg 
    tIX = cell(1,length(rangeElm));
    for ii = 1:length(rangeElm)
        i_elm = rangeElm(ii);
        tIX{ii} = cell2mat(t.stimmat(rangeBlocks,i_elm));        
    end

else
    tIX = [];
    for i_block = rangeBlocks
        tIX = [tIX, t.blockStarts(i_block):t.blockStops(i_block)]; %#ok<AGROW>
    end
end

end