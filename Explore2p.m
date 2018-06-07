function h = Explore2p(varargin)
% EXPLORE2P
% GUI to explore functional imaging data (e.g. from Two-Photon '2P' microscopy)
% To use, directly load preproceesed imaging data in Suite2p output format (https://github.com/cortex-lab/Suite2P), 
% along with (optional) experimental recordings of stimulus/behavior. 

%% testing
% convenience flag for testing phase: init load demo data
global isTesting;
isTesting = true;

%% init
h = ImageClass(); % code to construct/init infrastructure in here 
%(see custom ImageClass specifically designed for this gui)

%% Make figure
scrn = get(0,'Screensize');
fig_width = scrn(3)*0.5;
fig_height = scrn(4)*0.5;
hfig = figure('Position',[scrn(3)*0.2, scrn(4)*0.05, fig_width, fig_height],...% [50 100 1700 900]
    'Name','GUI_2p',...%,'KeyPressFcn',@KeyPressCallback,...
    'ToolBar', 'none','MenuBar', 'none',...
    'ResizeFcn',@resizeMainFig_callback); %
hold off; axis off

h.hfig = hfig;

%% Menu 1: File
hm_file = uimenu(hfig,'Label','File');

uimenu(hm_file,'Label','Load data...',...
    'Callback',@menu_loadmat_Callback);

uimenu(hm_file,'Label','Export to workspace',...
    'Callback',@menu_export_workspace_Callback);

uimenu(hm_file,'Label','Pop-up plot',...
    'Callback',@menu_popupPlot_Callback);

uimenu(hm_file,'Label','Save GUI session',...
    'Separator','on',...
    'Callback',@menu_saveGUIsession_Callback);

uimenu(hm_file,'Label','Open GUI session...',...
    'Callback',@menu_loadGUIsession_Callback);

%% Menu 2: Edit
hm_edit = uimenu(hfig,'Label','Edit');

h.gui.back = uimenu(hm_edit,'Label','Back',...
    'Callback',@menu_back_Callback);

h.gui.forward = uimenu(hm_edit,'Label','Forward',...
    'Callback',@menu_forward_Callback);

h.gui.isStimAvg = uimenu(hm_edit,'Label','Trace avg.',...
    'Separator','on',...
    'Checked','off',...
    'Callback',@menu_traceAvg_Callback);

%% Menu 3: View
hm_view = uimenu(hfig,'Label','View');

uimenu(hm_view,'Label','Refresh',...
    'Callback',@menu_refresh_Callback);

h.gui.plotLines = uimenu(hm_view,'Label','Lines/Grayscale',...
    'Separator','on',...
    'Checked','on',...
    'Callback',@menu_isPlotlines_Callback);

h.gui.sqeezeColors = uimenu(hm_view,'Label','Sqeeze colors',...    
    'Callback',@menu_sqeeze_Callback);

h.gui.showTextFunc = uimenu(hm_view,'Label','Show text (Func)',...    
    'Callback',@menu_isShowTextFunc_Callback);


%% Menu 4: Help
hm_help = uimenu(hfig,'Label','Help');
h.gui.help = uimenu(hm_help,'Label','Getting Started',...
    'Callback',@menu_help_Callback);

%% Create UI controls
set(gcf,'DefaultUicontrolUnits','pixels');
set(gcf,'defaultUicontrolBackgroundColor',[1 1 1]);

% tab group setup
M_names = {'Selection','Operations','Regression','Clustering','Saved Clusters'};

h.gui.tgroup = uitabgroup('Parent', hfig, 'Unit','pixels','Position', [50,fig_height-80,fig_width-100,80]);
numtabs = length(M_names);
tab = cell(1,numtabs);
for i = 1:numtabs
    tab{i} = uitab('Parent', h.gui.tgroup, 'BackgroundColor', [1,1,1], 'Title', M_names{i});
end

% grid setup, to help align display elements
rheight = 20;
yrow = 1.5*rheight:-rheight:-0.5*rheight;
dTextHt = 0; % dTextHt = manual adjustment for 'text' controls:
% (vertical alignment is top instead of center like for all other controls)
bwidth = 30;
grid = 5:bwidth+5:40*bwidth;

%% UI tab 1: Selection
i_tab = 1;

% edit_selectROIrange_Callback
i=1;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Cell/ROI range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left',...
    'ToolTipString','Type in range to display, e.g. ''1,2,5'',''2:4'',''6:end''');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_selectROIrange_Callback});

