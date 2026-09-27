function bw = mrf2D_superpixel_AI(img, classnum, label_init, superpixel_label, maxnum, options)
validateattributes(img, {'numeric'}, {'real', '2d', 'nonempty'}, mfilename, 'img');
validateattributes(maxnum, {'numeric'}, {'scalar', 'integer', 'nonnegative', 'finite'}, mfilename, 'maxnum');
if ~isequal(size(img), size(label_init)) || any(~isfinite(label_init(:)))
    error('RainFlood:InvalidInitialLabels', 'label_init must be finite and match img size.');
end
if classnum ~= 2
    error('本实现仅支持二类(classnum=2)。');
end
if ~isequal(size(img), size(superpixel_label))
    error('img 与 superpixel_label 尺寸不一致。');
end
if ~isa(img,'double'), img = im2double(img); end
sp = double(superpixel_label);
if ~isreal(sp) || any(~isfinite(sp(:))) || any(sp(:) < 1) || any(mod(sp(:),1)~=0)
    error('superpixel_label需为正整数标签。');
end
[H,W] = size(img);
imgv0 = img(:);
finitePix = isfinite(imgv0);
imgv0(~finitePix) = 0;
img = reshape(imgv0,H,W);
label0 = double(label_init);
u = unique(label0(:));
if numel(u) > 2
    thr = median(label0(:));
    label0 = 1 + (label0 > thr);
else
    if all(ismember(u,[0 1]))
        label0 = label0 + 1;
    elseif all(ismember(u,[1 2]))
    else
        label0 = 1 + (label0 ~= u(1));
    end
end
if nargin < 6, options = struct(); end
options = mrfDefaultOptions(options);
lambda_sp = options.lambda_sp;
minSigma = options.minSigma;
stopFrac = options.stopFrac;
bandRadius = options.bandRadius;
alpha = options.alpha;
lambda_px = options.lambda_px;
sigmaEdge = options.sigmaEdge;
beta = 1/(2*sigmaEdge^2);
k_intra = options.k_intra;
max_em = min(maxnum, 8);
bw_coarse = coarse_superpixel_cut(img, sp, label0, finitePix, lambda_sp, minSigma, stopFrac, max_em);
if ~options.RefineBoundary
    bw = bw_coarse;
    return;
end
bandMask = make_boundary_band(bw_coarse, bandRadius);
bandMask(~reshape(finitePix,H,W)) = false;
if ~any(bandMask(:))
    bw = bw_coarse;
    return;
end
bw = refine_band_pixel_graphcut(img, sp, bw_coarse, bandMask, finitePix, alpha, lambda_px, beta, k_intra, minSigma);
end
