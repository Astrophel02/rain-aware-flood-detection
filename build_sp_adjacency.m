function [s, t, len] = build_sp_adjacency(sp)
[rows, cols] = size(sp);
A = sp(:,1:cols-1); B = sp(:,2:cols);
m = (A ~= B);
a = A(m); b = B(m);
C = sp(1:rows-1,:); D = sp(2:rows,:);
m2 = (C ~= D);
c = C(m2); d = D(m2);
p = [a(:), b(:); c(:), d(:)];
if isempty(p)
    s = []; t = []; len = [];
    return;
end
s = min(p(:,1), p(:,2));
t = max(p(:,1), p(:,2));
[pairs, ~, ic] = unique([s, t], 'rows');
s = pairs(:, 1);
t = pairs(:, 2);
len = accumarray(ic, 1);
end
