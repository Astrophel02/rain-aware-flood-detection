function total = boxWindowSum(values, windowSize)
total = conv2(conv2(values, ones(windowSize,1), 'same'), ...
    ones(1,windowSize), 'same');
end
