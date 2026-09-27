function Nvector = NormalizeCommon(vector, lower, upper)
if nargin < 2
    lower = -1;
    upper = 1;
elseif nargin < 3
    upper = 1;
end
validateattributes(lower, {'numeric'}, {'real', 'finite', 'scalar'});
validateattributes(upper, {'numeric'}, {'real', 'finite', 'scalar', '>=', lower});
vector = double(vector);
Nvector = nan(size(vector));
valid = isfinite(vector);
if ~any(valid(:))
    return;
end
values = vector(valid);
minimum = min(values);
span = max(values) - minimum;
if span == 0
    Nvector(valid) = lower;
else
    Nvector(valid) = lower + (upper - lower) * (values - minimum) / span;
end
end
