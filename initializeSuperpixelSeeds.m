function seeds = initializeSuperpixelSeeds(edgeStrength, scale)
[rows,cols]=size(edgeStrength);
validateattributes(scale,{'numeric'},{'scalar','real','positive','finite'});
nr=max(1,round(rows/scale)); nc=max(1,round(cols/scale));
rr=max(1,min(rows,round(((1:nr)-0.5)*rows/nr)));
cc=max(1,min(cols,round(((1:nc)-0.5)*cols/nc)));
[R,C]=ndgrid(rr,cc); seeds=[R(:),C(:)];
radius=floor(min(rows/nr,cols/nc)/4);
for k=1:size(seeds,1)
    r=max(1,seeds(k,1)-radius):min(rows,seeds(k,1)+radius);
    c=max(1,seeds(k,2)-radius):min(cols,seeds(k,2)+radius);
    local=edgeStrength(r,c); local(~isfinite(local))=Inf;
    minimum=min(local(:));
    if ~isfinite(minimum), continue; end
    [ir,ic]=find(local==minimum);
    [~,closest]=min((r(ir)-seeds(k,1)).^2+(c(ic)-seeds(k,2)).^2);
    seeds(k,:)=[r(ir(closest)),c(ic(closest))];
end
end
