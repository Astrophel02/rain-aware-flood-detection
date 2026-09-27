function labels = mergeSmallSuperpixels(labels, minRegionSize)
K=max(labels(:)); counts=accumarray(labels(:),1,[K,1]);
[s,t,w]=build_sp_adjacency(labels);
adjacency=sparse([s;t],[t;s],[w;w],K,K);
parent=(1:K)';
[~,order]=sort(counts);
changed=true;
while changed
    changed=false;
    for index=1:K
        id=order(index); source=id;
        while parent(source)~=source, source=parent(source); end
        if counts(source)>=minRegionSize, continue; end
        [neighbor,~,weights]=find(adjacency(:,id));
        if isempty(neighbor), continue; end
        while any(parent(neighbor)~=neighbor), neighbor=parent(neighbor); end
        keep=neighbor~=source;
        neighbor=neighbor(keep); weights=weights(keep);
        if isempty(neighbor), continue; end
        [roots,~,group]=unique(neighbor);
        boundary=accumarray(group,weights);
        best=find(boundary==max(boundary));
        [~,winner]=max(counts(roots(best)));
        target=roots(best(winner));
        parent(source)=target;
        counts(target)=counts(target)+counts(source); counts(source)=0;
        changed=true;
    end
end
while any(parent(parent)~=parent), parent=parent(parent); end
labels=reshape(parent(labels(:)),size(labels));
[~,~,ids]=unique(labels(:)); labels=reshape(ids,size(labels));
end
