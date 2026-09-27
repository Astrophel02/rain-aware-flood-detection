function structC = readC2(path, lines, samples)
validateattributes(lines, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
validateattributes(samples, {'numeric'}, {'scalar', 'integer', 'positive', 'finite'});
folder = char(path);
if isfolder(fullfile(folder, 'C2'))
    folder = fullfile(folder, 'C2');
end
structC.C11 = readC2Component(fullfile(folder, 'C11.bin'), lines, samples);
real12 = readC2Component(fullfile(folder, 'C12_real.bin'), lines, samples);
imag12 = readC2Component(fullfile(folder, 'C12_imag.bin'), lines, samples);
structC.C12 = complex(real12, imag12);
structC.C22 = readC2Component(fullfile(folder, 'C22.bin'), lines, samples);
end
