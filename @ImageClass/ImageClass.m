classdef ImageClass % h.im = ImageClass
    %{
    data structured for a single session
    This class is initiated when the GUI first loads data.
    Data all goes under this handle, so that by default functions don't have to
    pass values around.
    
    ...
    In the future, when analyzing multiple sessions, maybe an array of
    these objects can be handled at once with 'extractfield'.

    %}
    % functional data class, imports from suite2p output file (*proc.mat)
    properties (SetAccess=private) % dynamically sliced % Dependent?
        
        M % dynamically sliced calcium traces
        stim
        behavior
    end
    properties (Constant)
        dat = []; %loadProcMat; % flag % load from suite2p output (procmat)
    end
    properties (Dependent, Hidden)
        % for renaming purposes
    end
    properties
        % for slicing
        tIX % time index array
        cIX % cell index array
        
        % operations and display
        gIX % grouping index array
        numK % number of groups/colors, corresponding to colormap
%         clrmap % colormap
        
        % properties only used in gui (e.g. gui element handles not recorded here)
        gui = struct;
        
        % gui options
        ops = struct; % struct, not editable
        
        % testing new properties here
        vis = struct('clrmaptype','rand'...
            );
    end
    
    methods
        %% constructor % load
        function h = ImageClass()
            
            %% gui % init in GUI?
            h.gui.backCache = [];
            h.gui.fwCache = [];
%             % GUI cache
            % bCache = [];
            % fCache = [];
            % bCache.cIX = cell(1,1);
            % bCache.gIX = cell(1,1);
            % bCache.numK = cell(1,1);
            % fCache.cIX = cell(1,1);
            % fCache.gIX = cell(1,1);
            % fCache.numK = cell(1,1);
            % h.gui.backCache = bCache;
            % h.gui.fwCache = fCache;
            
            %% ops
            h.ops.plotLines = 1;
            h.ops.haveFrameInfo = 0;
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
