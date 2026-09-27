function diffGraph = cacDiffGraph(T1, T2, method)
method = validatestring(method, {'HLT', 'HLT_rain'});
HLT = symmetricHLT(T1, T2);
diffGraph = NormalizeCommon(OutlierElimination(HLT - 2, 'maxmin'), 0, 1);
if strcmp(method, 'HLT_rain')
    vv = NormalizeCommon(OutlierElimination(T2.C22, 'maxmin'), 0, 1);
    vh = NormalizeCommon(OutlierElimination(T2.C11, 'maxmin'), 0, 1);
    rain = NormalizeCommon(OutlierElimination(vv ./ vh, 'maxmin'), 0, 1);
    diffGraph = NormalizeCommon(diffGraph - rain, 0, 1);
end
end
