
%%
clear all; close all; clc

%% set MATLAB path
% set the Explore2p code folder as current directory
if true % set the
    scriptName = mfilename('fullpath');
    [code_dir, filename, fileextension]= fileparts(scriptName);
    addpath(genpath(code_dir));
    cd(code_dir)
    
else
    % (hard-coded, customize here)
    folder = 'C:\Users\xiuye\Dropbox\!Research\2Pcode\Explore2p'; %#ok<UNRCH>
    addpath(genpath(folder));
    cd(folder)
end

%% launch GUI
Explore2p;

% and load some data (if not automatically loading default session)

%% export current variables: Click ->
% File > Export to workspace

%% manual analyses in workspace
cIX = h.cIX(1:3:end);
gIX = h.gIX(1:3:end);

%% import back to GUI to visualize: Click ->
% File > Import from workspace