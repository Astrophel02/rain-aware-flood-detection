function [UpThre,LowThre] = BoxPlotCalOutliers(V)
%BOXPLOTCALOUTLIERS Return upper/lower extreme-outlier fences (3 * IQR).
% Original quartile convention by GaoHan, retained for numerical compatibility.
% Preserve the historical quartile weights for inputs of length >= 3.
V = V(isfinite(V));
if isempty(V)
    UpThre = NaN; LowThre = NaN; return;
end
if numel(V) < 3
    UpThre = max(V); LowThre = min(V); return;
end

Vsort = sort(V);
N = length(Vsort);

% the 25th percentiles point
N1 = (N + 1) / 4;

if N1 == floor(N1)
    Q1 = Vsort(N1);
else
    N1 = floor(N1);
    Q1 = 0.25 * Vsort(N1) + 0.75 * Vsort(N1+1);
end

% the 75th percentiles point
N3 = 3 * (N + 1) / 4;

if N3 == floor(N3)
    Q3 = Vsort(N3);
else
    N3 = floor(N3);
    Q3 = 0.75 * Vsort(N3) + 0.25 * Vsort(N3+1);
end

% calculate the threshold
% the '3' determine the extreme outlier point
% the '1.5' determine the mild outlier point
IQR = Q3 - Q1;
UpThre = Q3 + 3 * IQR;
LowThre = Q1 - 3 * IQR;

end
