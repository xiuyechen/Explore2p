function h = LoadSessionData(h)
disp('loading proc data');
root = 'C:\Users\xiuye\Documents\2P_processed\';

global isTesting
if isTesting
    filename1 = 'F_m011_010918_plane1_proc.mat';
    filepath1 = 'C:\Users\xiuye\Documents\2P_processed\Expore2p_demodata\m011_010918_1';
else
    [filename1,filepath1]=uigetfile(fullfile(root, 'F*.mat'), 'Select Data File');
end

h_load = load(fullfile(filepath1, filename1));
h.dat = h_load.dat;

%% init
% h.hfig = getParentFigure(hObject);
T = struct2table(h.dat.stat);
h.M = zscore(h.dat.Fcell{1},0,2);
h.IsCell = table2array(T(:,28));
h.IX_ROI = find(h.IsCell);

% time points
h.t_start = 1;%2000;
h.t_stop = size(h.M,2);%3000;

% init cell selection to display
h.cIX = (1:100)';%(1:length(h.IX_ROI))';%h.IX_ROI;
h.gIX = (1:length(h.cIX))';
h.cIX_abs = h.IX_ROI(h.cIX);

%% app flags
h.clrmaptype = 'hsv';

%% draw
h = RefreshFigure(h);
end
