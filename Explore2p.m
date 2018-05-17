function h = Explore2p(varargin)

%% Make figure
scrn = get(0,'Screensize');
hfig = figure('Position',[scrn(3)*0.2 scrn(4)*0.05 scrn(3)*0.5 scrn(4)*0.5],...% [50 100 1700 900]
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
h.backCache = bCache;
h.fwCache = fCache;

% testing phase: init load demo data
global isTesting;
isTesting = 1;
if isTesting
    h = loadSessionData(h);
end


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
    'Callback',@refresh_Callback);

h.gui.plotLines = uimenu(hm_vis,'Label','Lines/Grayscale',...
    'Checked','on',...
    'Callback',@toggle_plotlines_Callback);

hm_colormap = uimenu(hm_vis,'Label','Colormap');

h.gui.hsv = uimenu(hm_colormap,'Label','hsv',...
    'Checked','on',...
    'Callback',@toggle_plotlines_Callback);
% ,...
%     'Checked','on',...
%     'Callback',@toggle_plotlines_Callback);

%% Create UI controls
set(gcf,'DefaultUicontrolUnits','normalized');
set(gcf,'defaultUicontrolBackgroundColor',[1 1 1]);

% tab group setup
tgroup = uitabgroup('Parent', hfig, 'Position', [0.05,0.88,0.91,0.12]);
numtabs = 6;
tab = cell(1,numtabs);
M_names = {'General','Operations','Regression','Clustering etc.','Saved Clusters','Atlas'};
for i = 1:numtabs
    tab{i} = uitab('Parent', tgroup, 'BackgroundColor', [1,1,1], 'Title', M_names{i});
end


% grid setup, to help align display elements
rheight = 0.5;
yrow = 0.5:-0.5:0;%0.97:-0.03:0.88;
dTextHt = 0.05; % dTextHt = manual adjustment for 'text' controls:
% (vertical alignment is top instead of center like for all other controls)
bwidth = 0.03;
grid = 0:bwidth+0.001:1;


%% tabs

i_tab = 1;

%% UI row 1: File
i_row = 1;
i = 1;n = 0;
i=i+n;

% n=2; % Export
% uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Export',...
%     'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
%     'Callback',@pushbutton_Export_Callback);

% i=i+n;
% n=2;
% uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','load .mat',...
%     'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
%     'Callback',@pushbutton_loadmat_Callback);

i=i+n;
n=2;
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','rank sk',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@rank_by_skewness);

i=i+n;
n=3;
uicontrol('Parent',tab{i_tab},'Style','text','String','Choose top _ ROI''s',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','right');

i=i+n;
n=2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_ROIcount_Callback});

i=i+n;
n=3;
uicontrol('Parent',tab{i_tab},'Style','text','String','Choose ROI range:',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','right');
i=i+n;
n=2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_selectROIrange_Callback});
i=i+n;
n=3;
uicontrol('Parent',tab{i_tab},'Style','text','String','Choose cluster range:',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','right');
i=i+n;
n=2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_selectClusterRange_Callback});

i=i+n;
n=2; % rank clusters based on various criteria (to choose)
uicontrol('Parent',tab{i_tab},'Style','text','String','Rank by:',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','right');

i=i+n; % 'hier' is the same as default (used after every k-means);'stim-lock' uses std across reps;
n=2; % motor stuff uses the best alignment (by cross-correlation) with the behavior trace;
% L+R is average of L & R; stim-motor is combines 'stim-lock' w 'motor' with arbituary weighting.
menu = {'(choose)','hier.','size','stim-lock','corr','motor','L motor','R motor','L+R motor',...
    'fft','inverse sparseness','multi-motor w/ stim-avr','sparseness'};
uicontrol('Parent',tab{i_tab},'Style','popupmenu','String',menu,'Value',1,...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@popup_ranking_Callback});

i=i+n;
n=3; % cluster indices will rank from 1 to number of clusters
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Sqeeze clusters',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_sqeeze_Callback);

%% save
guidata(hfig, h);

end

%% Callback functions

% 1.1
function loadmat_Callback(hObject,~)
h = guidata(hObject);
h = loadSessionData(h);
guidata(hObject, h);
end

% 1.2
function export_Callback(hObject,~)
h = guidata(hObject);
assignin('base', 'h', h);
end

% 2.1
function back_Callback(hObject,~)
h = guidata(hObject);
bC = h.backCache;
fC = h.fwCache;

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
    
    h.backCache = bC;
    h.fwCache = fC;
    % flag
    %     setappdata(hfig,'rankID',0);
    %     M = GetTimeIndexedData(hfig);
    %     setappdata(hfig,'M',M);
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
bC = h.backCache;
fC = h.fwCache;

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
    
    h.backCache = bC;
    h.fwCache = fC;
    % handle rankID: >=2 means write numbers as text next to colorbar
    %     setappdata(hfig,'rankID',0);
    
    % flag
    %     M = GetTimeIndexedData(hfig);
    %     setappdata(hfig,'M',M);
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
function refresh_Callback(hObject,~)
h = guidata(hObject);
h = refreshFigure(h);
guidata(hObject, h);
end

