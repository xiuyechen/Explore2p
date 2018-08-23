function h = Explore2p(varargin)
% EXPLORE2P
% GUI to explore functional imaging data (e.g. from Two-Photon '2P' microscopy)
% To use, directly load preproceesed imaging data in Suite2p output format (https://github.com/cortex-lab/Suite2P), 
% along with (optional) experimental recordings of stimulus/behavior. 

%% testing
% convenience flag for testing phase: init load demo data
global isDemo;
isDemo = true;

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
    'Separator','on',...
    'Callback',@menu_export_workspace_Callback);

uimenu(hm_file,'Label','Import from workspace',...
    'Callback',@menu_import_workspace_Callback);

uimenu(hm_file,'Label','Pop-up plot',...
    'Separator','on',...
    'Callback',@menu_popupPlot_Callback);

uimenu(hm_file,'Label','Save updated input file (proc.mat)',...
    'Separator','on',...
    'Callback',@menu_updateProcmat_Callback);

uimenu(hm_file,'Label','Save GUI session',...
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

h.gui.isCellvsROI = uimenu(hm_edit,'Label','Indexing: cell vs. ROI',...
    'Separator','on',...
    'Checked','on',...
    'Callback',@menu_cellvsROI_Callback);

h.gui.isZscore = uimenu(hm_edit,'Label','Normalized (z-score)',...
    'Separator','on',...
    'Checked','on',...
    'Callback',@menu_isZscore_Callback);

%% Menu 3: View
hm_view = uimenu(hfig,'Label','View');

uimenu(hm_view,'Label','Refresh',...
    'Callback',@menu_refresh_Callback);

h.gui.plotLines = uimenu(hm_view,'Label','Lines/Grayscale',...
    'Separator','on',...
    'Checked','on',...
    'Callback',@menu_isPlotlines_Callback);

h.gui.showTextFunc = uimenu(hm_view,'Label','Show text (Func)',...   
    'Checked','on',...
    'Callback',@menu_isShowTextFunc_Callback);

h.gui.showTextAnat = uimenu(hm_view,'Label','Show text (Anat)',...   
    'Checked','on',...
    'Callback',@menu_isShowTextAnat_Callback);

h.gui.fixRandSeed = uimenu(hm_view,'Label','Fix Random clrmap',...   
    'Checked','on',...
    'Callback',@menu_isFixRandSeed_Callback);

h.gui.sqeezeColors = uimenu(hm_view,'Label','Sqeeze colors',...  
    'Separator','on',...
    'Callback',@menu_sqeeze_Callback);

h.gui.splitCells = uimenu(hm_view,'Label','Split cells',...      
    'Callback',@menu_splitCells_Callback);

h.gui.showLegend = uimenu(hm_view,'Label','Show stimulus legend',...    
    'Separator','on',...
    'Callback',@menu_showLegend_Callback);

%% Menu 4: Custom
hm_file = uimenu(hfig,'Label','Custom');

uimenu(hm_file,'Label','template',...
    'Callback',@menu_template_Callback);

%% Menu 5: Help
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

% edit_selectClusterRange_Callback
i=1;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Cluster range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left',...
    'ToolTipString','Type in range to display, e.g. ''1,3-5'',''2:4'';''1:end'' to show all');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_selectClusterRange_Callback});

% edit_selectCellRange_Callback
i=i+n;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Cell range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left',...
    'ToolTipString','Type in range to display, e.g. ''1,3-5'',''2:4'';''1:end'' to show all');
i_row = 2;
h.gui.cellRange = uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_selectCellRange_Callback});

% edit_selectROIrange_Callback
i=i+n;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','ROI range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left',...
    'ToolTipString','Type in range to display, e.g. ''1,3-5'',''2:4'';''1:end'' to show all');
i_row = 2;
h.gui.ROIrange = uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_selectROIrange_Callback});

% edit_toggleCellvsROI_Callback
i=i+n;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Cell/not cell(!)',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left',...
    'ToolTipString','Type in range to display, e.g. ''1,3-5'',''2:4'';''1:end'' to show all');
i_row = 2;
h.gui.editCellvsROI = uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_toggleCellvsROI_Callback});

% edit_manualtIXRange_Callback
i=i+n;n=3;
i_row = 1;
h.gui.framerange = ...
    uicontrol('Parent',tab{i_tab},'Style','text','String','frame range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
    % ToolTipString set in 'h = loadSessionData(h)'
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_manualtIXRange_Callback});

