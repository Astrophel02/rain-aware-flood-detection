function bw = mrf2D(img,classnum,label,maxnum)
label = label + 1;
diff = 9999999;
num = 0;
while diff > 50000
    label_u = imfilter(label,[0,1,0;0,0,0;0,0,0],'replicate');
    label_d = imfilter(label,[0,0,0;0,0,0;0,1,0],'replicate');
    label_l = imfilter(label,[0,0,0;1,0,0;0,0,0],'replicate');
    label_r = imfilter(label,[0,0,0;0,0,1;0,0,0],'replicate');
    label_ul = imfilter(label,[1,0,0;0,0,0;0,0,0],'replicate');
    label_ur = imfilter(label,[0,0,1;0,0,0;0,0,0],'replicate');
    label_dl = imfilter(label,[0,0,0;0,0,0;1,0,0],'replicate');
    label_dr = imfilter(label,[0,0,0;0,0,0;0,0,1],'replicate');
    pw = zeros(classnum,size(label,1)*size(label,2));
    for i = 1:classnum
        label_i = i * ones(size(label));
        temp = ~(label_i - label_u) + ~(label_i - label_d) + ~(label_i - label_l) + ~(label_i - label_r) + ~(label_i - label_ul) + ~(label_i - label_ur) + ~(label_i - label_dl) + ~(label_i - label_dr);
        pw(i,:) = temp(:)/8;
    end
    mu = zeros(1,classnum);
    sigma = zeros(1,classnum);
    for i = 1:classnum
        index = label == i;
        data_c = img(index);
        data_c = data_c(~isnan(data_c));
        mu(i) = mean(data_c);
        sigma(i) = var(data_c);
    end
    p_sw = zeros(classnum,size(label,1)*size(label,2));
    for i = 1:size(img,1)*size(img,2)
        for j = 1:classnum
            p_sw(j,i) = 1/sqrt(2*pi*sigma(j)) * exp(-(img(i)-mu(j))^2/2/sigma(j));
        end
    end
    p = pw .* p_sw;
    label_1 = zeros(size(label));
    for i = 1:size(img,1)*size(img,2)
        if p(1,i) >= p(2,i)
            label_1(i) = 1;
        else
            label_1(i) = 2;
        end
    end
    diff = sum(sum(abs(label-label_1)));
    label = label_1;
    num = num + 1;
    if num >= maxnum
        break;
    end
end
bw = label;
end
