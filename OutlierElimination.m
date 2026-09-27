function Feature2DResult = OutlierElimination(Feature2D, method)
%OUTLIERELIMINATION Clip box-plot outliers or replace upper outliers locally.
% Original algorithm by GaoHan (2020-05-22); method and interface retained.
method = validatestring(method, {'max', 'min', 'maxmin', 'average'});
[UpThre,LowThre] = BoxPlotCalOutliers(Feature2D(:));
[Nrow, Ncol] = size(Feature2D);

Feature2Dtmp = Feature2D;

switch method
    case 'max'
        Feature2Dtmp(Feature2D > UpThre) = UpThre;
        Feature2DResult = Feature2Dtmp;
    case 'min'
        Feature2Dtmp(Feature2D < LowThre) = LowThre;
        Feature2DResult = Feature2Dtmp;
    case 'maxmin'
        Feature2Dtmp(Feature2D > UpThre) = UpThre;
        Feature2Dtmp(Feature2D < LowThre) = LowThre;
        Feature2DResult = Feature2Dtmp;
        
    case 'average'
        [idxRow, idxCol] = find(Feature2D > UpThre);

        wsize = 3;
        radius = (wsize - 1) / 2;
        Nidx = length(idxRow);
        Feature2Dtmp(Feature2D > UpThre) = nan;
        
        Feature2DNew = zeros(Nrow+2*radius, Ncol+2*radius);
        Feature2DNew = Feature2DNew * nan;
        Feature2DNew(radius+1:end-radius,radius+1:end-radius) = Feature2Dtmp;
        clear Feature2Dtmp;
        for i = 1:Nidx
            crow = idxRow(i)+radius;
            ccol = idxCol(i)+radius;
            
            region = Feature2DNew(crow-radius:crow+radius,ccol-radius:ccol+radius);
            Feature2DNew(crow,ccol) = mean(region(:),'omitnan');
        end
        
        Feature2DResult = Feature2DNew(radius+1:end-radius,radius+1:end-radius);
end

end
