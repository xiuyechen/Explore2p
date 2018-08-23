function h = getIndexedData(h)
% This function updates variables depending on currently selected cells (cIX) 
% and time indexing (tIX, e.g. depending on averaging or trimming in time).
% The outputs are saved under h:
% - M_0: functional data for all segmented ROIs (rows: ROI's; cols:
% time frames)
% - M: functional data for all currently selected cells/ROI's (rows:
% cells/ROI's; cols: time frames)
% - stim: stimulus code, matching the functional data
% (if applicable, modify code to output behavior in parallel with stim)
%
% The function is mainly called in updateIndices(), after either cIX or tIX is changed

%% Inputs
tIX = h.tIX;
roiIX = h.roiIX; % this calculates the ROI indices corresponding to cIX, see ImageClass def

% options
isZscore = h.ops.isZscore;
isStimAvg = h.ops.isStimAvg;

nROIs = h.nROIs; %length(h.IsCell);

%% Main
if isStimAvg
    
    M_0 = zeros(nROIs,h.timeInfo.nFrames);
    for ii = 1:nROIs
        ichosen = ii;
        
        F = [];
        Fneu = [];
        for j = 1:numel(h.dat.Fcell)
            F    = cat(2, F, h.dat.Fcell{j}(ichosen, :));
            Fneu = cat(2, Fneu, h.dat.FcellNeu{j}(ichosen, :));
        end
        coefNeu = 0.7 * ones(1, size(F,1));
        
        dF                  = F - bsxfun(@times, Fneu, coefNeu(:));
        y = double(dF);%my_conv_local(medfilt1(double(F), 3), 3);
        y_m = y-mean(y);
        M_0(ii,:) = y_m;%/10000;
    end
    
    %% averaging (for each element, and then concatenate)
    M_avg_0 = [];
    for i = 1:length(tIX) % tIX is a cell
        IX = tIX{i};
        IX2 = IX';
        IX2 = IX2(:);
        M2 = M_0(:,IX2);
        M3 = reshape(M2,size(M2,1),size(IX,1),[]);
        this_avg = squeeze(mean(M3,2));
        M_avg_0 = horzcat(M_avg_0,this_avg); %#ok<AGROW>
    end
    M_0 = M_avg_0;
    
else % ~isStimAvg
    
    M_0 = zeros(nROIs,length(tIX));
    for ii = 1:nROIs
        ichosen = ii;%roiIX(ii);dbquit
        
        
        F = [];
        Fneu = [];
        for j = 1:numel(h.dat.Fcell)
            F    = cat(2, F, h.dat.Fcell{j}(ichosen, :));
            Fneu = cat(2, Fneu, h.dat.FcellNeu{j}(ichosen, :));
        end
        coefNeu = 0.7 * ones(1, size(F,1));
        
        dF                  = F - bsxfun(@times, Fneu, coefNeu(:));
        y = double(dF(tIX));%my_conv_local(medfilt1(double(F), 3), 3);
        y_m = y-mean(y);
        M_0(ii,:) = y_m;%/10000;
    end
    
    if isZscore
        M_0 = zscore(M_0,0,2);
    end
end

M = M_0(roiIX,:);

%% slice stim code
if isStimAvg
    IX = getStimAvgTimeIndex(h);    
    stim = h.timeInfo.stimCode(IX);
else
    stim = h.timeInfo.stimCode(tIX);
end

%% Output
h.M = M;
h.M_0 = M_0;
h.stim = stim;

end