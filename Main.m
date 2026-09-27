function [result, cfg, timing] = Main(configFile)
root = fileparts(mfilename('fullpath'));
originalPath = path;
cleanup = onCleanup(@() path(originalPath));
addpath(root);
if nargin < 1
    configFile = fullfile(root,'Config.yaml');
end
cfg = readFloodConfig(configFile);
T1 = readC2(cfg.T1Path,cfg.lines,cfg.samples);
T2 = readC2(cfg.T2Path,cfg.lines,cfg.samples);
differenceTimer = tic;
diffGraph = cacDiffGraph(T1,T2,cfg.diffMethod);
timing.DifferenceGenerationSeconds = toc(differenceTimer);
labels = [];
if cfg.requiresSuperpixels
    labels = generateSuperPixel(T1,T2,diffGraph,cfg.superpixelOptions);
end
clear T1 T2;
segmentationTimer = tic;
result = segmentDifferenceImage(diffGraph,labels,cfg);
timing.DifferenceSegmentationSeconds = toc(segmentationTimer);
result = logical(result);
clear diffGraph labels;
if ~isfolder(cfg.outputDirectory)
    mkdir(cfg.outputDirectory);
end
imwrite(result,fullfile(cfg.outputDirectory,'detection.png'));
save(fullfile(cfg.outputDirectory,'detection.mat'),'result','cfg','timing','-v7.3');
fprintf('Difference generation: %.3f s; segmentation (%s): %.3f s\n', ...
    timing.DifferenceGenerationSeconds,cfg.segmentationMethod,timing.DifferenceSegmentationSeconds);
fprintf('Detection results saved to %s\n',cfg.outputDirectory);
end
