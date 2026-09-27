function component = readC2Component(filename, lines, samples)
info = dir(filename);
if isempty(info) || info.isdir
    error('RainFlood:MissingC2File', 'C2 component not found: %s', filename);
end
if info.bytes ~= 4 * lines * samples
    error('RainFlood:C2SizeMismatch', ...
        'Expected %d bytes for [%d,%d], found %d in %s.', ...
        4 * lines * samples, lines, samples, info.bytes, filename);
end
[fid, message] = fopen(filename, 'rb', 'ieee-le');
if fid < 0
    error('RainFlood:C2OpenFailed', '%s: %s', filename, message);
end
cleanup = onCleanup(@() fclose(fid));
component = fread(fid, [samples, lines], 'float32').';
end
