classdef ImageClass % h = ImageClass
    % functional data class, imports from suite2p output file (*proc.mat)
    % maybe make constructor take mouse/date/session, and a 'isGUI' flag
    % for scripts?
    %{
    data structured for a gui session
    This class is initiated when the GUI first loads data.


    ImageClass object can be used either with the GUI or in script.
    - GUI:    
    Object created at GUI initiation. One GUI window only handles data
    from one imaging session, but multiple GUI windows can be used at
    once if different handles are specified (e.g. h_mouseX = Explore2p;)
    All data is stored under this object. Most functions only pass
    the object (h) as both the input and the output.
    
    - Script:
    see demo\demo_script
    
    Tip:
    If you are not familiar with 'objects', it behaves pretty much like a
    struct with fields (e.g. access 'timeInfo' by typing 'h.timeInfo').
    Only the dependent properties are a little different, e.g. 'roiIX' is  
    calculated from 'h.IsCell' only when retrieved.
    
    === CUSTOMIZATION ===
    
    Here are lists of functions that need to be customized for various
    scenarios.
    
    1. Imaging data input, if using non-suit2p *proc.mat files
    - input\initSessionData
    - input\loadSessionData
    
    2. Stimulus/behavior input data, a file we call 'frameInfo' 
    (currently, information about each frame is saved as a struct, and 
    a field 'EventInfo' holds a raw stimulus code)
    - input\get_stimCode_from_frameInfo_API': output of this function is
    a vector of 1*nFrames, non-negative interger values to represent
    unique stimulus types. Also specify stimulus code keys here. 

    3. Stimulus paradigms (stimulus code corresponding to experimental design)    
    - input\parseStimCode    
    - @ImageClass\getTimeIndex
    - input\getStimAvgTimeIndex    
            
    %}

    properties
        % figure handle of the main GUI
        hfig % exist(h.hfig) is also used in scripts to check whether running GUI window vs. stand-alone scripts
        
        % storage of input data (static for a given data session)
        dat = struct % store suite2p output data (*_proc.mat) exactly as is into this field
        timeInfo = struct % load frameInfo data that contains frame-by-frame stim/behavior info, parse into relevant params and store here as a struct
        
        % core (dynamic) properties, for slicing functional data 'M' [see properties (SetAccess=private)]
        tIX % time index array, 1xn
        cIX % cell index array, or 'chosen'; nx1
                
        % operations and display
        gIX % grouping index array, for clustering/color display % same size as cIX
        numK % number of groups/colors, corresponding to colormap
        %         clrmap % colormap
        
        cellvsROI % flag, 1 = show cells, 0 = show ROI's
        
        IsCell % logical array of 0's (this ROI is not a cell) and 1's (this ROI is considered a cell)
        IsChosen % if show cells, IsChosen = IsCell; elseif show ROIs, IsChosen = 1:nROIs        
        
        % visualization fields
        vis = struct % see constructor for fields
        
        % options (mostly set from gui, can use in scripts too)
        ops = struct % see constructor for fields
        
        % properties only used in gui (e.g. gui element handles and cache)
        gui = struct % see constructor for fields
        
        %% these should be private set
%         M % dynamically sliced calcium traces, depends on cIX and tIX
%         M_0 % traces for all ROI's (not just cells), depends on tIX
%         stim % depends on tIX
%         behavior % depends on tIX
        
        %% template for future fields
        % convinient to have a struct that can be grown after classdef
        temp = struct        
        
    end
    
    properties (SetAccess=private) % when housekeeping functions are moved into Class code        
        M % dynamically sliced calcium traces, depends on cIX and tIX
        M_0 % traces for all ROI's (not just cells), depends on tIX
        stim % depends on tIX
        %         behavior % depends on tIX
    end
    
    properties (Dependent) % dependent properties only calculated when accessed        
        roiIX % ROI index corresponding to cIX - the current selection of cells (or ROI's)
        nROIs % total number of ROI's in this session
        nCells % total number of cells in this session
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
        function val = get.roiIX(h)
            absIX = find(h.IsChosen); 
            val = absIX(h.cIX);
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
                
        %% (template) local functions (defined here)
        % (or place functions in separate files in this class folder)
        function View(h)
            figure();
            imagesc(h.M)
        end
    end        
end
