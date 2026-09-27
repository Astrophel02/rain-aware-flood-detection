function average = finiteWindowMean(values, windowSize, valid, count)
values(~valid) = 0;
average = boxWindowSum(values, windowSize) ./ max(count,1);
average(count == 0) = NaN;
end
