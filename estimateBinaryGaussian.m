function [mu1, mu2, sigma1, sigma2] = estimateBinaryGaussian(values, labels, minSigma)
class1 = values(labels == 1);
class2 = values(labels == 2);
mu1 = sum(class1) / max(numel(class1),1);
mu2 = sum(class2) / max(numel(class2),1);
variance1 = sum((class1-mu1).^2) / max(numel(class1),1);
variance2 = sum((class2-mu2).^2) / max(numel(class2),1);
sigma1 = sqrt(max(variance1, minSigma^2));
sigma2 = sqrt(max(variance2, minSigma^2));
if ~isfinite(mu1), mu1 = 0.25; end
if ~isfinite(mu2), mu2 = 0.75; end
if ~isfinite(sigma1), sigma1 = minSigma; end
if ~isfinite(sigma2), sigma2 = minSigma; end
end
