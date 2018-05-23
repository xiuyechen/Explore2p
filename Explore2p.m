function h = Explore2p(varargin)

%% Make figure
scrn = get(0,'Screensize');
fig_width = scrn(3)*0.5;
fig_height = scrn(4)*0.5;
hfig = figure('Position',[scrn(3)*0.2, scrn(4)*0.05, fig_width, fig_height],...% [50 100 1700 900]
    'Name','GUI_2p',...%,'KeyPressFcn',@KeyPressCallback,...
    'ToolBar', 'none','MenuBar', 'none',...
    'ResizeFcn',@resizeMainFig_callback); %
hold off; axis off

%% init
h = [];
h.hfig = hfig;

% GUI cache
bCache = []; % Cache for going b-ack (bad abbr)
fCache = []; % Cache for going f-orward
bCache.cIX = cell(1,1);
bCache.gIX = cell(1,1);
bCache.numK = cell(1,1);
fCache.cIX = cell(1,1);
fCache.gIX = cell(1,1);
fCache.numK = cell(1,1);
h.gui.backCache = bCache;
h.gui.fwCache = fCache;

%% Make menu
% 1. File
hm_file = uimenu(hfig,'Label','File');

uimenu(hm_file,'Label','Load...',...
    'Callback',@loadmat_Callback);

uimenu(hm_file,'Label','Export to workspace',...
    'Callback',@export_Callback);

% 2. Edit
hm_edit = uimenu(hfig,'Label','Edit');

h.gui.back = uimenu(hm_edit,'Label','Back',...
    'Callback',@back_Callback);

h.gui.forward = uimenu(hm_edit,'Label','Forward',...
    'Callback',@forward_Callback);

% 3. Visuals
hm_vis = uimenu(hfig,'Label','Visuals');

uimenu(hm_vis,'Label','Refresh',...
    'Callback',@menu_refresh_Callback);

h.gui.plotLines = uimenu(hm_vis,'Label','Lines/Grayscale',...
    'Checked','on',...
    'Callback',@menu_plotlines_Callback);

h.gui.plotLines = uimenu(hm_vis,'Label','Sqeeze colors',...    
    'Callback',@menu_sqeeze_Callback);

%% Create UI controls
set(gcf,'DefaultUicontrolUnits','pixels');
set(gcf,'defaultUicontrolBackgroundColor',[1 1 1]);

% tab group setup
h.gui.tgroup = uitabgroup('Parent', hfig, 'Unit','pixels','Position', [50,fig_height-80,fig_width-100,80]);
numtabs = 5;
tab = cell(1,numtabs);
M_names = {'General','Operations','Regression','Clustering etc.','Saved Clusters'};
for i = 1:numtabs
    tab{i} = uitab('Parent', h.gui.tgroup, 'BackgroundColor', [1,1,1], 'Title', M_names{i});
end

% grid setup, to help align display elements
rheight = 20;
yrow = 1.5*rheight:-rheight:-0.5*rheight;
dTextHt = 0; % dTextHt = manual adjustment for 'text' controls:
% (vertical alignment is top instead of center like for all other controls)
bwidth = 30;
grid = 5:bwidth+5:20*bwidth;

%% UI tab 1: General
i_tab = 1;

% edit_selectROIrange_Callback
i=1;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','ROI range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_selectROIrange_Callback});

% edit_selectClusterRange_Callback
i=i+n;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Cluster range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_selectClusterRange_Callback});

% popup_ranking_Callback
i=i+n;n=3; 
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Rank criteria',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
menu = {'(choose)','max value','skewness','num pixels'};
uicontrol('Parent',tab{i_tab},'Style','popupmenu','String',menu,'Value',1,...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@popup_ranking_Callback});

% popup_chooseclrmap_Callback
i=i+n;n=3; 
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Colormap',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','popupmenu',...
    'String',{'hsv','random clrs','jet','hsv(old)'},...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@popup_chooseclrmap_Callback);


%%
% testing phase: init load demo data
global isTesting;
isTesting = 1;
if isTesting
    h = loadSessionData(h);
    refreshFigure(h);
end

