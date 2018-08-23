function cIX = roiIX2cIX(roiIX,IsCell)
% convert indices
% convert from roiIX... keep cells within roiIX
absIX = find(IsCell);
IX = ismember(absIX,roiIX);
cIX = find(IX);
end