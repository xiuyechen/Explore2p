function h = getIndexedData(h) % tIX input?
% This function updates variables depending on tIX (M_0,M,behavior,stim)
% Called after cIX or tIX is changed (e.g. setTimeIndex).

%% Inputs
tIX = h.tIX;
cIX_abs = h.cIX_abs;
% list ops
isZscore = h.ops.isZscore;
isStimAvg = h.ops.isStimAvg;

%% Main
if isStimAvg
    
    M = zeros(length(cIX_abs),h.timeInfo.nFrames);
    for ii = 1:length(cIX_abs)
        ichosen = cIX_abs(ii);

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
        M(ii,:) = y_m/10000;
    end
    %% averaging (for each element, and then concatenate)
    M_avg = [];
    for i = 1:length(tIX) % tIX is a cell
        IX = tIX{i};
        IX2 = IX';
        IX2 = IX2(:);
        M2 = M(:,IX2);
        M3 = reshape(M2,size(M2,1),size(IX,1),[]);
        this_avg = squeeze(mean(M3,2));
        M_avg = horzcat(M_avg,this_avg); %#ok<AGROW>
    end
    M = M_avg;

else % ~isStimAvg    
    
    M = zeros(length(cIX_abs),length(tIX));
    for ii = 1:length(cIX_abs)
        ichosen = cIX_abs(ii);
        
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
        M(ii,:) = y_m/10000;
    end
    
    if isZscore
        M = zscore(M,0,2);
    end
end

%% slice stim code
if isStimAvg
    IX = [];
    for ii = h.ops.rangeElm
        IX = horzcat(IX,h.timeInfo.stimmat{ii}(1,:)); %#ok<AGROW>
    end
    stim = h.timeInfo.stimCode(IX);
else
    stim = h.timeInfo.stimCode(tIX);
end

%% Output
h.M = M;
h.stim = stim;

end