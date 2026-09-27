function validateCovarianceImage(T, lines, samples)
validateattributes(lines, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
validateattributes(samples, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
fields = {'C11', 'C12', 'C22'};
for k = 1:numel(fields)
    name = fields{k};
    if ~isstruct(T) || ~isscalar(T) || ~isfield(T, name) || ...
            ~isnumeric(T.(name)) || ~isequal(size(T.(name)), [lines, samples])
        error('RainFlood:InvalidCovariance', ...
            'T.%s must be a numeric matrix of size [%d,%d].', name, lines, samples);
    end
end
end
