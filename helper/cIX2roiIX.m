function roiIX = cIX2roiIX(cIX,IsCell)
% convert indices, from cIX to roiIX
absIX = find(IsCell);
roiIX = absIX(cIX);
end


   

