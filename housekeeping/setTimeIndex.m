function tIX = setTimeIndex(h)
% when relevant gui ops are updated, this function computes the new tIX, 
% and updates all variables that depend on tIX (M_0 and M, beahvior and stim)
% (tIX is set but not publicly accessed)


%% input params

isStimAvr = h.gui.isStimAvr;
% expt blocks (sessions)
% stim ID (block type)


% isRawtime = getappdata(hfig,'isRawtime');
% stimrange = getappdata(hfig,'stimrange');
% load
timelists = getappdata(hfig,'timelists');
periods = getappdata(hfig,'periods');
fishset = getappdata(hfig,'fishset');

%% set tIX
if fishset == 1,
    if isStimAvr,
        tIX = 1:periods;
    else
        tIX = timelists{1};
    end
    
else % fishset>1,
    if isStimAvr,
        tIX = [];
        for i = 1:length(stimrange),
            ix = stimrange(i);
            i_start = sum(periods(1:ix-1)); % if ix-1<1, sum = 0
            tIX = horzcat(tIX,(i_start+1:i_start+periods(ix)));
            %             tIX = vertcat(tIX,(i_start+1:i_start+periods(ix))');
        end
    else % full range
        if ~isRawtime,
            tIX = cat(2, timelists{stimrange});
        else
            tIX = sort(cat(2, timelists{stimrange}));
        end
    end
end
% setappdata(hfig,'tIX',tIX);
% 
% %% set M_0
% [M_0,behavior,stim] = GetTimeIndexedData(hfig,'isAllCells');
% setappdata(hfig,'M_0',M_0);
% 
% %% set M
% cIX = getappdata(hfig,'cIX');
% if ~isempty(M_0)
%     M = M_0(cIX,:);
% else
%     M = [];
% end
% setappdata(hfig,'M',M);


% %% set stimulus regressors
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