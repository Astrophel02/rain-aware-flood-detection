function band = make_boundary_band(lbl, radius)
[H,W] = size(lbl);
b = false(H,W);
dR = lbl(:,1:W-1) ~= lbl(:,2:W);
dD = lbl(1:H-1,:) ~= lbl(2:H,:);
b(:,1:W-1) = b(:,1:W-1) | dR;
b(:,2:W)   = b(:,2:W)   | dR;
b(1:H-1,:) = b(1:H-1,:) | dD;
b(2:H,:)   = b(2:H,:)   | dD;
if radius <= 0
    band = b;
    return;
end
if exist('imdilate','file') == 2 && exist('strel','file') == 2
    se = strel('disk', radius, 0);
    band = imdilate(b, se);
else
    k = ones(2*radius+1);
    band = conv2(double(b), k, 'same') > 0;
end
end
