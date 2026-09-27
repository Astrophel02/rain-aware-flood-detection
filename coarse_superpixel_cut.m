function bw = coarse_superpixel_cut(img, sp, label0, finitePix, lambda_sp, minSigma, stopFrac, max_em)
[H,W] = size(img);
imgv = img(:);
spv  = sp(:);
K    = max(spv);
idx = finitePix(:);
n_sp    = accumarray(spv(idx), 1, [K 1], @sum, 0);
sumI_sp = accumarray(spv(idx), imgv(idx), [K 1], @sum, 0);
sumI2_sp= accumarray(spv(idx), imgv(idx).^2, [K 1], @sum, 0);
valid = (n_sp > 0);
mean_sp = zeros(K,1);
mean_sp(valid) = sumI_sp(valid)./n_sp(valid);
[es, et, elen] = build_sp_adjacency(sp);
E = numel(es);
if E > 0
    sigmaI = robust_sigma(mean_sp(es) - mean_sp(et));
else
    sigmaI = 0.1;
end
sigmaI = max(sigmaI, 0.02);
labv = label0(:);
cnt1 = accumarray(spv(idx), double(labv(idx)==1), [K 1], @sum, 0);
cnt2 = accumarray(spv(idx), double(labv(idx)==2), [K 1], @sum, 0);
x_sp = ones(K,1);
x_sp(cnt2 > cnt1) = 2;
x_sp(~valid) = 1;
for it = 1:max_em
    lab_cur = x_sp(spv);
    v = imgv(idx);
    l = lab_cur(idx);
    [mu1, mu2, sig1, sig2] = estimateBinaryGaussian(v, l, minSigma);
    SSE1 = sumI2_sp - 2*mu1*sumI_sp + n_sp*(mu1^2);
    SSE2 = sumI2_sp - 2*mu2*sumI_sp + n_sp*(mu2^2);
    SSE1 = max(SSE1,0); SSE2 = max(SSE2,0);
    D1 = 0.5*(SSE1/(sig1^2)) + n_sp*log(sig1);
    D2 = 0.5*(SSE2/(sig2^2)) + n_sp*log(sig2);
    D1(~valid)=0; D2(~valid)=0;
    m = min(D1,D2);
    D1 = max(D1-m,0);
    D2 = max(D2-m,0);
    D1(~isfinite(D1))=1e6; D2(~isfinite(D2))=1e6;
    if E > 0
        dmu = mean_sp(es)-mean_sp(et);
        w = exp(-(dmu.^2)/(2*sigmaI^2));
        mlen = mean(elen); if ~isfinite(mlen) || mlen<=0, mlen=1; end
        w = w .* min(elen/mlen, 10);
        w = lambda_sp * w;
        w(~isfinite(w) | w<0) = 0;
    else
        w = [];
    end
    x_new = graphcut_binary_potts(D1,D2,es,et,w);
    diffFrac = nnz(x_new~=x_sp)/max(nnz(valid),1);
    x_sp = x_new;
    if diffFrac < stopFrac
        break;
    end
end
bw = reshape(x_sp(spv), H, W);
end
