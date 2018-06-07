function tIX = getTimeIndex(h)
% check: 
% % % % when relevant gui ops are updated, this function computes the new tIX, 
% % % % and updates all variables that depend on tIX (M_0 and M, beahvior and stim)
% % % % (tIX is set but not publicly accessed)


%% input params

isStimAvg = h.ops.isStimAvg;
rangeBlocks = h.ops.rangeBlocks;
% % expt blocks (sessions)??
% % stim ID (block type) stimilar to old stimrange

% shorthand
t = h.timeInfo;

%% set tIX
if isStimAvg    
    tIX = t.stimmat(h.ops.rangeElm); % iscell(tIX) = true;
else
    tIX = [];
    for i_block = rangeBlocks
        tIX = [tIX, t.blockStarts(i_block):t.blockStops(i_block)];
    end
end

% setappdata(hfig,'tIX',tIX);

%% set M_0
% [M_0,behavior,stim] = GetTimeIndexedData(hfig,'isAllCells');
% setappdata(hfig,'M_0',M_0);
% 
%% set M again
% cIX = getappdata(hfig,'cIX');
% if ~isempty(M_0)
%     M = M_0(cIX,:);
% else
%     M = [];
% end
% setappdata(hfig,'M',M);

%% recalculate stimulus regressors?? this is not dealt with in getIndexed Data


% stim = getappdata(hfig,'stim');
% fishset = getappdata(hfig,'fishset');
% 
% [~, names] = GetStimRegressor(stim,fishset);
% 
% s = cell(size(names));
% for i = 1:length(names),
%     s{i} = [num2str(i),': ',names{i}];
% end
% 
% global hstimreg;
% set(hstimreg,'String',['(choose)',s]);
end