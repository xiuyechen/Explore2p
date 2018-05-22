classdef IOdata 
    % input/output data (to the brain)
    % i.e. stimulus and/or behavior for the corresponding imaging experiment
    properties (GetAccess=private)
        %  freely change the names or characteristics of a private property without affecting users of the object
    end
    properties (Constant)
    end
    properties (Dependent)
        % specify that a property is calculated only when asked for
    end
    properties        
        DI % discrete input (stimulus code)
        AI % analog input (stimulus variable)
        DO % discrete output (behavior code) 
        AO % analog output (behavior variable)
    end
    
    methods
        % constructor
%         function h = IOdata(hdat,flag)
%             h.Traces = hdat.Fcell;
%         end
        
        % other functions
        function regs = getRegressor(io)            
            regs = [];
        end
    end
    
    
end
        