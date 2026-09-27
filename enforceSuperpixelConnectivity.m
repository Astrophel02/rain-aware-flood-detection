function labels = enforceSuperpixelConnectivity(labels, minRegionSize)
if nargin<2, minRegionSize=1; end
regions=label2idx(labels);
next=numel(regions);
[rows,~]=size(labels);
for k=1:numel(regions)
    pixels=regions{k};
    if isempty(pixels), continue; end
    [r,c]=ind2sub(size(labels),pixels);
    r0=min(r); c0=min(c);
    patch=false(max(r)-r0+1,max(c)-c0+1);
    patch(sub2ind(size(patch),r-r0+1,c-c0+1))=true;
    components=bwconncomp(patch,4);
    for j=2:components.NumObjects
        [pr,pc]=ind2sub(size(patch),components.PixelIdxList{j});
        idx=(pc+c0-2)*rows+pr+r0-1;
        next=next+1; labels(idx)=next;
    end
end
[~,~,ids]=unique(labels(:));
labels=reshape(ids,size(labels));
if minRegionSize>1
    labels=mergeSmallSuperpixels(labels,minRegionSize);
end
end