% edit_stimElmRange_Callback
i=i+n;n=3;
i_row = 1;
h.gui.elementrange = ...
    uicontrol('Parent',tab{i_tab},'Style','text','String','Element range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
    % ToolTipString set in 'h = loadSessionData(h)'
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_stimElmRange_Callback});

% edit_blockRange_Callback
i=i+n;n=3;
i_row = 1;
h.gui.blockrange = ...
    uicontrol('Parent',tab{i_tab},'Style','text','String','Block range',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
    % ToolTipString set in 'h = loadSessionData(h)'
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_blockRange_Callback});

%% UI tab 2: Operations
i_tab = 2;
% popup_ranking_Callback
i=1;n=3; 
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Rank cells',...
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
    'String',{'random clrs','hsv','jet','hsv(old)'},...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@popup_chooseclrmap_Callback);

%% UI tab 3: Regression
i_tab = 3;
% popup_chooseStimCode_Callback
i=1;n=3; 
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Stim code',...
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
uicontrol('Parent',tab{i_tab},'Style','text','String','Rank cells',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
menu = {'(choose)','single stim reg'};
uicontrol('Parent',tab{i_tab},'Style','popupmenu','String',menu,'Value',1,...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@popup_regranking_Callback});

%% UI tab 4: Clustering
i_tab = 4;

% edit_kmeans_Callback
i=1;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','k-means',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_kmeans_Callback});

i=i+n;n=3;
i_row = 1;
h.gui.demotextbox = ...
    uicontrol('Parent',tab{i_tab},'Style','text','String','(demo: skip cells)',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left',...
    'ToolTipString','Type in an integer n to skip every nth cell');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_template_Callback});

%% UI tab 5: Save Clusters
i_tab = 5;

% edit_saveGUIcluster
i=1;n=3;
i_row = 1;
uicontrol('Parent',tab{i_tab},'Style','text','String','Cluster name',...
    'Position',[grid(i) yrow(i_row)-dTextHt bwidth*n rheight],'HorizontalAlignment','left');
