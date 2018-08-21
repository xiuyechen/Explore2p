 function h = updateROIindices(h,argin)
 % function h = updateROIindices(h,IsCell)
 % also works as function h = updateROIindices(h,roiIX)
 
 h.roiIX = find(argin);
 
 %% index with all ROI's
 h.absIX = (1:length(h.IsCell))'; % usually: h.absIX = find(h.IsCell);

 % convert roiIX input into new cIX, given the updated absIX
 h.cIX = h.roiIX;
 h.gIX = ones(size(h.cIX));
 
 h = updateIndices(h,h.cIX,h.gIX);
 
 end
 
%  function markROIasCell