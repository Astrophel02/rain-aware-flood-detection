function labels = generatePolSARSuperpixels(T1,T2,EDGE,ENL,targetCount,maxiter,beta,tolerance,options)
[rows,cols] = size(EDGE);
step = sqrt(rows*cols/targetCount);
seeds = initializeSuperpixelSeeds(EDGE,step);
K = size(seeds,1);
F.C11 = real((T1.C11+T2.C11)/2);
F.C22 = real((T1.C22+T2.C22)/2);
F.C12 = (T1.C12+T2.C12)/2;
valid = isfinite(F.C11) & isfinite(F.C22) & isfinite(F.C12) ...
    & F.C11 >= 0 & F.C22 >= 0;
F.C11(~valid)=0; F.C22(~valid)=0; F.C12(~valid)=0;
span = F.C11+F.C22;
positive = span(span>0);
if isempty(positive), spanFloor=1; else, spanFloor=median(positive)*1e-6; end
F.Span = NormalizeCommon(log(max(span,spanFloor)),0,1);
clear span positive;
F.Change = zeros(rows,cols);
if options.ChangeWeight > 0
    if ~isfield(options,'DifferenceImage') || ~isequal(size(options.DifferenceImage),[rows,cols])
        error('RainFlood:MissingDifferenceImage','Change-guided PolSAR requires DifferenceImage.');
    end
    F.Change = options.DifferenceImage;
    F.Change(~isfinite(F.Change))=0;
end
confidence = log1p(max(ENL,0));
confidence(~isfinite(confidence))=0;
confidence = NormalizeCommon(OutlierElimination(confidence,'maxmin'),0,1);
confidence(~isfinite(confidence))=0;
edge = EDGE; edge(~isfinite(edge))=0; edge=min(max(edge,0),1);
spatialWeight = 0.5 + 0.5*confidence.*(1-edge);
seedIndex = sub2ind([rows,cols],seeds(:,1),seeds(:,2));
names = fieldnames(F);
for n=1:numel(names), means.(names{n})=F.(names{n})(seedIndex); end
radius = ceil(step);
for iteration=1:maxiter
    distance=inf(rows,cols); labels=zeros(rows,cols);
    for k=1:K
        r=seeds(k,1); c=seeds(k,2);
        rr=max(1,floor(r)-radius):min(rows,ceil(r)+radius);
        cc=max(1,floor(c)-radius):min(cols,ceil(c)+radius);
        [R,C]=ndgrid(rr,cc);
        region=struct('C11',F.C11(rr,cc),'C12',F.C12(rr,cc),'C22',F.C22(rr,cc));
        center=struct('C11',means.C11(k),'C12',means.C12(k),'C22',means.C22(k));
        pol=log1p(covarianceEdgeContrast(region,center));
        power=(F.Span(rr,cc)-means.Span(k)).^2;
        change=(F.Change(rr,cc)-means.Change(k)).^2;
        spatial=((R-r).^2+(C-c).^2)/step^2;
        candidate=pol+power+options.ChangeWeight*change ...
            +(beta/5)^2*spatialWeight(rr,cc).*spatial;
        oldDistance=distance(rr,cc); block=labels(rr,cc);
        update=candidate<oldDistance;
        oldDistance(update)=candidate(update); block(update)=k;
        distance(rr,cc)=oldDistance; labels(rr,cc)=block;
    end
    missing=labels==0;
    if any(missing(:))
        if iteration==1
            error('RainFlood:UncoveredPixels','Initial superpixel windows did not cover the image.');
        end
        labels(missing)=previousLabels(missing);
    end
    [newSeeds,newMeans]=updateSuperpixelClusters(labels,F,seeds,means);
    movement=sum(abs(newSeeds(:)-seeds(:)));
    seeds=newSeeds; means=newMeans;
    if iteration>=2 && movement<=tolerance, break; end
    previousLabels=labels;
end
labels=enforceSuperpixelConnectivity(labels,max(1,floor(step^2/4)));
end