function toggle_plotlines_Callback(hObject,~)
h = guidata(hObject);
% flag = get(h.gui.plotLines,'Checked');
h = toggleMenu(h,h.gui.plotLines,'plotLines');
refreshFigure(h);
guidata(hObject, h);
end

function h = toggleMenu(h,menu_handle,flag_string)
% toggle
currentflag = get(h.gui.plotLines,'Checked');
if strcmp(currentflag,'off')
    set(menu_handle,'Checked','on');    
    h.flag = setfield(h.flag,flag_string,1);
elseif strcmp(currentflag,'on')
    set(menu_handle,'Checked','off');
    h.flag = setfield(h.flag,flag_string,0);
end
end
% function pushbutton_drawIm_Callback(hObject,~)
% hfig = getParentFigure(hObject);
% h = guidata(hObject);
%
% % select ROI's to plot
% h.n_topROIs = min(30,length(h.IX_ROI));
% h = ChooseROIs_default(h,h.n_topROIs);
%
% % draw
% h = refreshFigure(h);
% guidata(hObject, h);
% end

% flagged
function edit_ROIcount_Callback(hObject,~)
str = get(hObject,'String');
h = guidata(hObject);
if ~isempty(str)
    temp = textscan(str,'%d');% integer
    h.n_topROIs = temp{:};
else
    h.n_topROIs = length(h.IX_ROI);
end

h = rank_by_skewness(h,h.n_topROIs);

% draw
h = refreshFigure(h);
guidata(hObject, h);
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
    [cIX,gIX] = SelectClusterRange(h.cIX,h.gIX,range);
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
%         sk = skewness(h.M, [], 2);        
          sk = max(h.M, [], 2);      
%         [~,IX_sort] = sort(sk,'ascend');
        gIX = h.gIX;
%         for i = 1:11
%             g
        numU = length(unique(gIX));
        [gIX,~] = SortGroupIXbyScore(sk,1:length(gIX),numU,'descend');
        
%         gIX = IX_sort;%(1:topN);     
    case 2
        T = struct2table(h.dat.stat);
        h.M = zscore(h.dat.Fcell{1},0,2);
        h.skew = table2array(T(:,22));
        A = h.skew(h.cIX_abs,1);
        [~,IX_sort] = sort(A,'ascend');
        gIX = IX_sort;%(1:topN); 
    case 3
        T = struct2table(h.dat.stat);
        h.M = zscore(h.dat.Fcell{1},0,2);
        h.footprint = table2array(T(:,10));%footprint
        A = h.footprint(h.cIX_abs,1);
        [~,IX_sort] = sort(A,'ascend');
        gIX = IX_sort;%(1:topN); 
end
% if rankID>1
%     setappdata(hfig,'rankscore',round(rankscore*100)/100);
%     setappdata(hfig,'clrmap_name','jet');
% else
%     setappdata(hfig,'clrmap_name','hsv_new');
% end

h.clrmaptype = 'jet'; 

h = updateIndices(h,h.cIX,gIX);
refreshFigure(h);
guidata(hObject, h);
end

%%


%% ranking functions

function h = rank_by_skewness(hObject,~)
h = guidata(hObject);
h.IX_ROI = h.absIX;
%% rank traces

% calculate skewness
sk = zeros(length(h.IX_ROI),1);
for i = 1:length(h.IX_ROI)
    ichosen = h.IX_ROI(i);
    F =  h.dat.Fcell{1}(ichosen, h.t_start:h.t_stop);
    Fneu = h.dat.FcellNeu{1}(ichosen, h.t_start:h.t_stop);
    
    
    % F(:, ops.badframes)  = F(:,    indNoNaN(ix));
    % Fneu(:, ops.badframes)  = Fneu(:, indNoNaN(ix));
    
    
    coefNeu = 0.7 * ones(1, size(F,1));
    
    dF                  = F - bsxfun(@times, Fneu, coefNeu(:));
    
    % dF          = F - Fneu;
    
%     sd           = std(dF, [], 2);
%     sdN          = std(Fneu, [], 2);
    
    sk(i, 1) = skewness(dF, [], 2);
end

[~,IX_sort] = sort(sk,'ascend');
gIX = IX_sort(h.cIX_abs);
[gIX,numU] = SqueezeGroupIX(gIX);

h = updateIndices(h,h.cIX,gIX,numU);
refreshFigure(h);
guidata(hObject, h);

end

function pushbutton_sqeeze_Callback(hObject,~)
h = guidata(hObject);
[gIX, numU] = SqueezeGroupIX(h.gIX);
h = updateIndices(h,h.cIX,gIX,numU);
refreshFigure(h);
guidata(hObject, h);
end

%% extra

function resizeMainFig_callback(hObject,~)
h = guidata(hObject);
if ~isempty(h) % empty at initial opening of GUI
    h = refreshFigure(h);
    guidata(hObject, h);
end
end