function h = loadSessionData(h)
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

if isfield(h_load,'dat') % proc.mat
    h.dat = h_load.dat;
else
    h.dat = h_load; % not proc...
    
    
    %%
    h.dat.maxmap = 2;
    ops = h.dat.ops;
    if isfield(ops, 'mimg1') && ~isempty(ops.mimg1)
        h.dat.mimg(:,:,h.dat.maxmap) = ops.mimg1(ops.yrange, ops.xrange);
        h.dat.mimg_proc(:,:,h.dat.maxmap) = normalize_image(h.dat.mimg(:,:,h.dat.maxmap));
    end
    h.dat.mimg(:,:,5) = 0;
end


%% init
% h.hfig = getParentFigure(hObject);
T = struct2table(h.dat.stat);
h.M = zscore(h.dat.Fcell{1},0,2);
h.IsCell = table2array(T(:,28));
h.absIX = find(h.IsCell);

% time points
h.t_start = 1;%2000;
h.t_stop = size(h.M,2);%3000;

% init cell selection to display
h.cIX = (1:length(h.absIX))';
h.gIX = (1:length(h.cIX))';
h.cIX_abs = h.absIX(h.cIX);
h.numK = max(h.gIX);


%% app flags
% h.vis.clrmaptype = 'hsv';
h.ops.plotLines = 1;
h.vis.clrmaptype = 'rand'; 

end
