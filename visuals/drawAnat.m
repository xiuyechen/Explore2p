function h = drawAnat(h)
roiIX = h.roiIX; 

%% plot mean image with ROI's drawn on top.
% mean image
im_bg0 = squeeze(h.dat.mimg(:,:,2));

% ROI image
Lx = h.dat.ops.Lx;
Ly = h.dat.ops.Ly;
Sat1 = ones(Ly, Lx);
Sat2 = ones(Ly, Lx);
H1 = zeros(Ly, Lx);
H2 = zeros(Ly, Lx);

% % chose cells
% for i = 1:length(h.dat.stat)
%     h.dat.stat(i).iscell = (ismember(i,cIX));
% end
% %
% [iclust1, iclust2, V1, V2] = ...
%     getviclust(h.dat.stat, h.dat.cl.Ly,  h.dat.cl.Lx, h.dat.cl.vmap, h.dat.F.ichosen);
if isfield(h.dat,'cl')
    vmap = h.dat.cl.vmap;
else
    vmap = 'unit';
end
[iclust1,V1] = getviclustRange(h.dat.stat, Ly,  Lx, vmap, roiIX);

% iselect in Suite2p is drawn in gray;
% iselect     = iclust1==h.dat.F.ichosen;
% Sat1(iselect)= 0;
%
% iselect     = iclust2==h.dat.F.ichosen;
% Sat2(iselect)= 0;

%% get colors
% if strcmp(h.vis.clrmaptype,'hsv')
%     % apply colors to anat map
%     Hmap_abs = zeros(1,length(h.dat.stat)); % each cell gets a color, saved into h.clrmap for use across the gui
%     huemat = h.huemap(h.gIX,1);
%     Hmap_abs(cIX_abs) = huemat;
%     % size of clrmap is now 1*numROIs
%     H1(iclust1>0)   = Hmap_abs(iclust1(iclust1>0)); % size of H1 is X*Y
%     
%     
%     % H1(iclust1>0)   = h.dat.cl.rands(iclust1(iclust1>0));
%     % H2(iclust2>0)   = h.dat.cl.rands(iclust2(iclust2>0));
%     
%     im_roi = hsv2rgb(cat(3, H1, Sat1, V1)); % convert HSV into RGB, size of im_roi is X*Y*3
%     im_roi = min(im_roi, 1); % make sure no RGB values exceed 1, should all be between 0 and 1
% 
%     
% else  % use RGB 
    clrmap_abs = zeros(length(find(h.IsCell)),3); % each cell gets a color, saved into h.clrmap for use across the gui
    clrmat = h.vis.clrmap(h.gIX,:);
    clrmap_abs(roiIX,1) = clrmat(:,1);
    clrmap_abs(roiIX,2) = clrmat(:,2);
    clrmap_abs(roiIX,3) = clrmat(:,3);
    
    % (the following is cumbersome but gets the indexing done)
    R = zeros(size(im_bg0));
    G = zeros(size(im_bg0));
    B = zeros(size(im_bg0));
    Rclrmap_abs = clrmap_abs(:,1);
    Gclrmap_abs = clrmap_abs(:,2);
    Bclrmap_abs = clrmap_abs(:,3);
    R(iclust1>0)   = Rclrmap_abs(iclust1(iclust1>0));
    G(iclust1>0)   = Gclrmap_abs(iclust1(iclust1>0));
    B(iclust1>0)   = Bclrmap_abs(iclust1(iclust1>0));
    im_roi = cat(3,R,G,B);
% end

% make grayscale background image in RGB
im_bg1 = mat2gray(im_bg0);
im_bg = repmat(im_bg1,1,1,3);
Low_High  = [0,0.5];
im_bg = imadjust(im_bg,Low_High); 

% combine colored pixels with the black and white anat background
IX = find(im_roi); 
im_anat = 0.5*im_bg;
im_anat(IX) = im_roi(IX); 

h.vis.im_anat = im_anat; % output

% Low_High  = [0,0.5];
% im4 = imadjust(im3,Low_High);
% imshow(im4)

%% draw on current axes
imagesc(h.vis.im_anat);
axis equal; axis off; axis ij;

% add number labels of all ROI's (if not too many ROI's)
if h.vis.isShowTextAnat %length(cIX_abs)<50
    
    [~,ix_sort] = sort(h.gIX,'ascend');
    for i = 1:length(roiIX)
        ii = ix_sort(i);
        ichosen = roiIX(i);
        x0 = mean(h.dat.stat(ichosen).xpix);
        y0 = mean(h.dat.stat(ichosen).ypix);        
        str = num2str(h.cIX(ii));
        if x0>20
            text(x0-10,y0,str,'color','w','HorizontalAlignment','right');%clr);
        else
            text(x0+10,y0,str,'color','w','HorizontalAlignment','left');%clr);
        end
    end
end
end