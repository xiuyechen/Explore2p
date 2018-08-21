
function h = updateIndices(h,cellvsROI,arg1,arg2,arg3,arg4)
% frequently used, updates cell-index,group-index,cluster-number. set-operations included in here.
% updateIndices(h,cellvsROI,cIX,gIX,numK,tIX)
% updateIndices(h,cellvsROI,cIX,gIX,numK)
% updateIndices(h,cellvsROI,cIX,gIX)
% updateIndices(h,cellvsROI,tIX) % CAUTION: NOT == updateIndices(h,cellvsROI,cIX)
% updateIndices(h,cellvsROI)
% updateIndices(h)

if nargin == 3
    tIX = arg1;
elseif nargin == 4
    cIX = arg1;
    gIX = arg2;
elseif nargin == 5
    cIX = arg1;
    gIX = arg2;
    numK = arg3;
elseif nargin == 6
    cIX = arg1;
    gIX = arg2;
    numK = arg3;
    tIX = arg4;
end

% toggle on/off: whether to cache tIX changes
% if h.ops.isCacheTimeIX
%     tIX_last = h.gui.tIX_last;
% else
%     tIX = h.tIX;
% end

%% 
if ~exist('cellvsROI','var')
    cellvsROI = h.cellvsROI;
end
if ~exist('cIX','var') || isempty(cIX)
    cIX = h.cIX;
end
if ~exist('gIX','var')
    gIX = h.gIX;
end
if ~exist('numK','var')
    numK = h.numK;
end
if ~exist('tIX','var')
    tIX = h.tIX;
end

if isempty(cIX)
    disp('empty set!');
%     errordlg('empty set!');
    return;
end

%% cell vs ROI?

% if h.ops.isCellnotROIix
%     h.roiIX = h.absIX(cIX);
%     h.absIX = find(h.IsCell);
% else
%     h.roiIX = cIX;
%     
%     % convert roiIX input into new cIX, given the updated absIX?
%     h.cIX = h.roiIX;
%     h.gIX = ones(size(h.cIX));
% end

%% update cache
bC = h.gui.backCache; 

cIX_last = h.cIX;
gIX_last = h.gIX;
numK_last = h.numK;
tIX_last = h.tIX;
cellvsROI_last = h.cellvsROI;
if ~(isequal(cIX_last,cIX) && isequal(gIX_last,gIX) && isequal(numK_last,numK) && isequal(tIX_last,tIX))
    bC.cIX = [cIX_last,bC.cIX];
    bC.gIX = [gIX_last,bC.gIX];
    bC.numK = [h.numK,bC.numK];
    bC.tIX = [tIX_last,bC.tIX];
    bC.cellvsROI = [cellvsROI_last,bC.cellvsROI];
    
    set(h.gui.back,'enable','on');
    if length(bC.cIX)>20
        bC.cIX(end) = [];
        bC.gIX(end) = [];
        bC.numK(end) = [];
        bC.tIX(end) = [];
        bC.cellvsROI(end) = [];
    end
end
 
%% set operations, if applicable
% opID = getappdata(hfig,'opID');
% if opID ~= 0,
%     switch opID,
%         case 1,
%             disp('union');
%             [~,ia,ib] = union(cIX_last,cIX,'stable');
%             IX = vertcat(cIX_last(ia),cIX(ib));% IX;
%         case 2,
%             disp('intersect');
%             [IX,ia,~] = intersect(cIX_last,cIX);
%             ib = [];
%         case 3,
%             disp('setdiff');
%             [IX,ia] = setdiff(cIX_last,cIX);
%             ib = [];
%         case 4,
%             disp('rev setdiff');
%             % swap sequence, then same as opID==3
%             temp = cIX;
%             cIX = cIX_last;
%             cIX_last = temp;
%             temp = gIX;
%             gIX = gIX_last;
%             gIX_last = temp;
%             [IX,ia] = setdiff(cIX_last,cIX);
%             ib = [];        
%     end
%     if opID<5,
%         if ~isempty(IX),
%             cIX = IX;
%             gIX = vertcat(gIX_last(ia),gIX(ib)+max(gIX_last(ia)));
%             numK = length(unique(gIX));
%             %         [gIX, numK] = SqueezeGroupIX(gIX);
%         else
%             errordlg('operation result is empty set!')
%             waitforbuttonpress;
%         end
%     end
%     set(h.gui.opID,'Value',1,'BackgroundColor',[1,1,1]); % reset
%     setappdata(hfig,'opID',0);
% end
%%
h.gui.backCache = bC;


% sort based on gIX
[~,I] = sort(gIX);
h.cIX = cIX(I);
h.gIX = gIX(I);

% only M depends on cIX change... 
% whereas a tIX change requires more updates

h.tIX = tIX;

h.cellvsROI = cellvsROI;
h = setCellvsROI(h);

%%
h = getIndexedData(h); % updates variables depending on tIX (M_0,M,behavior,stim)

if exist('numK','var')
    h.numK = double(numK);
end

h = getColormap(h);

if length(h.cIX)>200
    h.vis.isPlotLines = 0;
    set(h.gui.plotLines,'Checked','off');
end
%% Resets: reset flags the NEXT time this function is called (so they only apply to this particular plot)
% handle rankID: >=2 means write numbers as text next to colorbar
% first UpdateIndices sets rankID to 100, second sets back to 0
% rankID = getappdata(hfig,'rankID');
% if rankID>=2,
%     if rankID==100,
%         setappdata(hfig,'rankID',0);
%     else
%         setappdata(hfig,'rankID',100);
%     end
% end

% % toggle 'isWeighAlpha'
% isWeighAlpha = getappdata(hfig,'isWeighAlpha');
% if isWeighAlpha == 1,
%     setappdata(hfig,'isWeighAlpha',100);
% elseif isWeighAlpha == 100,
%     setappdata(hfig,'isWeighAlpha',0);
% end
%%
% guidata(hObject, h);

end
