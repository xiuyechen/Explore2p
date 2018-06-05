function ix = getElementIndices(codes, eltCode, varargin)
% GETELEMENTINDICES Returns indices that define where a particular stimulus 
% element occurs. By default, a struct array is returned where each
% structure has the field 'ix'. Each struct in the array represents all of
% the frames captured during the presentation of one element. If you don't
% care to have the indices separated by presentation, then use 
% getElementIndices(..., 'Collapse', true) and a vector containing all the
% indices will be returned.

collapse = parseVarargin(varargin, 'Collapse', false);

% Prepare the return value.
ix = struct('ix', {});

% Make an indicator function, and find where it rises and falls.
% indicator = int32([0, codes == eltCode, 0]);
indicator = [0, abs(codes - eltCode)<eps, 0];

% If this stimulus isn't found, return immediately.
if ~any(indicator)
    if collapse
        ix = [];
    end
    return
end

indicatorDiffs = diff(indicator);
indicatorChanged = int32(find(indicatorDiffs));
indicatorRise = indicatorChanged(1:2:end);
indicatorFall = indicatorChanged(2:2:end);
assert(length(indicatorRise) == length(indicatorFall));

for ii=1:length(indicatorRise)
    start =  indicatorRise(ii);
    stop  =  indicatorFall(ii) - 1;
    ix(length(ix)+1) =  struct('ix', start:stop);
end

if collapse
    allIx = [];
    for ii=1:length(ix)
        allIx = [allIx ix(ii).ix]; %#ok<AGROW>
    end
    ix = allIx;
end

end

