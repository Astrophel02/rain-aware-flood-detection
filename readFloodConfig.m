function cfg = readFloodConfig(filename)
if nargin == 0
    filename = fullfile(fileparts(mfilename('fullpath')),'Config.yaml');
end
cfg = readFlatYaml(filename);
[found, attributes] = fileattrib(filename);
if ~found, error('RainFlood:ConfigNotFound','Cannot locate configuration: %s',filename); end
configDirectory = fileparts(attributes.Name);
for key = {'T1Path','T2Path','outputDirectory'}
    if isfield(cfg,key{1}) && ischar(cfg.(key{1}))
        value = cfg.(key{1});
        if isempty(regexp(value,'^(?:[A-Za-z]:[\\/]|[\\/])','once'))
            cfg.(key{1}) = fullfile(configDirectory,value);
        end
    end
end
if ~isfield(cfg,'segmentationMethod')
    cfg.segmentationMethod = 'MS-MRF';
    if isfield(cfg,'mrfRefineBoundary') && isequal(cfg.mrfRefineBoundary,false)
        cfg.segmentationMethod = 'Superpixel-SS-MRF';
    end
end
required = {'lines','samples','T1Path','T2Path','outputDirectory','diffMethod', ...
    'superpixelMethod','superpixelScale','superpixelMaxIter','superpixelBeta', ...
    'superpixelTolerance','superpixelChangeWeight','edgeWindowLength', ...
    'edgeWindowWidth','enlWindowSize','mrfMaxIter','mrfLambda','mrfPixelLambda', ...
    'mrfEta','mrfBoundaryRadius','mrfMinSigma','mrfStopFraction','mrfDataWeight', ...
    'mrfIntraWeight','segmentationMethod'};
missing = setdiff(required,fieldnames(cfg));
unknown = setdiff(fieldnames(cfg),[required,{'mrfRefineBoundary'}]);
if ~isempty(missing) || ~isempty(unknown)
    error('RainFlood:InvalidConfig','Missing keys: [%s]. Unknown keys: [%s].', ...
        strjoin(missing,', '),strjoin(unknown,', '));
end
for key = {'T1Path','T2Path','outputDirectory','diffMethod','superpixelMethod','segmentationMethod'}
    validateattributes(cfg.(key{1}),{'char'},{'row','nonempty'},mfilename,key{1});
end
for key = {'lines','samples','superpixelMaxIter','edgeWindowLength','edgeWindowWidth','enlWindowSize'}
    validateattributes(cfg.(key{1}),{'numeric'},{'scalar','integer','positive','finite'},mfilename,key{1});
end
validateattributes(cfg.superpixelScale,{'numeric'},{'scalar','real','positive','finite'});
validateattributes(cfg.mrfMaxIter,{'numeric'},{'scalar','integer','nonnegative','finite'});
for key = {'superpixelBeta','superpixelTolerance','superpixelChangeWeight'}
    validateattributes(cfg.(key{1}),{'numeric'},{'scalar','real','nonnegative','finite'},mfilename,key{1});
end
cfg.diffMethod = validatestring(cfg.diffMethod,{'HLT','HLT_rain'});
cfg.superpixelMethod = validatestring(cfg.superpixelMethod,{'reference','polsar'});
cfg.segmentationMethod = validatestring(cfg.segmentationMethod, ...
    {'Otsu','Pixel-SS-MRF','Superpixel-SS-MRF','MS-MRF'},mfilename,'segmentationMethod');
cfg.requiresSuperpixels = ismember(cfg.segmentationMethod,{'Superpixel-SS-MRF','MS-MRF'});
cfg.mrfRefineBoundary = strcmp(cfg.segmentationMethod,'MS-MRF');
if strcmp(cfg.segmentationMethod,'Pixel-SS-MRF')
    validateattributes(cfg.mrfMaxIter,{'numeric'},{'positive'},mfilename,'mrfMaxIter');
end
cfg.superpixelOptions = struct('Method',cfg.superpixelMethod,'Scale',cfg.superpixelScale, ...
    'MaxIter',cfg.superpixelMaxIter,'Beta',cfg.superpixelBeta, ...
    'Tolerance',cfg.superpixelTolerance,'ChangeWeight',cfg.superpixelChangeWeight, ...
    'EdgeWindowLength',cfg.edgeWindowLength,'EdgeWindowWidth',cfg.edgeWindowWidth, ...
    'ENLWindowSize',cfg.enlWindowSize);
cfg.mrfOptions = mrfDefaultOptions(struct('lambda_sp',cfg.mrfLambda, ...
    'lambda_px',cfg.mrfPixelLambda,'sigmaEdge',cfg.mrfEta,'bandRadius',cfg.mrfBoundaryRadius, ...
    'minSigma',cfg.mrfMinSigma,'stopFrac',cfg.mrfStopFraction,'alpha',cfg.mrfDataWeight, ...
    'k_intra',cfg.mrfIntraWeight,'RefineBoundary',cfg.mrfRefineBoundary));
end