% % edit_selectClusterRange_Callback
% i=i+n;n=3;
% i_row = 1;
% uicontrol('Parent',tab{i_tab},'Style','text','String','Cluster range',...
%     'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
% i_row = 2;
% uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
%     'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
%     'Callback',{@edit_selectClusterRange_Callback});

% edit_manualtIXRange_Callback
i=i+n;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','frame range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_manualtIXRange_Callback});

% edit_stimElmRange_Callback
i=i+n;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Element range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_stimElmRange_Callback});

% edit_blockRange_Callback
i=i+n;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Block range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_blockRange_Callback});

%% UI tab 2: Operations
i_tab = 2;
% popup_ranking_Callback
i=1;n=3; 
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Rank Cells',...
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

%% UI tab 3: Regression
i_tab = 3;
% popup_chooseStimCode_Callback
i=1;n=3; 
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Stim Code',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left',...
    'ToolTipString','These are the individual stimulus sequence elements. Select stimulus for regression under ''Rank Cells''\''stim reg''');
i_row = 2;
menu = {'(choose)','A','B','C','D','Grey'};
uicontrol('Parent',tab{i_tab},'Style','popupmenu','String',menu,'Value',1,...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@popup_chooseStimCode_Callback});

% popup_regranking_Callback
i=i+n;n=3; 
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Rank Cells',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
menu = {'(choose)','single stim reg'};
uicontrol('Parent',tab{i_tab},'Style','popupmenu','String',menu,'Value',1,...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@popup_regranking_Callback});

%% testing
% testing phase: init load demo data
if isTesting
    h = loadSessionData(h);
    refreshFigure(h);
end

%% save
guidata(hfig, h);

end

%% Callback functions

%% Menu 1: File

function menu_loadmat_Callback(hObject,~)
h = guidata(hObject);
h = loadSessionData(h);
guidata(hObject, h);

refreshFigure(h);
end

function menu_export_workspace_Callback(hObject,~)
h = guidata(hObject);
assignin('base', 'h', h);
end

function menu_popupPlot_Callback(hObject,~)
h = guidata(hObject);
scrn = get(0,'Screensize');
fig_width = scrn(3)*0.5;
fig_height = scrn(4)*0.45; % effective plot is same size as in GUI window
hfig2 = figure('Position',[scrn(3)*0.2, scrn(4)*0.05, fig_width, fig_height]);
refreshFigure(h,hfig2);
end

function menu_saveGUIsession_Callback(hObject,~)
h = guidata(hObject); %#ok<NASGU> % to save

% get save path
timestamp = datestr(now,'mmddyy_HHMMSS');
filename = ['E2p_' timestamp '.mat'];
[file,path] = uiputfile(filename,'Save current GUI session');
filedir = fullfile(path,file);

% save master-handle (to all data)
save(filedir,'h');
end

function menu_loadGUIsession_Callback(hObject,~)
h = guidata(hObject);
[file,path] = uigetfile('*.mat','Load a saved GUI session');
load(fullfile(path,file),'h');
end

%% Menu 2: Edit

function menu_back_Callback(hObject,~)
h = guidata(hObject);
bC = h.gui.backCache;
fC = h.gui.fwCache;

if ~isempty(bC.cIX{1})
    disp('back (from cache)');
    
    % set last into forward cache
    fC.cIX = [h.cIX,fC.cIX];
    fC.gIX = [h.gIX,fC.gIX];
    fC.numK = [h.numK,fC.numK];
    fC.tIX = [h.tIX,fC.tIX];
    % retrieve
    h.cIX = bC.cIX{1};
    h.gIX = bC.gIX{1};
    h.numK = bC.numK{1};
    h.tIX = bC.tIX{1};
    if iscell(h.tIX)
        h.ops.isStimAvg = 1;
        h.gui.isStimAvg.Checked = 'on';
    else
        h.ops.isStimAvg = 0;
        h.gui.isStimAvg.Checked = 'off';
    end
    h.cIX_abs = h.absIX(h.cIX);
    h = getIndexedData(h);
    h = refreshFigure(h);
    
    % finish
    bC.cIX(1) = [];
    bC.gIX(1) = [];
    bC.numK(1) = [];
    bC.tIX(1) = [];
    
    h.gui.backCache = bC;
    h.gui.fwCache = fC; 
    
    set(h.gui.forward,'enable','on');
else % nothing to retrieve
    set(h.gui.back,'enable','off');
end
guidata(hObject, h);
end

function menu_forward_Callback(hObject,~)
h = guidata(hObject);
bC = h.gui.backCache;
fC = h.gui.fwCache;

if ~isempty(fC.cIX{1})
    disp('forward (from cache)');
    
    % set last into (backward) cache
    bC.cIX = [h.cIX,bC.cIX];
    bC.gIX = [h.gIX,bC.gIX];
    bC.numK = [h.numK,bC.numK];
    bC.tIX = [h.tIX,bC.tIX];
    % retrieve
    h.cIX = fC.cIX{1};
    h.gIX = fC.gIX{1};
    h.numK = fC.numK{1};
    h.tIX = fC.tIX{1};
    if iscell(h.tIX)
        h.ops.isStimAvg = 1;
        h.gui.isStimAvg.Checked = 'on';
    else
        h.ops.isStimAvg = 0;
        h.gui.isStimAvg.Checked = 'off';
    end
    h.cIX_abs = h.absIX(h.cIX);
    h = getIndexedData(h);
    h = refreshFigure(h);
    
    % finish
    fC.cIX(1) = [];
    fC.gIX(1) = [];
    fC.numK(1) = [];
    fC.tIX(1) = [];
    
    h.gui.backCache = bC;
    h.gui.fwCache = fC;
    % handle rankID: >=2 means write numbers as text next to colorbar
    %     setappdata(hfig,'rankID',0);  
    set(h.gui.back,'enable','on');
else
    set(h.gui.forward,'enable','off');
end
guidata(hObject, h);
end

function menu_traceAvg_Callback(hObject,~)
h = guidata(hObject);
h = toggleMenu(h,h.gui.isStimAvg,'ops','isStimAvg');
tIX = getTimeIndex(h);
h = updateIndices(h,tIX);
refreshFigure(h);
guidata(hObject, h);
end

%% Menu 3: View

function menu_refresh_Callback(hObject,~)
h = guidata(hObject);
refreshFigure(h);
guidata(hObject, h);
end

function menu_isPlotlines_Callback(hObject,~)
h = guidata(hObject);
h = toggleMenu(h,h.gui.plotLines,'vis','isPlotLines');
refreshFigure(h);
guidata(hObject, h);
end

function menu_sqeeze_Callback(hObject,~)
h = guidata(hObject);
[gIX, numU] = squeezeGroupIX(h.gIX);
h = updateIndices(h,h.cIX,gIX,numU);
refreshFigure(h);
guidata(hObject, h);
end

function menu_isShowTextFunc_Callback(hObject,~)
h = guidata(hObject);
h = toggleMenu(h,h.gui.showTextFunc,'vis','isShowTextFunc');
refreshFigure(h);
guidata(hObject, h);
end

%% Menu 4: Help

function menu_help_Callback(~,~)
msg = 'see README on https://github.com/xiuyechen/Explore2p';
helpdlg(msg);
end

%% UI tab 1: Selection

function edit_selectROIrange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    str = strrep(str,'end',num2str(max(h.gIX)));
    range = parseRange(str);
    [cIX,gIX] = selectCellRange(h.cIX,h.gIX,range);
    h = updateIndices(h,cIX,gIX);
    refreshFigure(h);
    guidata(hObject, h);
end
end

function edit_manualtIXRange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    str = strrep(str,'end',num2str(h.timeInfo.nFrames));
    range = parseRange(str);
    if max(range)>h.timeInfo.nFrames
        msg = ['Out of range. Max number of frames is ',num2str(h.timeInfo.nFrames)];
        errordlg(msg);
    else
        tIX = range';
        h = updateIndices(h,tIX);
        refreshFigure(h);
        guidata(hObject, h);
    end
end
end

function edit_stimElmRange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    str = strrep(str,'end',num2str(h.timeInfo.nElm));
    range = parseRange(str);
    if max(range)>h.timeInfo.nElm
        msg = ['Out of range. Max number of elements is ',num2str(h.timeInfo.nElm)];
        errordlg(msg);
    else
        h.ops.rangeElm = range';
        tIX = getTimeIndex(h);
        h = updateIndices(h,tIX);
        refreshFigure(h);
        guidata(hObject, h);
    end
end
end

function edit_blockRange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    str = strrep(str,'end',num2str(h.timeInfo.nBlocks));
    range = parseRange(str);    
    if max(range)>h.timeInfo.nBlocks
        msg = ['Out of range. Max number of blocks is ',num2str(h.timeInfo.nBlocks)];
        errordlg(msg);
    else        
        h.ops.rangeBlocks = range';
        tIX = getTimeIndex(h);
        h = updateIndices(h,tIX);
        refreshFigure(h);
        guidata(hObject, h);
    end
end
end

%% UI tab 2: Operations

function popup_ranking_Callback(hObject,~)
rankID = get(hObject,'Value') - 1;
if rankID==0
    return;
end
h = guidata(hObject);
h.gui.rankID = rankID;

switch rankID
    case 1 % 'max value'
        A = max(h.M, [], 2);
        [~,IX_sort] = sort(A,'descend');
        cIX = h.cIX(IX_sort);
        gIX = (1:length(cIX))';
    case 2 % 'skewness'
        T = struct2table(h.dat.stat);        
        skew = table2array(T(:,22));
        A = skew(h.cIX_abs,1);
        [~,IX_sort] = sort(A,'ascend');
        cIX = h.cIX(IX_sort);
        gIX = (1:length(cIX))';
    case 3 % 'num pixels'
        T = struct2table(h.dat.stat);        
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
guidata(hObject, h);
end

%% UI tab 3: Regression

function popup_chooseStimCode_Callback(hObject,~)
h = guidata(hObject);
h.ops.i_stim = get(hObject,'Value')-1;
guidata(hObject, h);
end

function popup_regranking_Callback(hObject,~)
rankID = get(hObject,'Value') - 1;
if rankID==0
    return;
end
h = guidata(hObject);
h.gui.rankID = rankID;

switch rankID    
    case 1 % 'stingle stim reg'
%         h.M = zscore(h.dat.Fcell{1},0,2);
        t = h.timeInfo;
        
        % get chosen stim type
        disp(t.stimCodeNameArray{h.ops.i_stim});        
        
        % regression 
        %% [better way to make reg.... to-do]
        reg_raw = zeros(t.nFrames,1);
        IX = t.stimChunks(h.ops.i_stim).ix;
        % collapse
        allIx = [];
        for ii = 1:length(IX)
            allIx = [allIx IX(ii).ix]; %#ok<AGROW>
        end
        IX = allIx;
        reg_raw(IX) = 1;
        if h.ops.isStimAvg
            IX = [];
            for ii = h.ops.rangeElm
                IX = horzcat(IX,t.stimmat{ii}(1,:)); %#ok<AGROW>
            end            
            reg = reg_raw(IX);
        else
            reg = reg_raw(h.tIX);
        end
        %%
        coeff = corr(reg,h.M');
        
        % sort by regression result
        [coeff_sorted,IX_sort] = sort(coeff,'descend');
        cIX = h.cIX(IX_sort);
        gIX = (1:length(cIX))';
        
        % output...
        h.temp.coeff = coeff;
        disp(['top 5 coeff: ',num2str(coeff_sorted(1:5))]);  
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

%% extra

function h = toggleMenu(h,menu_handle,group_str,flag_str) % h.ops flags only
% toggle
currentflag = get(menu_handle,'Checked');
if strcmp(currentflag,'off')
    set(menu_handle,'Checked','on');
    h.(group_str).(flag_str) = 1;
elseif strcmp(currentflag,'on')
    set(menu_handle,'Checked','off');
    h.(group_str).(flag_str) = 0;
end
end

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
