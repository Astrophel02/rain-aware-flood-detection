function values = readFlatYaml(filename)
text = fileread(filename);
if ~isempty(text) && text(1) == char(65279), text(1) = []; end
rows = regexp(text,'\r\n|\n|\r','split');
values = struct();
for row = 1:numel(rows)
    line = rows{row}; trimmed = strtrim(line);
    if isempty(trimmed) || startsWith(trimmed,'#') || ismember(trimmed,{'---','...'})
        continue;
    end
    tokens = regexp(line,'^([A-Za-z]\w*):\s*(.*?)\s*$','tokens','once');
    if isempty(tokens)
        error('RainFlood:InvalidYaml','%s:%d: expected a top-level key: value.',filename,row);
    end
    key = tokens{1};
    if isfield(values,key)
        error('RainFlood:DuplicateYamlKey','%s:%d: duplicate key %s.',filename,row,key);
    end
    try
        values.(key) = parseYamlScalar(tokens{2});
    catch cause
        error('RainFlood:InvalidYaml','%s:%d (%s): %s',filename,row,key,cause.message);
    end
end
end
