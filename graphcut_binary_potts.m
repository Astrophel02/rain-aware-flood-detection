function x = graphcut_binary_potts(D1, D2, es, et, w)
D1 = D1(:);
D2 = D2(:);
es = es(:); et = et(:); w = w(:);
K = numel(D1);
if numel(D2) ~= K || numel(es) ~= numel(et) || numel(es) ~= numel(w)
    error('RainFlood:GraphSizeMismatch', 'Unary/edge vector lengths are inconsistent.');
end
if any(~isfinite(es) | es < 1 | es > K | es ~= fix(es)) || ...
        any(~isfinite(et) | et < 1 | et > K | et ~= fix(et))
    error('RainFlood:InvalidGraphNode', 'Edge endpoints must be integer IDs in 1:K.');
end
D1(~isfinite(D1)) = 1e6;
D2(~isfinite(D2)) = 1e6;
offset = min(D1,D2);
D1 = max(D1-offset,0);
D2 = max(D2-offset,0);
w(~isfinite(w) | w < 0) = 0;
source = K + 1;
sink = K + 2;
ii = [(1:K)'; repmat(source,K,1); es; et];
jj = [repmat(sink,K,1); (1:K)'; et; es];
capacity = sparse(ii, jj, [D1; D2; w; w], K+2, K+2);
G = digraph(capacity);
[~,~,sourceNodes,~] = maxflow(G, source, sink);
x = 2 * ones(K,1);
x(sourceNodes(sourceNodes <= K)) = 1;
end
