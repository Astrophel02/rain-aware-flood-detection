function options = mrfDefaultOptions(overrides)
options = struct('lambda_sp',1.2,'minSigma',0.01,'stopFrac',1e-3, ...
    'bandRadius',4,'alpha',1.0,'lambda_px',8.0,'sigmaEdge',0.08, ...
    'k_intra',1.5,'RefineBoundary',true);
if nargin == 0, return; end
validateattributes(overrides, {'struct'}, {'scalar'});
names = fieldnames(overrides);
for k = 1:numel(names)
    name = names{k};
    if ~isfield(options,name)
        error('RainFlood:UnknownMRFOption','Unknown MRF option: %s.',name);
    end
    options.(name) = overrides.(name);
end
for name = {'lambda_sp','lambda_px','alpha','k_intra'}
    validateattributes(options.(name{1}),{'numeric'},{'scalar','real','finite','nonnegative'});
end
for name = {'minSigma','sigmaEdge'}
    validateattributes(options.(name{1}),{'numeric'},{'scalar','real','finite','positive'});
end
validateattributes(options.stopFrac,{'numeric'},{'scalar','real','finite','>=',0,'<=',1});
validateattributes(options.bandRadius,{'numeric'},{'scalar','integer','finite','nonnegative'});
validateattributes(options.RefineBoundary,{'logical'},{'scalar'});
end
