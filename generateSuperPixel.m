function labels = generateSuperPixel(T1, T2, Scale, EDGE, ENL, lines, samples, maxiter, beta, tolerance, options)
if nargin == 4 && isstruct(EDGE)
    settings = EDGE;
    differenceImage = Scale;
    validateattributes(differenceImage,{'numeric'},{'real','2d','nonempty'});
    [lines,samples] = size(differenceImage);
    Scale = settings.Scale; maxiter = settings.MaxIter;
    beta = settings.Beta; tolerance = settings.Tolerance;
    options = rmfield(settings,{'Scale','MaxIter','Beta','Tolerance'});
    options.DifferenceImage = differenceImage;
    EDGE = []; ENL = [];
elseif nargin < 11
    options = struct();
end
validateattributes(options, {'struct'}, {'scalar'});
allowed = {'Method','DifferenceImage','NumSuperpixels','ChangeWeight', ...
    'EdgeWindowLength','EdgeWindowWidth','ENLWindowSize'};
unknown = setdiff(fieldnames(options),allowed);
if ~isempty(unknown)
    error('RainFlood:UnknownSuperpixelOption','Unknown option: %s.',unknown{1});
end
validateattributes(lines, {'numeric'}, {'scalar','integer','positive','finite'});
validateattributes(samples, {'numeric'}, {'scalar','integer','positive','finite'});
validateattributes(Scale, {'numeric'}, {'scalar','positive','finite','real'});
if ~isfield(options,'Method'), options.Method = 'polsar'; end
if ~isfield(options,'NumSuperpixels')
    options.NumSuperpixels = max(1,round(lines*samples/Scale));
end
validateattributes(options.NumSuperpixels, {'numeric'}, ...
    {'scalar','integer','positive','finite','<=',lines*samples});
method = validatestring(options.Method,{'reference','polsar'});
if strcmp(method,'reference')
    if ~isfield(options,'DifferenceImage')
        error('RainFlood:MissingDifferenceImage','Reference mode requires the downstream DifferenceImage.');
    end
    image = options.DifferenceImage;
    validateattributes(image, {'numeric'}, {'real','2d','nonempty'});
    if ~isequal(size(image),[lines,samples])
        error('RainFlood:InvalidFeatureSize','DifferenceImage must match [lines,samples].');
    end
    image(isnan(image)) = 0;
    if any(~isfinite(image(:)))
        error('RainFlood:InfiniteDifferenceImage','DifferenceImage contains Inf.');
    end
    labels = superpixels(image,options.NumSuperpixels);
    return;
end
validateCovarianceImage(T1,lines,samples);
validateCovarianceImage(T2,lines,samples);
validateattributes(maxiter, {'numeric'}, {'scalar','integer','positive','finite'});
validateattributes(beta, {'numeric'}, {'scalar','real','nonnegative','finite'});
validateattributes(tolerance, {'numeric'}, {'scalar','real','nonnegative','finite'});
if ~isfield(options,'EdgeWindowLength'), options.EdgeWindowLength = 7; end
if ~isfield(options,'EdgeWindowWidth'), options.EdgeWindowWidth = 7; end
if ~isfield(options,'ENLWindowSize'), options.ENLWindowSize = 20; end
if isempty(EDGE)
    EDGE_T1 = EdgeDetection(T1,options.EdgeWindowLength,options.EdgeWindowWidth);
    EDGE_T2 = EdgeDetection(T2,options.EdgeWindowLength,options.EdgeWindowWidth);
    EDGE = (EDGE_T1+EDGE_T2)/2;
end
if isempty(ENL)
    ENL1 = cacENL(T1,lines,samples,options.ENLWindowSize);
    ENL2 = cacENL(T2,lines,samples,options.ENLWindowSize);
    ENL = (ENL1+ENL2)/2;
end
if ~isequal(size(EDGE),[lines,samples]) || ~isequal(size(ENL),[lines,samples])
    error('RainFlood:InvalidFeatureSize','EDGE and ENL must match [lines,samples].');
end
if ~isfield(options,'ChangeWeight'), options.ChangeWeight = 0; end
validateattributes(options.ChangeWeight, {'numeric'}, {'scalar','nonnegative','finite'});
labels = generatePolSARSuperpixels(T1,T2,EDGE,ENL,options.NumSuperpixels, ...
    maxiter,beta,tolerance,options);
end
