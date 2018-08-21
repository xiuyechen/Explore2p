classdef ImageClass % h = ImageClass
    % functional data class, imports from suite2p output file (*proc.mat)
    % maybe make constructor take mouse/date/session, and a 'isGUI' flag
    % for scripts
    %{
    data structured for a gui session
    This class is initiated when the GUI first loads data.
    Data all goes under this handle, so that by default functions don't have to
    pass values around.
    
    ...
    In the future, when analyzing multiple sessions, maybe an array of
    these objects can be handled at once.

    %}
    
    properties (SetAccess=private) % when housekeeping functions are moved into Class code
        
        %         M % dynamically sliced calcium traces, depends on cIX and tIX
        %         M_0 % depends on tIX
        %         stim % depends on tIX
        %         behavior % depends on tIX
        
        %         vis.clrmap % depends on cIX, gIX, numK and clrmaptype?
        
        %         absIX % depends on IsCell
    end
    %     properties (Constant)
    %
    %     end
    properties (Dependent, Hidden)
        % for renaming purposes
    end
    
    properties
        %
        hfig % ?? where is it used?
        
        % load data
        dat = []; %loadProcMat; % flag % load from suite2p output (procmat)
        timeInfo
        
        % core properties, for slicing
        tIX % time index array, 1xn
        cIX % cell index array, or 'chosen'; nx1
        
        %         absIX % absIX = find(IsCell); ROI index array ('absolute index', does not change with curation)
        
        
        % operations and display
        gIX % grouping index array, for clustering/color display % same size as cIX
        numK % number of groups/colors, corresponding to colormap
        %         clrmap % colormap
        
        cellvsROI
        
        % visualization fields
        vis = struct
        % options (set from gui), may be used in analysis
        ops = struct
        % properties only used in gui (e.g. gui element handles and cache)
        gui = struct
        
        %% these should be private set
        M % dynamically sliced calcium traces, depends on cIX and tIX
        M_0 % traces for all ROI's (not just cells), depends on tIX
        
        % TBD
        stim % depends on tIX
        behavior % depends on tIX
        
        %% temp or convinience fields
        temp = struct
        IsCell % absIX = find(IsCell);
        IsChosen % if show cells, IsChosen = IsCell; else, IsChosen = 1:nROIs
        
        % dependent values?
        %         nROI = length(IsCell);
        %         nCell = length(absIX);
        
    end
    
    properties (Dependent)
        roiIX % absIX corresponding to the current selection of cIX, roiIX = absIX(cIX);
        absIX % absIX = find(IsChosen); ROI index array ('absolute index', does not change with curation)
        
        nROIs
        nCells
    end
    
    
    methods
        %% constructor % load
        function h = ImageClass()
            
            %% vis
            vis = [];
            vis.clrmaptype = 'rand';
            vis.isPlotLines = 1;
            vis.isShowTextFunc = 1;
            vis.isShowTextAnat = 1;
            vis.isFixRandSeed = 1;
            
            h.vis = vis;
            
            %% ops
            ops = [];
            
            % data loading
            ops.haveFrameInfo = 0; % this flag hasn't been implemented..
            % functional format
            ops.isStimAvg = 0;
            ops.rangeBlocks = [];
            ops.rangeElm = [];
            
            % data format
            ops.isZscore = 1;
            
            %             ops.cellvsROI = 1;
            
            h.ops = ops;
            
            %% gui % init in GUI?
            gui = [];
            
            % GUI cache
            bCache = [];
            fCache = [];
            bCache.cIX = cell(1,1);
            bCache.gIX = cell(1,1);
            bCache.numK = cell(1,1);
            bCache.tIX = cell(1,1);
            bCache.cellvsROI = cell(1,1);
            
            fCache.cIX = cell(1,1);
            fCache.gIX = cell(1,1);
            fCache.numK = cell(1,1);
            fCache.tIX = cell(1,1);
            fCache.cellvsROI = cell(1,1);
            
            gui.backCache = bCache;
            gui.fwCache = fCache;
            
            % not recording gui element handles here
            
            % gui flags for gui vis
            gui.rankID = 0; % TBD
            
            h.gui = gui;
        end
        %% property get/set methods
        
        function val = get.absIX(h)
            val = find(h.IsChosen);
        end
        
        function val = get.roiIX(h)
            val = h.absIX(h.cIX);
        end
        
        function val = get.nROIs(h)
            val = length(h.IsCell);
        end
        
        function val = get.nCells(h)
            val = length(find(h.IsCell));
        end
        
        %% rename old variables (using dependent variables)
        %         % method 1
        %         function obj = set.cIX(obj,val)
        %             obj.cellIndex = val;
        %         end
        %         function value = get.cIX(obj)
        %             value = obj.cellIndex;
        %         end
        %
        %         % method 2: alias ??
        %         function value = get.cellIndex(obj)
        %             value = obj.cIX;
        %         end
        %
        %         function obj = set.cellIndex(obj,val)
        %             obj.cIX = val;
        %         end
        
        %% functions in separate files (in this class folder)
        test(h);
        
        %% local functions (defined here)
        function View(h)
            figure();
            imagesc(h.Traces)
        end
    end
    
    
end
