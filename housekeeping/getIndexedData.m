function h = getIndexedData(h) % tIX input?
% This function updates variables depending on tIX (M_0,M,behavior,stim)
% Called after cIX or tIX is changed (e.g. setTimeIndex).

% list ops
isZscore = h.ops.isZscore;
isStimAvg = h.ops.isStimAvg;

%% input imaging data

% main data input
% if ~isZscore,
%     cellResp = getappdata(hfig,'CellResp');
%     cellRespAvr = getappdata(hfig,'CellRespAvr');
% else
%     cellResp = getappdata(hfig,'CellRespZ');
%     cellRespAvr = getappdata(hfig,'CellRespAvrZ');
% end

%%


if isStimAvg
    
    M = zeros(length(h.cIX_abs),h.timeInfo.nFrames);
    for ii = 1:length(h.cIX_abs)
        ichosen = h.cIX_abs(ii);
        %     igroup = gIX(ii);
        
        
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
    %%
    M_avg = [];
    for i = 1:length(h.tIX) % tIX is a cell
        IX = h.tIX{i};
        IX2 = IX';
        IX2 = IX2(:);
        M2 = M(:,IX2);
        M3 = reshape(M2,size(M2,1),size(IX,1),[]);
        this_avg = squeeze(mean(M3,2));
        M_avg = horzcat(M_avg,this_avg); %#ok<AGROW>
    end
    M = M_avg;
else
    
    
    M = zeros(length(h.cIX_abs),length(h.tIX));
    for ii = 1:length(h.cIX_abs)
        ichosen = h.cIX_abs(ii);
        %     igroup = gIX(ii);
        
        
        F = [];
        Fneu = [];
        for j = 1:numel(h.dat.Fcell)
            F    = cat(2, F, h.dat.Fcell{j}(ichosen, :));
            Fneu = cat(2, Fneu, h.dat.FcellNeu{j}(ichosen, :));
        end
        coefNeu = 0.7 * ones(1, size(F,1));
        
        dF                  = F - bsxfun(@times, Fneu, coefNeu(:));
        y = double(dF(h.tIX));%my_conv_local(medfilt1(double(F), 3), 3);
        y_m = y-mean(y);
        M(ii,:) = y_m/10000;
        
    end
    
    if isZscore
        M = zscore(M,0,2);
    end
end
h.M = M;

%% get sliced stim code

if isStimAvg
    IX = [];
    for ii = h.ops.rangeElm
        IX = horzcat(IX,h.timeInfo.stimmat{ii}(1,:)); %#ok<AGROW>
    end
    h.stim = h.timeInfo.stimCode(IX);
else
    h.stim = h.timeInfo.stimCode(h.tIX);
end

end