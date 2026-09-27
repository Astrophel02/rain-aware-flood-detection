function contrast = covarianceEdgeContrast(A, B)
power = max(real(A.C11+A.C22),real(B.C11+B.C22));
ridge = max(1e-6*power,realmin);
A.C11 = real(A.C11)+ridge; A.C22 = real(A.C22)+ridge;
B.C11 = real(B.C11)+ridge; B.C22 = real(B.C22)+ridge;
contrast = symmetricHLT(A,B)-2;
contrast(~isfinite(contrast)) = 0;
contrast = max(contrast,0);
end
