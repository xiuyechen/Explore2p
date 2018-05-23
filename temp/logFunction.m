function logFunction(varargin)

logStr = func2str(varargin{:});
eval(logStr);

fprintf('>> %s\n',logStr);