%% save
guidata(hfig, h);

end

%% Callback functions

% 1.1
function loadmat_Callback(hObject,~)
h = guidata(hObject);
h = loadSessionData(h);
guidata(hObject, h);

refreshFigure(h);
end

% 1.2
function export_Callback(hObject,~)
h = guidata(hObject);
assignin('base', 'h', h);
end

% 2.1
function back_Callback(hObject,~)
h = guidata(hObject);
bC = h.gui.backCache;
fC = h.gui.fwCache;

if ~isempty(bC.cIX{1})
    % set last into forward cache
    fC.cIX = [h.cIX,fC.cIX];
    fC.gIX = [h.gIX,fC.gIX];
    fC.numK = [h.numK,fC.numK];
    % retrieve
    h.cIX = bC.cIX{1};
    h.gIX = bC.gIX{1};
    h.numK = bC.numK{1};
    bC.cIX(1) = [];
    bC.gIX(1) = [];
    bC.numK(1) = [];
    
    h.gui.backCache = bC;
    h.gui.fwCache = fC;    
    h.cIX_abs = h.absIX(h.cIX);
    h = getFuncData(h);
    
    % finish
    disp('back (from cache)')
    h = refreshFigure(h);
    set(h.gui.forward,'enable','on');
else % nothing to retrieve
    set(h.gui.back,'enable','off');
end
guidata(hObject, h);
end

% 2.2
function forward_Callback(hObject,~)
h = guidata(hObject);
bC = h.gui.backCache;
fC = h.gui.fwCache;

if ~isempty(fC.cIX{1})
    % set last into (backward) cache
    bC.cIX = [h.cIX,bC.cIX];
    bC.gIX = [h.gIX,bC.gIX];
    bC.numK = [h.numK,bC.numK];
    % retrieve
    h.cIX = fC.cIX{1};
    h.gIX = fC.gIX{1};
    h.numK = fC.numK{1};
    fC.cIX(1) = [];
    fC.gIX(1) = [];
    fC.numK(1) = [];
    
    h.gui.backCache = bC;
    h.gui.fwCache = fC;
    % handle rankID: >=2 means write numbers as text next to colorbar
    %     setappdata(hfig,'rankID',0);

    h.cIX_abs = h.absIX(h.cIX);
    h = getFuncData(h);
    
    % finish
    disp('forward (from cache)')
    h = refreshFigure(h);
    set(h.gui.back,'enable','on');
else
    set(h.gui.forward,'enable','off');
end
guidata(hObject, h);
end


%% 3.1
function menu_refresh_Callback(hObject,~)
h = guidata(hObject);
h = refreshFigure(h);
guidata(hObject, h);
end

function menu_plotlines_Callback(hObject,~)
h = guidata(hObject);
h = toggleMenu(h,h.gui.plotLines,'plotLines');
refreshFigure(h);
guidata(hObject, h);
end

function h = toggleMenu(h,menu_handle,flag_string)
% toggle
currentflag = get(h.gui.plotLines,'Checked');
if strcmp(currentflag,'off')
    set(menu_handle,'Checked','on');
    h.ops = setfield(h.ops,flag_string,1);
elseif strcmp(currentflag,'on')
    set(menu_handle,'Checked','off');
    h.ops = setfield(h.ops,flag_string,0);
end
end

function edit_selectROIrange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    str = strrep(str,'end',num2str(max(h.gIX)));
    range = parseRange(str);
    [cIX,gIX] = selectCellRange(h.cIX,h.gIX,range);
    h = updateIndices(h,cIX,gIX);
    h = refreshFigure(h);
    guidata(hObject, h);
end
end

function edit_selectClusterRange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    str = strrep(str,'end',num2str(max(h.gIX)));
    range = parseRange(str);
    [cIX,gIX] = selectClusterRange(h.cIX,h.gIX,range);
    h = updateIndices(h,cIX,gIX);
    refreshFigure(h);
    guidata(hObject, h);
end
end

function popup_ranking_Callback(hObject,~)
% menu = {'(ranking)','hier.','size','stim-lock','corr','noise'};
rankID = get(hObject,'Value') - 1;
if rankID==0
    return;
