function  h = getColormap(h)
numK = h.numK;

if strcmp(h.clrmaptype,'hsv') % use HSV coding, which, in the Value channel includes information from 'lambda' (from ROI stats)    
    huemap = linspace(0,0.8,numK); % to make a custom hsv map that doesn't include the circular overlap range in magenta-red (by not using range 0 to 1)
    clrmap = squeeze(hsv2rgb(cat(3, huemap, ones(size(huemap)), ones(size(huemap)))));
    
    h.huemap = huemap';
elseif strcmp(h.clrmaptype,'rand')  % use RGB (not tested)
    H = horzcat(rand(numK,1),rand(numK,1),0.5+0.5*rand(numK,1));
    clrmap = hsv2rgb(H);    
elseif strcmp(h.clrmaptype,'jet')  % use RGB (not tested)
    clrmap = flipud(jet(numK));
elseif strcmp(h.clrmaptype,'hsv_old') % use HSV coding, which, in the Value channel includes information from 'lambda' (from ROI stats)    
    huemap = linspace(0,1,numK);
    clrmap = squeeze(hsv2rgb(cat(3, huemap, ones(size(huemap)), ones(size(huemap)))));
   
    h.huemap = huemap';
end

h.clrmap = clrmap;

end