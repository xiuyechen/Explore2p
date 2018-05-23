function h = updateTimeIndexedData(h)
% list ops
isZscore = h.ops.isZscore;

%% input imaging data

% main data input
if ~isZscore,
    cellResp = getappdata(hfig,'CellResp');
    cellRespAvr = getappdata(hfig,'CellRespAvr');
else
    cellResp = getappdata(hfig,'CellRespZ');
    cellRespAvr = getappdata(hfig,'CellRespAvrZ');
end

%%


M = zeros(length(h.cIX_abs),length(h.t_start:h.t_stop));
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
    y = double(dF(h.t_start:h.t_stop));%my_conv_local(medfilt1(double(F), 3), 3);
    y_m = y-mean(y);
    M(ii,:) = y_m/10000;
    
end
h.M = M;
end