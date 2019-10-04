function h = loadSessionData(h)
disp('loading proc data');

%% load data


% scriptName = mfilename('fullpath');
% [currentpath, filename, fileextension]= fileparts(scriptName);
% code_dir = currentpath;


dataRoot2p = getDataRoot2p();%'C:\Users\xiuye\Documents\2P_processed\';

global isDemo
if isDemo
    % download a set of 2 demo data files (suite2p output file and frameInfo.mat)
    url_1 = 'https://www.dropbox.com/s/c1d7arckqytpp37/f_330873-a_2018-05-17_plane1_proc.mat?dl=0';
    url_2 = 'https://www.dropbox.com/s/h4x86pajjeyqbtf/frameinfo.mat?dl=0';
    if exist('demo','dir')==7
        fileName1 = fullfile('demo','mouse0_proc.mat');
        fileName2 = fullfile('demo','frameInfo.mat');
    else
        fileName1 = 'mouse0_proc.mat';
        fileName2 = 'frameInfo.mat';
    end
    
    % file 1:
    if exist(fileName1, 'file') == 2
        fullFileName_s2p = fileName1;
        disp(['using demo data ',fileName1,' (Suite2p output file)']);
    else
        fullFileName_s2p = websave(fileName1,url_1);
        disp(['demo data downloaded to ',fileName1,' (Suite2p output file)']);
    end

    % file 2:
    if exist(fileName2, 'file') == 2
        fullFileName_frameInfo = fileName2;
        disp(['using demo data ',fileName2,' (stim/behavior file)']);
    else
        fullFileName_frameInfo = websave(fileName2,url_2);
        disp(['demo data downloaded to ',fileName2,' (stim/behavior file)']);
    end

    % load files
    h_load = load(fullFileName_s2p);
    load(fullFileName_frameInfo,'frameInfo');
    h.ops.haveFrameInfo = 1;
    
else % GUI input    
    [filename1,filepath1]=uigetfile(fullfile(dataRoot2p, 'F*.mat'), 'Select Data File');
    if isequal(filename1,0)
        disp('(File selection cancelled)')
        return;
    end
    
    % load suite2p output data
    h_load = load(fullfile(filepath1, filename1));
    
    % load frameInfo (not mandatory but recommended)
    % default: assuming 'frameInfo.mat' is saved in the corresponding
    % folder for each session
    try
        load(fullfile(filepath1, 'frameInfo.mat'),'frameInfo');
    catch
        [filename1,filepath1]=uigetfile(fullfile(dataRoot2p, '*.mat'), 'Select frameInfo File, press ''Cancel'' if N/A');
        if ~isequal(filename1,0)
            try
                load(fullfile(filepath1, filename1),'frameInfo.mat','frameInfo');
            catch
                errordlg('frameInfo invalid, no stimulus/motor information loaded');
            end
        end
    end
end

%% save to GUI data
if isfield(h_load,'dat') % proc.mat
    h.dat = h_load.dat;
    
else % this is a stub, not tested
    h.dat = h_load; % not proc...
    
    %% mean image
    h.dat.maxmap = 2;
    ops = h.dat.ops;
    if isfield(ops, 'mimg1') && ~isempty(ops.mimg1)
        h.dat.mimg(:,:,h.dat.maxmap) = ops.mimg1(ops.yrange, ops.xrange);
%         h.dat.mimg_proc(:,:,h.dat.maxmap) = normalize_image(h.dat.mimg(:,:,h.dat.maxmap));
    end
    h.dat.mimg(:,:,5) = 0;
end

if exist('frameInfo','var')
    h = initSessionData(h,frameInfo);
else
    h = initSessionData(h);
end

end
