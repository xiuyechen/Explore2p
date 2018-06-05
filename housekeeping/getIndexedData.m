function h = getIndexedData(h)
% This function updates variables depending on tIX (M_0,M,behavior,stim)
% Called after cIX or tIX is changed (e.g. setTimeIndex).

% list ops
isZscore = h.ops.isZscore;

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
h.M = M;


% isTrialRes = getappdata(hfig,'isTrialRes');
% isClusRes = getappdata(hfig,'isClusRes');
% 
% % main data input
% if ~isZscore,
%     cellResp = getappdata(hfig,'CellResp');
%     cellRespAvr = getappdata(hfig,'CellRespAvr');
% else
%     cellResp = getappdata(hfig,'CellRespZ');
%     cellRespAvr = getappdata(hfig,'CellRespAvrZ');
% end
% 
% isMotorseed = getappdata(hfig,'isMotorseed');
% if ~isMotorseed,
%     Behavior_full = getappdata(hfig,'Behavior_full');
%     BehaviorAvr = getappdata(hfig,'BehaviorAvr');
% else
%     Behavior_full = getappdata(hfig,'Behavior_full_motorseed');
%     BehaviorAvr = getappdata(hfig,'BehaviorAvr_motorseed');
% end
% stim_full = getappdata(hfig,'stim_full');
% stimAvr = getappdata(hfig,'stimAvr');
% % other params
% isStimAvr = getappdata(hfig,'isStimAvr');
% cIX = getappdata(hfig,'cIX');
% tIX = getappdata(hfig,'tIX');
% % absIX = getappdata(hfig,'absIX');
% 
% %% set data
% isFullData = getappdata(hfig,'isFullData');
% if isFullData
%     
%     if isStimAvr,
%         if exist('isAllCells','var'),
%             M = cellRespAvr(:,tIX);
%         else
%             M = cellRespAvr(cIX,tIX);
%         end
%         behavior = BehaviorAvr(:,tIX);
%         stim = stimAvr(:,tIX);
%     else
%         if exist('isAllCells','var'),
%             M = cellResp(:,tIX);
%         else
%             M = cellResp(cIX,tIX);
%         end
%         behavior = Behavior_full(:,tIX);
%         stim = stim_full(:,tIX);
%     end
%     
%     
%     if isTrialRes
%         [~,M] = GetTrialAvrLongTrace(hfig,M);
%         [~,behavior] = GetTrialAvrLongTrace(hfig,behavior);
%         %     cellRespAvr = getappdata(hfig,'CellRespAvrZ');
%     end
%     
%     if isClusRes
%         gIX = getappdata(hfig,'gIX');
%         [~,M] = FindClustermeans(gIX,M);
%     end
% else
%     M = [];
%     if isStimAvr,
%         behavior = BehaviorAvr(:,tIX);
%         stim = stimAvr(:,tIX);
%     else
%         behavior = Behavior_full(:,tIX);
%         stim = stim_full(:,tIX);
%     end
% end
% 
% setappdata(hfig,'behavior',behavior);
% setappdata(hfig,'stim',stim);
end