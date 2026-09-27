function filtered = filterCovarianceImage(T, weights)
validateattributes(weights, {'numeric'}, {'real','2d','nonnegative','finite','nonempty'});
if sum(weights(:)) == 0
    error('RainFlood:EmptyKernel','The covariance kernel must have positive weight.');
end
weights = weights / sum(weights(:));
valid = isfinite(T.C11) & isfinite(T.C12) & isfinite(T.C22);
mass = imfilter(double(valid), weights, 'symmetric', 'same');
names = {'C11','C12','C22'};
for k = 1:numel(names)
    values = T.(names{k});
    values(~valid) = 0;
    filtered.(names{k}) = imfilter(values, weights, 'symmetric', 'same') ./ max(mass,eps);
    filtered.(names{k})(mass == 0) = NaN;
end
end
