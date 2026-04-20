function s = ensure_slash(path)
% Ensure path ends with '/'.
    if isempty(path) || path(end) ~= '/'
        s = [path, '/'];
    else
        s = path;
    end
end


