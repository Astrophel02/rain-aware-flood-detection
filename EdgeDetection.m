function EDGE = EdgeDetection(structC, length, width)
validateattributes(length, {'numeric'}, {'scalar','integer','odd','>=',3,'finite'});
validateattributes(width, {'numeric'}, {'scalar','integer','odd','>=',3,'finite'});
[rows,cols] = size(structC.C11);
validateCovarianceImage(structC,rows,cols);
centerRow = (length+1)/2;
centerCol = (width+1)/2;
[row,col] = ndgrid((1:length)-centerRow, (1:width)-centerCol);
weights = exp(-0.5*((row/max(length/3,1)).^2 + (col/max(width/3,1)).^2));
above = weights; above(centerRow:end,:) = 0;
below = weights; below(1:centerRow,:) = 0;
left = weights; left(:,centerCol:end) = 0;
right = weights; right(:,1:centerCol) = 0;
vertical = covarianceEdgeContrast(filterCovarianceImage(structC,above), ...
    filterCovarianceImage(structC,below));
horizontal = covarianceEdgeContrast(filterCovarianceImage(structC,left), ...
    filterCovarianceImage(structC,right));
contrast = log1p(max(vertical,horizontal));
EDGE = NormalizeCommon(OutlierElimination(contrast,'maxmin'),0,1);
EDGE(~isfinite(EDGE)) = 0;
end
