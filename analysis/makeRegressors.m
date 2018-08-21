function reg = makeRegressors(h)
t = h.timeInfo;
reg_raw = zeros(t.nFrames,1);
IX = t.stimChunks(h.ops.i_stim).ix;
% collapse
allIx = [];
for ii = 1:length(IX)
    allIx = [allIx IX(ii).ix]; %#ok<AGROW>
end
IX = allIx;
reg_raw(IX) = 1;
if h.ops.isStimAvg
    IX = [];
    for ii = h.ops.rangeElm
        IX = horzcat(IX,t.stimmat{ii}(1,:)); %#ok<AGROW>
    end
    reg = reg_raw(IX);
else
    reg = reg_raw(h.tIX);
end

end