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
        
        % temporary!
        t_start
        t_stop
        
        % core properties, for slicing
        tIX % time index array
        cIX % cell index array, or 'chosen' 
        
        absIX % ROI index array ('absolute index', does not change with curation)
        cIX_abs % absIX corresponding to the current selection of cIX 
        
        % operations and display
        gIX % grouping index array, for clustering/color display
        numK % number of groups/colors, corresponding to colormap
%         clrmap % colormap
                
        % visualization fields
        vis = struct 
        % options (set from gui), may be used in analysis
        ops = struct
        % properties only used in gui (e.g. gui element handles and cache)
        gui = struct        
        
        %% these should be private set
        M % dynamically sliced calcium traces, depends on cIX and tIX
        M_0 % depends on tIX
        stim % depends on tIX
        behavior % depends on tIX
        
        %% temp or convinience fields
        temp = struct
        IsCell
    end
    
    methods
        %% constructor % load
        function h = ImageClass()
            %% vis 
            vis = [];
            vis.clrmaptype = rand;
                     
            h.vis = vis;
            
            %% ops
            ops = [];
            ops.plotLines = 1;
            % data loading
            ops.haveFrameInfo = 0;
            % functional format
            ops.isStimAvr = 0;
            
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
            
            fCache.cIX = cell(1,1);
            fCache.gIX = cell(1,1);
            fCache.numK = cell(1,1);
            fCache.tIX = cell(1,1);
            gui.backCache = bCache;
            gui.fwCache = fCache;

            % not recording gui element handles here
            
            % gui flags for gui vis
            gui.rankID = 0; % TBD
            
            h.gui = gui;
        end
        %% property get/set methods
        %         function h = set.clrmap(h,val)
        %             h.clrmap = val;
        %         end
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
