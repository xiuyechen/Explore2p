function val = parseVarargin(vargs, name, default)
% Gets value for name/value pair. If the name is not found, then a default
% value is returned (NaN by default, but the 'default' can be used to
% specify another default value.

narginchk(2, 3);

% Find element that occurs after 'name'. If it exists, return it.
for ii = 1:(numel(vargs)-1)
    if strcmp(vargs{ii}, name)
        val = vargs{ii+1};
        return
    end
end

% Return default value.
if nargin == 2
    val = NaN;
else
    val = default;
end
end