i_row = 2;
uicontrol('Parent',tab{i_tab},'Style','edit','String','',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',{@edit_saveGUIcluster});

i=i+n;n=3;
uicontrol('Parent',tab{i_tab},'Style','pushbutton','String','Load clusters...',...
    'Position',[grid(i) yrow(i_row) bwidth*n rheight],...
    'Callback',@pushbutton_loadclusters_Callback);


%% testing
% testing phase: init load demo data
if isDemo
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
refreshFigure(h);
guidata(hObject, h);
end

function menu_export_workspace_Callback(hObject,~)
h = guidata(hObject);
assignin('base', 'h', h);
end

function menu_import_workspace_Callback(hObject,~)
h = guidata(hObject);

% import cIX, gIX, and optionally tIX
cIX = evalin('base','cIX');
gIX = evalin('base','gIX');
if exist('tIX','var')
    tIX = evalin('base','tIX');
else
    tIX = h.tIX;
end
numK = max(gIX);

h = updateIndices(h,h.cellvsROI,cIX,gIX,numK,tIX);
refreshFigure(h);
guidata(hObject, h);
end

function menu_popupPlot_Callback(hObject,~)
h = guidata(hObject);
scrn = get(0,'Screensize');
fig_width = scrn(3)*0.5;
fig_height = scrn(4)*0.45; % effective plot is same size as in GUI window
hfig2 = figure('Position',[scrn(3)*0.2, scrn(4)*0.05, fig_width, fig_height]);
refreshFigure(h,hfig2);
end

function menu_updateProcmat_Callback(hObject,~)
h = guidata(hObject); 

% update the IsCell param to dat struct
dat = h.dat;
for j = 1:numel(dat.stat)
    dat.stat(j).iscell = h.IsCell(j);    
end

% set default file name
datestamp = datestr(now,'mmddyy');
[~,name,ext] = fileparts(dat.filename);
filename = [name,'_',datestamp,'_proc',ext];

% UI get save path
[file,path] = uiputfile(filename,'Save curated data in Suite2p output format');
filedir = fullfile(path,file);

% save dat
save(filedir,'dat');
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
guidata(hObject, h);
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
    fC.cellvsROI = [h.cellvsROI,fC.cellvsROI];
    % retrieve
    h.cIX = bC.cIX{1};
    h.gIX = bC.gIX{1};
    h.numK = bC.numK{1};
    h.tIX = bC.tIX{1};
    h.cellvsROI = bC.cellvsROI{1};
    if iscell(h.tIX)
        h.ops.isStimAvg = 1;
        h.gui.isStimAvg.Checked = 'on';
    else
        h.ops.isStimAvg = 0;
        h.gui.isStimAvg.Checked = 'off';
    end

    h = setCellvsROI(h);

    h = getIndexedData(h);
    h = refreshFigure(h);
    
    % finish
    bC.cIX(1) = [];
    bC.gIX(1) = [];
    bC.numK(1) = [];
    bC.tIX(1) = [];
    bC.cellvsROI(1) = [];
    
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
    bC.cellvsROI = [h.cellvsROI,bC.cellvsROI];
    % retrieve
    h.cIX = fC.cIX{1};
    h.gIX = fC.gIX{1};
    h.numK = fC.numK{1};
    h.tIX = fC.tIX{1};
    h.cellvsROI = fC.cellvsROI{1};
    if iscell(h.tIX)
        h.ops.isStimAvg = 1;
        h.gui.isStimAvg.Checked = 'on';
    else
        h.ops.isStimAvg = 0;
        h.gui.isStimAvg.Checked = 'off';
    end

    h = setCellvsROI(h);
    
    h = getIndexedData(h);
    h = refreshFigure(h);
    
    % finish
    fC.cIX(1) = [];
    fC.gIX(1) = [];
    fC.numK(1) = [];
    fC.tIX(1) = [];
    fC.cellvsROI(1) = [];
    
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
h = updateIndices(h,h.cellvsROI,h.cIX,h.gIX,h.numK,tIX);
refreshFigure(h);
guidata(hObject, h);
end

function menu_cellvsROI_Callback(hObject,~)
h = guidata(hObject);
[h,cellvsROI_new] = toggleMenu(h,h.gui.isCellvsROI);

% convert indices
if cellvsROI_new % convert from roiIX... keep cells within roiIX
    roiIX = h.cIX; % old value
    cIX = roiIX2cIX(roiIX,h.IsCell);
    gIX = (1:length(cIX))';
else % convert from cIX to roiIX
    roiIX = cIX2roiIX(h.cIX,h.IsCell);
    cIX = roiIX; % still store as cIX, but now IsChosen is changed
    gIX = ones(length(cIX),1);
end

h = updateIndices(h,cellvsROI_new,cIX,gIX);
refreshFigure(h);
guidata(hObject, h);
end

function menu_isZscore_Callback(hObject,~)
h = guidata(hObject);
h = toggleMenu(h,h.gui.isZscore,'ops','isZscore');
h = updateIndices(h);
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

function menu_isShowTextFunc_Callback(hObject,~)
h = guidata(hObject);
h = toggleMenu(h,h.gui.showTextFunc,'vis','isShowTextFunc');
refreshFigure(h);
guidata(hObject, h);
end

function menu_isShowTextAnat_Callback(hObject,~)
h = guidata(hObject);
h = toggleMenu(h,h.gui.showTextAnat,'vis','isShowTextAnat');
refreshFigure(h);
guidata(hObject, h);
end

function menu_isFixRandSeed_Callback(hObject,~)
h = guidata(hObject);
h = toggleMenu(h,h.gui.fixRandSeed,'vis','isFixRandSeed');
refreshFigure(h);
guidata(hObject, h);
end

function menu_sqeeze_Callback(hObject,~)
h = guidata(hObject);
[gIX, numU] = squeezeGroupIX(h.gIX);
h = updateIndices(h,h.cellvsROI,h.cIX,gIX,numU);
refreshFigure(h);
guidata(hObject, h);
end

function menu_splitCells_Callback(hObject,~)
h = guidata(hObject);
gIX = (1:length(h.gIX))';
numU = max(gIX);
h = updateIndices(h,h.cellvsROI,h.cIX,gIX,numU);
refreshFigure(h);
guidata(hObject, h);
end

function menu_showLegend_Callback(hObject,~)
h = guidata(hObject);
names = h.timeInfo.stimCodeNameArray;

%% get trial-averaged stimulus
IX = [];
for ii = h.ops.rangeElm
    IX = horzcat(IX,h.timeInfo.stimmat{ii}(1,:)); %#ok<AGROW>
end
stim = h.timeInfo.stimCode(IX);

%% draw stimbar
figure('Position',[100,500,500,130]);hold on;
title('Stimulus bar (1 repetition)')
roughhalfbarheight = 1;
[stimbar,~,cmap] = getStimBar(roughhalfbarheight,stim); % horizontal stimulus bar
image(stimbar);axis off; axis tight
colormap(cmap);

% draw legend
hidden_h = [];
for ii = 1 : 5
    hidden_h(ii) = surf(uint8(ii-[1 1;1 1]), 'edgecolor', 'none','facealpha',0); 
end
legend(hidden_h, names, 'orientation','horizontal','location','SouthOutside')

end

%% Menu 4: (Template)

function menu_template_Callback(~,~)
h = guidata(hObject);
figure;
imagesc(h.M)
guidata(hObject, h);
end

%% Menu 5: Help

function menu_help_Callback(~,~)
msg = ['Quick tip: hover over labels (e.g. ''Cluster range'')',...
    'to see a tool-tip-string pop up. For an overview, see this readme on github: https://github.com/xiuyechen/Explore2p (for a link, see MATLAB command window output)'];
helpdlg(msg);

text_link = '<a href="matlab:web(''https://github.com/xiuyechen/Explore2p'');">https://github.com/xiuyechen/Explore2p</a>';
disp(text_link);
end

%% UI tab 1: Selection

function edit_selectClusterRange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    str = strrep(str,'end',num2str(max(h.gIX)));
    range = parseRange(str);
    [cIX,gIX] = selectClusterRange(h.cIX,h.gIX,range);
    h = updateIndices(h,h.cellvsROI,cIX,gIX);
    refreshFigure(h);
    guidata(hObject, h);
end
end

function edit_selectCellRange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    str = strrep(str,'end',num2str(h.nCells));
    cIX = parseRange(str);
    cellvsROI = 1;
    h = updateIndices(h,cellvsROI,cIX,(1:length(cIX))');
    refreshFigure(h);
    guidata(hObject, h);
end
end

function edit_selectROIrange_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)    
    str = strrep(str,'end',num2str(h.nROIs));
    roiIX = parseRange(str);
    cellvsROI = 0;
    h = updateIndices(h,cellvsROI,roiIX,ones(size(roiIX)));
    refreshFigure(h);    
    guidata(hObject, h);
end
end

function edit_toggleCellvsROI_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    choice = questdlg(['Toggling cell-assignment changes cell indexing;' ...
        'also you need to save it using File\Save updated input file (proc.mat).' ...
        'Would you like to proceed?'], ...
        'Warning'); % Yes/No/Cancel
    % Handle response
    if strcmp(choice,'Yes')        
        temp = textscan(str,'%d');
        ix = temp{:};
        
        % update IsCell
        if h.cellvsROI
            % cell, mark as not cell
            roi_ix = cIX2roiIX(ix,h.IsCell);
            fprintf('cell #%d = roi #%d set to not-cell \n',ix,roi_ix);
            h.IsCell(roi_ix) = 0;
            
            % manually update indexing
            cIX = h.cIX;
            cIX(ix) = [];
            cIX(ix:end) = cIX(ix:end)-1;
            
            gIX = h.gIX;
            gIX(ix) = [];
            
            h = updateIndices(h,h.cellvsROI,cIX,gIX);
            
        else % if is ROI
            % ROI, mark as cell
            roi_ix = ix;
            h.IsCell(roi_ix) = 1;
            fprintf('roi #%d set to cell \n',roi_ix);
            
            h = updateIndices(h);
        end
        
        refreshFigure(h);
        guidata(hObject, h);
    end
end
end

% roiIX = h.cIX; % old value
% cIX = roiIX2cIX(roiIX,h.IsCell);
% gIX = (1:length(cIX))';
% else % convert from cIX to roiIX
%     roiIX = cIX2roiIX(h.cIX,h.IsCell);
%     cIX = roiIX; % still store as cIX, but now IsChosen is changed
%     gIX = ones(length(cIX),1);
%     
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
        h = updateIndices(h,h.cellvsROI,h.cIX,h.gIX,h.numK,tIX);
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
        h = updateIndices(h,h.cellvsROI,h.cIX,h.gIX,h.numK,tIX);
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
        h = updateIndices(h,h.cellvsROI,h.cIX,h.gIX,h.numK,tIX);
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
        A = skew(h.roiIX,1);
        [~,IX_sort] = sort(A,'ascend');
        cIX = h.cIX(IX_sort);
        gIX = (1:length(cIX))';
    case 3 % 'num pixels'
        T = struct2table(h.dat.stat);        
        npix = table2array(T(:,6));
        A = npix(h.roiIX,1);
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

h = updateIndices(h,h.cellvsROI,cIX,gIX);
refreshFigure(h);
guidata(hObject, h);
end

function popup_chooseclrmap_Callback(hObject,~)
i_clr = get(hObject,'Value');
h = guidata(hObject);
if i_clr==1
    h.vis.clrmaptype = 'rand';
elseif i_clr==2
    h.vis.clrmaptype = 'hsv';
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
    case 1 % 'single stim reg'
        % get chosen stim type
        disp(h.timeInfo.stimCodeNameArray{h.ops.i_stim});        
        
        % regression with simple (boxcar) regressor     
        reg = makeRegressors(h);
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

h = updateIndices(h,h.cellvsROI,cIX,gIX);
refreshFigure(h);
guidata(hObject, h);
end

%% UI tab 4: Clustering

function edit_kmeans_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    temp = textscan(str,'%d');
    numK = temp{:};
    gIX = kmeans_direct(h.M,numK);
    
    h = updateIndices(h,h.cellvsROI,h.cIX,gIX,numK);
    refreshFigure(h);
    guidata(hObject, h);   
end
end

function edit_template_Callback(hObject,~)
h = guidata(hObject);
% get/format range
str = get(hObject,'String');
if ~isempty(str)
    temp = textscan(str,'%d');
    input_integer = temp{:};
    
    disp(['Your input ',num2str(input_integer),' is received.']);
    disp('Look for ''edit_template_Callback'' in the ''Explore2p.m'' code.');
    
    % popular variables to use: h.M, h.cIX, h.gIX. See ImageClass classdef
    % ...custom code...
    % example:
    cIX = h.cIX; % currently selected indices (originally named for Cell Indices, now also used when selecting ROI's)
    gIX = h.gIX; % group index (originally used to assign cluster id; used to show different clusters in different colors)
    
    step = input_integer;
    cIX = cIX(1:step:end);
    gIX = gIX(1:step:end);
    
    % Then use 'updateIndices' to update changed variables, see updateIndices help
    % for this example:
    h = updateIndices(h,h.cellvsROI,cIX,gIX);
    refreshFigure(h);
    guidata(hObject, h);   
end
end

%% UI tab 5: Save Clusters

function edit_saveGUIcluster(hObject,~) % state: 'current' or 'new'
h = guidata(hObject);
inputstr = get(hObject,'String');

s = [];
s.cellvsROI = h.cellvsROI;
s.cIX = h.cIX;
s.gIX = h.gIX;
s.numK = h.numK;
s.tIX = h.tIX;
s.IsCell = h.IsCell;
s.roiIX = h.roiIX;

% s.M = h.M;
% s.M_0 = h.M_0;

% set default file name
datestamp = datestr(now,'mmddyy');
[~,name,ext] = fileparts(h.dat.filename);
filename = [name,'_',datestamp,'_cluster_',inputstr,ext];

% UI get save path
[file,path] = uiputfile(filename,'Save curated data in Suite2p output format');
filedir = fullfile(path,file);

% save dat
save(filedir,'s');
end


function pushbutton_loadclusters_Callback(hObject,~)
h = guidata(hObject);
[file,path] = uigetfile('*.mat','Load a saved cluster file (.mat)');
load(fullfile(path,file),'s');

cellvsROI = s.cellvsROI;
cIX = s.cIX;
gIX = s.gIX;
numK = s.numK;
tIX = s.tIX;
% h.roiIX = s.roiIX; % dependent property

if ~isequal(h.IsCell,s.IsCell)    
    answer = questdlg('Are you sure you want to overwrite current cell curation?');
    if answer
        h.IsCell = s.IsCell;
        
        h = updateIndices(h,cellvsROI,cIX,gIX,numK,tIX);
        refreshFigure(h);
        guidata(hObject, h);
    else
        disp('cluster import aborted');
    end
else
    h = updateIndices(h,cellvsROI,cIX,gIX,numK,tIX);
    refreshFigure(h);
    guidata(hObject, h);
end
end

%% extra

function [h,flag] = toggleMenu(h,menu_handle,group_str,flag_str) % h.ops flags only
% h = toggleMenu(h,menu_handle,group_str,flag_str)
% [h,flag] = toggleMenu(h,menu_handle)

currentflag = get(menu_handle,'Checked');
% toggle
if nargin == 2
    if strcmp(currentflag,'off')
        set(menu_handle,'Checked','on');
        flag = 1;
    elseif strcmp(currentflag,'on')
        set(menu_handle,'Checked','off');
        flag = 0;
    end
elseif nargin ==4        
    if strcmp(currentflag,'off')
        set(menu_handle,'Checked','on');
        h.(group_str).(flag_str) = 1;
    elseif strcmp(currentflag,'on')
        set(menu_handle,'Checked','off');
        h.(group_str).(flag_str) = 0;
    end
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
