function h = DrawAnat(h)
cIX = h.cIX;
cIX_abs = h.IX_ROI(cIX);

%% plot mean image with ROI's drawn on top.
% mean image
im_bg0 = squeeze(h.dat.mimg(:,:,2));

% ROI image
Sat1     =  ones(h.dat.cl.Ly, h.dat.cl.Lx);
Sat2     =  ones(h.dat.cl.Ly, h.dat.cl.Lx);
H1              = zeros(h.dat.cl.Ly, h.dat.cl.Lx);
H2              = zeros(h.dat.cl.Ly, h.dat.cl.Lx);

% % chose cells
% for i = 1:length(h.dat.stat)
%     h.dat.stat(i).iscell = (ismember(i,cIX));
% end
% %
% [iclust1, iclust2, V1, V2] = ...
%     getviclust(h.dat.stat, h.dat.cl.Ly,  h.dat.cl.Lx, h.dat.cl.vmap, h.dat.F.ichosen);

[iclust1,V1] = getviclust(h.dat.stat, h.dat.cl.Ly,  h.dat.cl.Lx, h.dat.cl.vmap, cIX_abs);

% iselect in Suite2p is drawn in gray;
% iselect     = iclust1==h.dat.F.ichosen;
% Sat1(iselect)= 0;
%
% iselect     = iclust2==h.dat.F.ichosen;
% Sat2(iselect)= 0;

% % make colormap
h.clrmaptype = 'hsv';
if h.clrmaptype == 'hsv' % use HSV coding, which, in the Value channel includes information from 'lambda' (from ROI stats)
    numK = length(cIX);
    Hmap = linspace(0,0.8,numK); % to make a custom hsv map that doesn't include the circular overlap range in magenta-red (by not using range 0 to 1)
    Hmap_abs = zeros(1,length(h.dat.stat)); % each cell gets a color, saved into h.clrmap for use across the gui
    Hmap_abs(cIX_abs) = Hmap;

    % size of clrmap is now 1*numROIs
    H1(iclust1>0)   = Hmap_abs(iclust1(iclust1>0)); % size of H1 is X*Y
    
    
    % H1(iclust1>0)   = h.dat.cl.rands(iclust1(iclust1>0));
    % H2(iclust2>0)   = h.dat.cl.rands(iclust2(iclust2>0));
    
    im_roi = hsv2rgb(cat(3, H1, Sat1, V1)); % convert HSV into RGB, size of I is X*Y*3
    im_roi = min(im_roi, 1); % make sure no RGB values exceed 1, should all be between 0 and 1
    
    clrmap = squeeze(hsv2rgb(cat(3, Hmap, ones(size(Hmap)), ones(size(Hmap)))));
    
else % use RGB (not tested)
    numK = length(cIX);
    clrmap = jet(numK);
    clrmap_abs = zeros(1,length(h.dat.stat)); % each cell gets a color, saved into h.clrmap for use across the gui
    clrmap_abs(cIX) = clrmap;
    
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
end

inew = find(V1>0); % these are the colored pixels that need to be drawn on top of the black and white anat background
% combine and draw
im_bg1 = mat2gray(im_bg0);
im_bg = repmat(im_bg1,1,1,3);
Low_High  = [0,0.5];
im_bg = imadjust(im_bg,Low_High); % im1: grayscale background, in RGB

im_anat = 0.5*im_bg;%+im_roi); % copy to init
im_anat(inew) = im_roi(inew); % draw colors again in R channel,...
numpix = numel(H1);
im_anat(inew+numpix) = im_roi(inew+numpix); % ...in Green channel,
im_anat(inew+2*numpix) = im_roi(inew+2*numpix); % ... and in Blue channel


h.im_anat = im_anat; % output
h.clrmap = clrmap;

end