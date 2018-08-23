
%%
clear all; close all; clc

%% set path
folder = 'C:\Users\xiuye\Dropbox\!Research\2Pcode\Explore2p';
addpath(genpath(folder));
cd(folder)

%% launch GUI
Explore2p;

% and load some data (if not automatically loading default session)

%% export current variables
% File > Export to workspace

%% manual analyses in workspace
cIX = h.cIX(1:3:end);
gIX = h.gIX(1:3:end);

%% import back to GUI to visualize
% File > Import from workspace