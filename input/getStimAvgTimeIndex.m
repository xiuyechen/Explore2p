function IX = getStimAvgTimeIndex(h)
% get indexing for one period (of the stimulus presentation) only
% e.g. used at the end of getIndexedData for slicing stimulus code
IX = [];
for ii = h.ops.rangeElm
    IX = horzcat(IX,h.timeInfo.stimmat{1,ii}(1,:)); %#ok<AGROW>
end
end