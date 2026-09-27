function [centers,means] = updateSuperpixelClusters(labels,features,oldCenters,oldMeans)
[rows,~]=size(labels); K=size(oldCenters,1); names=fieldnames(features);
count=zeros(K,1); rowSum=zeros(K,1); colSum=zeros(K,1);
for n=1:numel(names), totals.(names{n})=zeros(K,1); end
chunkSize=1e6;
for first=1:chunkSize:numel(labels)
    idx=(first:min(first+chunkSize-1,numel(labels)))';
    ids=labels(idx); ids=ids(:);
    count=count+accumarray(ids,1,[K,1]);
    rowSum=rowSum+accumarray(ids,mod(idx-1,rows)+1,[K,1]);
    colSum=colSum+accumarray(ids,floor((idx-1)/rows)+1,[K,1]);
    for n=1:numel(names)
        name=names{n};
        values=features.(name)(idx);
        totals.(name)=totals.(name)+accumarray(ids,values(:),[K,1]);
    end
end
occupied=count>0;
centers=oldCenters; means=oldMeans;
centers(occupied,:)=[rowSum(occupied),colSum(occupied)]./count(occupied);
for n=1:numel(names)
    name=names{n};
    means.(name)(occupied)=totals.(name)(occupied)./count(occupied);
end
end
