function [stimCode,stimCodeNameArray] = get_stimCode_from_frameInfo_API(frameInfo)
% here: MANUAL INPUT for stimulus keys (stimCodeNameArray)

rawcodes = extractfield(frameInfo, 'EventValue');

[~,~,ic] = unique(rawcodes);
% C = [0,0.2,0.4,0.6,0.8,1]; % for test data
stimCode = ic'-1; % codes are now integers. new code 0 corresponds to raw 0

% manual input !!!
isKeep0 = 1;
if isKeep0
   stimCode = stimCode + 1; % lowest code is 1 instead of 0
end

stimCodeValueArray = 1:max(stimCode);%[0.2,0.4,0.6,0.8,1];% not counting 0

%% MANUAL INPUT for stimCodeNameArray
if length(stimCodeValueArray)==5
    stimCodeNameArray = {'A','B','C','D','Grey'}; % manual

elseif length(stimCodeValueArray)==8
    stimCodeNameArray = {'this','needs','to','be','typed','in','some','where'}; % temp
    disp('Stimulus key missing in Explore2p\input\get_stimCode_from_frameInfo_API.m');
    
else
    disp('Stimulus key missing in Explore2p\input\get_stimCode_from_frameInfo_API.m');
%     title = 'User input for stimulus code';
%     prompt = 'Enter names for distinct stimulus values (smallest to biggest value), seperated by '',''';
%     answer = inputdlg(prompt,title);
    
%     % parse the answer...
    
    
end

end