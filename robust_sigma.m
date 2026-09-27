function sigma = robust_sigma(x)
x = x(:);
x = x(isfinite(x));
if isempty(x)
    sigma = 0.1;
    return;
end
medx = median(x);
madx = median(abs(x - medx));
sigma = 1.4826 * madx;
if ~isfinite(sigma) || sigma <= 0
    sigma = std(x);
end
if ~isfinite(sigma) || sigma <= 0
    sigma = 0.1;
end
end
