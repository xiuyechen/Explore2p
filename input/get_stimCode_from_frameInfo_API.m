function stimCode = get_stimCode_from_frameInfo_API(frameInfo)
rawcodes = extractfield(frameInfo, 'EventValue');

[C,~,ic] = unique(rawcodes);
% C = [0,0.2,0.4,0.6,0.8,1]; % for test data
stimCode = ic'-1; % codes are now integers. new code 0 corresponds to raw 0

end