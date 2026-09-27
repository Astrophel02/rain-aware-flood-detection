function [result,initial] = segmentDifferenceImage(image,labels,cfg)
method = validatestring(cfg.segmentationMethod, ...
    {'Otsu','Pixel-SS-MRF','Superpixel-SS-MRF','MS-MRF'},mfilename,'segmentationMethod');
initial = double(imbinarize(image,graythresh(image)));
switch method
    case 'Otsu'
        result = initial;
    case 'Pixel-SS-MRF'
        result = mrf2D(image,2,initial,cfg.mrfMaxIter)-1;
    otherwise
        if isempty(labels)
            error('RainFlood:MissingSuperpixels','%s requires superpixel labels.',method);
        end
        options = cfg.mrfOptions;
        options.RefineBoundary = strcmp(method,'MS-MRF');
        result = mrf2D_superpixel_AI(image,2,initial,labels,cfg.mrfMaxIter,options)-1;
end
end
