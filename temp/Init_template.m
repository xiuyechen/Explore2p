% initialization after loading F_.mat file

if flag
    % if the user selected a file, do all the initializations
rng('default')

% keyboard;
if isfield(h.dat, 'dat')
    h.dat = h.dat.dat;
else
    h.dat.filename = fullfile(filepath1, filename1);
    h.dat.cl.Ly       = numel(h.dat.ops.yrange);
    h.dat.cl.Lx       = numel(h.dat.ops.xrange);
    
    % make up iclut here
    try
        [h.dat.res.iclust, h.dat.res.lambda, h.dat.res.lambda0] =...
            getIclust(h.dat.stat, h.dat.cl);
    catch
    end
    h.dat.res.iclust = reshape(h.dat.res.iclust, h.dat.cl.Ly, h.dat.cl.Lx);
%     h.dat.res.lambda = reshape(h.dat.res.lambda, h.dat.cl.Ly, h.dat.cl.Lx);
    
    h.dat.ops.Nk = numel(h.dat.stat);
    h.dat.cl.rands_orig   = .1 + .65 * rand(1, h.dat.ops.Nk);
    h.dat.cl.rands        = h.dat.cl.rands_orig;
    
    if isfield(h.dat.ops, 'clustrules')
       h.dat.clustrules = h.dat.ops.clustrules; 
    end
    
    % set up classifier
    h.dat.cl.threshold  = 0.5;
    h                   = identify_classifier(h);    
    h                   = classROI(h);
    
    % set all quadrants as not visited
    h.quadvalue = zeros(3);
    for j = 1:3
        for i = 1:3
            set(h.(sprintf('Q%d%d', j,i)), 'BackgroundColor',[.92 .92 .92]);
        end
    end
    
    h.dat.ylim = [0 h.dat.cl.Ly];
    h.dat.xlim = [0 h.dat.cl.Lx];    
    
    if ~isfield(h.dat.stat,'redcell')
        for j = 1:numel(h.dat.stat)
            h.dat.stat(j).redcell = 0;
            h.dat.stat(j).redprob = 0;
        end
    end    
   
    h.dat.F.ichosen = 1;
    
    % loop through redcells and set h.dat.cl.rands(h.dat.F.ichosen) = 0
    for j = find([h.dat.stat.redcell])
        h.dat.cl.rands(j) = 0;
    end
   
    % x and y limits on subquadrants
    h.dat.figure.x0all = round(linspace(0, 19/20*h.dat.cl.Lx, 4));
    h.dat.figure.y0all = round(linspace(0, 19/20*h.dat.cl.Ly, 4));
    h.dat.figure.x1all = round(linspace(1/20 * h.dat.cl.Lx, h.dat.cl.Lx, 4));
    h.dat.figure.y1all = round(linspace(1/20 * h.dat.cl.Ly, h.dat.cl.Ly, 4));
    
end

% activate all pushbuttons
pb = [84 93 101 86 87 89 90 92 103 98 95 96 102 99 100 1 2 104 112];
for j = 1:numel(pb)
    set(eval(sprintf('h.pushbutton%d', pb(j))),'Enable','on')
end
pb = [11 12 13 21 22 23 31 32 33];
for j = 1:numel(pb)
    set(eval(sprintf('h.Q%d', pb(j))),'Enable','on')
end
set(h.full,'Enable', 'on');
set(h.edit50,'Enable', 'on');
set(h.edit50,'String', num2str(h.dat.cl.threshold));
set(h.edit52,'Enable', 'on');
set(h.edit54,'Enable', 'on');
set(h.edit52,'String','-Inf');
set(h.edit54,'String','Inf');
h.statstr = 'npix';
h.statstrs = {'npix','cmpct','aspect_ratio','skew','std','footprint','mimgProj'};
h.statnum = 1;
h.statmins = -Inf*ones(1,7);
h.statmaxs = Inf*ones(1,7);
set_Bcolor(h, 1);
set_maskCcolor(h, 1);
% select unit normalized ROI brightness
h.dat.cl.vmap = 'unit';
set_maskBcolor(h, 1);
set(h.full, 'BackgroundColor', [1 0 0])

% setup different views of GUI
h.dat.maxmap = 2;
ops = h.dat.ops;
if isfield(ops, 'mimg1') && ~isempty(ops.mimg1)
    h.dat.mimg(:,:,h.dat.maxmap) = ops.mimg1(ops.yrange, ops.xrange);
    h.dat.mimg_proc(:,:,h.dat.maxmap) = normalize_image(h.dat.mimg(:,:,h.dat.maxmap));
end
h.dat.mimg(:,:,5) = 0;

h.dat.maxmap = h.dat.maxmap + 1;
if isfield(ops, 'mimgRED') && ~isempty(ops.mimgRED)
    h.dat.mimg(:,:,h.dat.maxmap) = ops.mimgRED(ops.yrange, ops.xrange);
    h.dat.mimg_proc(:,:,h.dat.maxmap) = normalize_image(h.dat.mimg(:,:,h.dat.maxmap));
elseif isfield(ops, 'AlignToRedChannel') && ops.AlignToRedChannel == 1 && ...
        isfield(ops, 'mimg') && ~isempty(ops.mimg)
    h.dat.mimg(:,:,h.dat.maxmap) = ops.mimg(ops.yrange, ops.xrange);
    h.dat.mimg_proc(:,:,h.dat.maxmap) = normalize_image(h.dat.mimg(:,:,h.dat.maxmap));
end
h.dat.maxmap = h.dat.maxmap + 1;
if isfield(ops, 'mimgREDcorrected') && ~isempty(ops.mimgREDcorrected)
    if sum(size(ops.mimgREDcorrected)==[ops.Ly ops.Lx]) == 2
        h.dat.mimg(:,:,h.dat.maxmap) = ops.mimgREDcorrected(ops.yrange, ops.xrange);
    else
        h.dat.mimg(:,:,h.dat.maxmap) = ops.mimgREDcorrected;
    end
    h.dat.mimg_proc(:,:,h.dat.maxmap) = normalize_image(h.dat.mimg(:,:,h.dat.maxmap));
end
h.dat.maxmap = h.dat.maxmap + 1;
if isfield(ops, 'Vcorr') && ~isempty(ops.Vcorr)
    h.dat.mimg(:,:,h.dat.maxmap) = ops.Vcorr;
    h.dat.mimg_proc(:,:,h.dat.maxmap) = normalize_image(h.dat.mimg(:,:,h.dat.maxmap));
end

h.dat.procmap = 0;
h.dat.map = 1;

redraw_fluorescence(h);
redraw_figure(h);

guidata(hObject,h)
end