function h = RefreshFigure(h)
h = UpdateIndices(h);
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


%% draw anat
% right subplot
axes(h2);
h = DrawAnat(h);
imagesc(h.im_anat);
% Low_High  = [0,0.5];
% im4 = imadjust(im3,Low_High);
% imshow(im4)
axis equal; axis off

% add number labels of all ROI's (if not too many ROI's)
cIX_abs = h.cIX_abs;
if length(cIX_abs)<50
    for i = 1:length(cIX_abs)
        ichosen = cIX_abs(i);
        x0 = mean(h.dat.stat(ichosen).xpix);
        y0 = mean(h.dat.stat(ichosen).ypix);
        clr = squeeze(hsv2rgb(h.clrmap(ichosen),1,1));
        if x0>20
            text(x0-10,y0,num2str(i),'color','w','HorizontalAlignment','right');%clr);
        else
            text(x0+10,y0,num2str(i),'color','w','HorizontalAlignment','left');%clr);
        end
    end
end

%% draw traces
% left subplot
axes(h1);hold on;
DrawTraces(h);
    



end
