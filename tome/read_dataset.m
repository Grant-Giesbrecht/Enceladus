% -------------------------------------------------------------------------
function value = read_dataset(filename, path)
% Read a single dataset and cast to the appropriate MATLAB type.

    raw    = h5read(filename, path);
    pytype = safe_read_attr(filename, path, '__pytype__');

    switch pytype
        case 'bool'
            value = logical(raw);

        case 'str'
            if iscell(raw); raw = raw{1}; end
            value = char(raw);

        case 'list'
            dtype = safe_read_attr(filename, path, 'dtype');
            if strcmp(dtype, 'object') || isempty(dtype)
                % String list comes back as cell array from h5read
                if iscell(raw)
                    value = cellfun(@char, raw, 'UniformOutput', false);
                else
                    value = raw;
                end
            else
                value = raw;            % numeric array
            end

        case 'ndarray'
            dtype = safe_read_attr(filename, path, 'dtype');
            value = cast_by_dtype(raw, dtype);

        case 'json'
            if iscell(raw); raw = raw{1}; end
            value = jsondecode(char(raw));

        otherwise
            % Scalar numerics or unlabelled legacy data
            if iscell(raw) && numel(raw) == 1
                value = raw{1};
            elseif ischar(raw) || (iscell(raw) && all(cellfun(@ischar,raw(:))))
                value = raw;
            elseif isnumeric(raw) && isscalar(raw)
                value = double(raw);
            else
                value = raw;
            end
    end
end


