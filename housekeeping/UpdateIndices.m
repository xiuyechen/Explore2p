% frequently used, updates cell-index,group-index,cluster-number. set-operations included in here.
function h = updateIndices(h,cIX,gIX,numK)
% toggle on/off: whether to cache tIX changes
% if h.ops.isCacheTimeIX
%     tIX_last = h.gui.tIX_last;
% else
%     tIX = h.tIX;
% end


%% 
if ~exist('gIX','var')
    gIX = h.gIX;
end
if ~exist('cIX','var')
    cIX = h.cIX;
end

if ~exist('numK','var')
    numK = h.numK;
end

if isempty(cIX)
    disp('empty set!');
%     errordlg('empty set!');
    return;
end

%% update cache
bC = h.gui.backCache; 

cIX_last = h.cIX;
gIX_last = h.gIX;
numK_last = h.numK;
if ~(isequal(cIX_last,cIX) && isequal(gIX_last,gIX) && isequal(numK_last,numK))
    bC.cIX = [cIX_last,bC.cIX];
    bC.gIX = [gIX_last,bC.gIX];
    bC.numK = [h.numK,bC.numK];
    set(h.gui.back,'enable','on');
    if length(bC.cIX)>20
        bC.cIX(end) = [];
        bC.gIX(end) = [];
        bC.numK(end) = [];
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
%         case 5,
%             disp('parent full clus');
%             cIX_parent = cIX;
%             gIX_parent = gIX;
%             [IX,ia,~] = intersect(cIX_parent,cIX_last);
% %             numK = length(unique(gIX_last));
%             U = unique(gIX_parent(ia));
%             gIX = [];
%             cIX = [];
%             for i_U = 1:length(U),
%                 ix = find(gIX_parent==U(i_U));
%                 gIX = [gIX;gIX_parent(ix)];
%                 cIX = [cIX;cIX_parent(ix)];
%             end
%         case 6,
%             disp('rev full clus'); % cIX_last is the parent set
%             [IX,ia,~] = intersect(cIX_last,cIX);
% %             numK = length(unique(gIX_last));
%             U = unique(gIX_last(ia));
%             gIX = [];
%             cIX = [];
%             for i_U = 1:length(U),
%                 ix = find(gIX_last==U(i_U));
%                 gIX = [gIX;gIX_last(ix)];
%                 cIX = [cIX;cIX_last(ix)];
%             end
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
h.cIX_abs = h.absIX(h.cIX);

% h.cIX = cIX;
% h.gIX = gIX;

% flag
% M = GetTimeIndexedData(hfig);
% setappdata(hfig,'M',M);
h = getFuncData(h);
% h = updateTimeIndexedData(h);

if exist('numK','var')
    h.numK = double(numK);
end

h = getColormap(h);

if length(h.cIX)>200
    h.flag.plotLines = 0;
    set(h.gui.plotlines,'Checked','off');
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
