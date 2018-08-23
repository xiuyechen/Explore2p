function h = refreshFigure(h,hfig_popup)
% draw functional traces and anatomical map side by side

if nargin == 2 % draw on popup window
    hfig = hfig_popup;
    ax_ht_ratio = 0.9;
else % draw on GUI
    hfig = h.hfig;
    ax_ht_ratio = 0.8;      
end

figure(hfig);

% clean-up canvas
allAxesInFigure = findall(hfig,'type','axes');
if ~isempty(allAxesInFigure)
    delete(allAxesInFigure);
end

% reset axes
pos = get(hfig,'Position'); % pos(3) is width, pos(4) is height
margin = pos(4)*0.04;
ax_ht = pos(4)*ax_ht_ratio;
h2 = axes('Units','pixels','Position',[pos(3)-ax_ht-margin,margin,ax_ht,ax_ht],'Units','pixels');
h1 = axes('Units','pixels','Position',[margin*2, margin, pos(3)-ax_ht-margin*4, ax_ht]);

%% make colormap
% h.clrmaptype = 'rand'; %'hsv';%% manual
h = getColormap(h);

%% draw traces
% left subplot
axes(h1);hold on;
drawTraces(h);
    
%% draw anat
% right subplot
axes(h2);hold on;
drawAnat(h);

end
