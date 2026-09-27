function value = parseYamlScalar(text)
text = strtrim(text);
if startsWith(text,'''')
    match = regexp(text,'^''((?:''''|[^''])*)''(?:\s+#.*)?\s*$','tokens','once');
    if isempty(match), error('Malformed single-quoted text.'); end
    value = strrep(match{1},'''''','''');
elseif startsWith(text,'"')
    match = regexp(text,'^("(?:\\.|[^"\\])*")(?:\s+#.*)?\s*$','tokens','once');
    if isempty(match), error('Malformed double-quoted text.'); end
    value = jsondecode(match{1});
else
    text = strtrim(regexprep(text,'\s+#.*$',''));
    if isempty(text) || startsWith(text,'#'), error('A scalar value is required.'); end
    if strcmp(text,'true'), value = true; return; end
    if strcmp(text,'false'), value = false; return; end
    number = '^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$';
    if ~isempty(regexp(text,number,'once'))
        value = str2double(text);
        if ~isfinite(value), error('Numeric values must be finite.'); end
        return;
    end
    if ~isempty(regexp(text,'[\[\]{}&*!|>]|:\s','once')) || ...
            ismember(lower(text),{'null','~','.nan','.inf','-.inf','+.inf'})
        error('Only flat scalar settings are supported; quote literal text.');
    end
    value = text;
end
end
