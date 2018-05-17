function h = refreshFigure(h)
figure(h.hfig);

% clean-up canvas
allAxesInFigure = findall(h.hfig,'type','axes');
if ~isempty(allAxesInFigure)
    delete(allAxesInFigure);
end
% 
% % h1 = axes('Position',[0.05, 0.04, 0.55, 0.83]);
% % h2 = axes('Position',[0.63, 0.04, 0.35, 0.83]);
% scrn = get(0,'Screensize');
% margin = scrn(3)*0.01; % use double margin on left of fig. 
% wd_fig = scrn(3)*0.5; % hard coded
% ht_fig = scrn(4)*0.5; % hard coded
% ht_ax2 = ht_fig*0.8;
% h1 = axes('Units','pixels','Position',[margin*2, margin, wd_fig-ht_ax2-margin*4, ht_ax2]);
% h2 = axes('Units','pixels','Position',[wd_fig-ht_ax2-margin, margin, ht_ax2, ht_ax2]);

pos = get(h.hfig,'Position'); % pos(3) is width, pos(4) is height
margin = pos(4)*0.04;
ax2_ht = pos(4)*0.8;
h2 = axes('Units','pixels','Position',[pos(3)-ax2_ht-margin,margin,ax2_ht,ax2_ht],'Units','pixels');
h1 = axes('Units','pixels','Position',[margin*2, margin, pos(3)-ax2_ht-margin*4, ax2_ht]);

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
