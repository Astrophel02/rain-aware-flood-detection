function ENL = cacENL(T, lines, samples, winsize)
validateCovarianceImage(T, lines, samples);
validateattributes(winsize, {'numeric'}, {'scalar','integer','positive','finite'});
valid = isfinite(T.C11) & isfinite(T.C12) & isfinite(T.C22) ...
    & real(T.C11) >= 0 & real(T.C22) >= 0;
count = boxWindowSum(double(valid), winsize);
mean11 = finiteWindowMean(real(T.C11), winsize, valid, count);
mean12 = finiteWindowMean(T.C12, winsize, valid, count);
mean22 = finiteWindowMean(real(T.C22), winsize, valid, count);
moment = real(T.C11).^2 + 2*abs(T.C12).^2 + real(T.C22).^2;
meanMoment = finiteWindowMean(moment, winsize, valid, count);
meanMatrixMoment = mean11.^2 + 2*abs(mean12).^2 + mean22.^2;
numerator = (mean11 + mean22).^2;
denominator = real(meanMoment - meanMatrixMoment);
roundoff = 32 * eps(max(meanMoment, meanMatrixMoment));
usable = count >= 2 & numerator > 0 & isfinite(numerator) ...
    & isfinite(denominator) & denominator >= -roundoff;
ENL = -ones(lines,samples);
ENL(usable) = numerator(usable) ./ max(denominator(usable), roundoff(usable));
end