end
h = guidata(hObject);
h.rankID = rankID;

switch rankID
    case 1
        A = max(h.M, [], 2);
%         [gIX,~] = SortGroupIXbyScore(sk,1:length(gIX),numU,'descend');
        [~,IX_sort] = sort(A,'descend');
        cIX = h.cIX(IX_sort);
        gIX = (1:length(cIX))';
    case 2
        T = struct2table(h.dat.stat);
        h.M = zscore(h.dat.Fcell{1},0,2);
        h.skew = table2array(T(:,22));
        A = h.skew(h.cIX_abs,1);
        [~,IX_sort] = sort(A,'ascend');
        cIX = h.cIX(IX_sort);
        gIX = (1:length(cIX))';
    case 3
        T = struct2table(h.dat.stat);
        h.M = zscore(h.dat.Fcell{1},0,2);
        npix = table2array(T(:,6));
        A = npix(h.cIX_abs,1);
        [~,IX_sort] = sort(A,'descend');
        cIX = h.cIX(IX_sort);
        gIX = (1:length(cIX))';
end
% if rankID>1
%     setappdata(hfig,'rankscore',round(rankscore*100)/100);
%     setappdata(hfig,'clrmap_name','jet');
% else
%     setappdata(hfig,'clrmap_name','hsv_new');
% end

h.vis.clrmaptype = 'jet';

h = updateIndices(h,cIX,gIX);
refreshFigure(h);
guidata(hObject, h);
end

%%


%% ranking functions

% function h = rank_by_skewness(hObject,~)
% h = guidata(hObject);
% h.IX_ROI = h.absIX;
% %% rank traces
% 
% % calculate skewness
% sk = zeros(length(h.IX_ROI),1);
% for i = 1:length(h.IX_ROI)
%     ichosen = h.IX_ROI(i);
%     F =  h.dat.Fcell{1}(ichosen, h.t_start:h.t_stop);
%     Fneu = h.dat.FcellNeu{1}(ichosen, h.t_start:h.t_stop);
%     
%     
%     % F(:, ops.badframes)  = F(:,    indNoNaN(ix));
%     % Fneu(:, ops.badframes)  = Fneu(:, indNoNaN(ix));
%     
%     
%     coefNeu = 0.7 * ones(1, size(F,1));
%     
%     dF                  = F - bsxfun(@times, Fneu, coefNeu(:));
%     
%     % dF          = F - Fneu;
%     
%     %     sd           = std(dF, [], 2);
%     %     sdN          = std(Fneu, [], 2);
%     
%     sk(i, 1) = skewness(dF, [], 2);
% end
% 
% [~,IX_sort] = sort(sk,'ascend');
% gIX = IX_sort(h.cIX_abs);
% [gIX,numU] = SqueezeGroupIX(gIX);
% 
% h = updateIndices(h,h.cIX,gIX,numU);
% refreshFigure(h);
% guidata(hObject, h);
% 
% end

function menu_sqeeze_Callback(hObject,~)
h = guidata(hObject);
[gIX, numU] = squeezeGroupIX(h.gIX);
h = updateIndices(h,h.cIX,gIX,numU);
refreshFigure(h);
guidata(hObject, h);
end

function popup_chooseclrmap_Callback(hObject,~)
i_clr = get(hObject,'Value');
h = guidata(hObject);
if i_clr==1
    h.vis.clrmaptype = 'hsv';
elseif i_clr==2
    h.vis.clrmaptype = 'rand';
elseif i_clr==3
    h.vis.clrmaptype = 'jet';
elseif i_clr==4
    h.vis.clrmaptype = 'hsv_old';
end
refreshFigure(h);
end

%% extra

function resizeMainFig_callback(hObject,~)
h = guidata(hObject);
if ~isempty(h) % empty at initial opening of GUI
    h = refreshFigure(h);
    guidata(hObject, h);
    
    pos = get(h.hfig,'Position');
    fig_width = pos(3);
    fig_height = pos(4);
    set(h.gui.tgroup,'Position',[50,fig_height-80,fig_width-100,80]);
end
end