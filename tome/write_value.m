% -------------------------------------------------------------------------
function write_value(value, filename, path)
% Dispatch on MATLAB type and write to HDF5 with a __pytype__ attribute.

    % ---- struct array → list_of_dicts ----------------------------------
    if isstruct(value) && numel(value) > 1
        group_create(filename, path);
        h5writeatt(filename, path, '__pytype__', 'list_of_dicts');
        for idx = 0 : numel(value)-1
            sub_path = sprintf('%s/%d', path, idx);
            group_create(filename, sub_path);
            h5writeatt(filename, sub_path, '__pytype__', 'dict');
            write_struct(value(idx+1), filename, [sub_path, '/']);
        end
        return
    end

    % ---- scalar struct → dict ------------------------------------------
    if isstruct(value)
        group_create(filename, path);
        h5writeatt(filename, path, '__pytype__', 'dict');
        write_struct(value, filename, [path, '/']);
        return
    end

    % ---- logical (bool) ------------------------------------------------
    if islogical(value)
        h5create(filename, path, size(value), 'Datatype', 'int32');
        h5write(filename, path, int32(value));
        h5writeatt(filename, path, '__pytype__', 'bool');
        return
    end

    % % ---- char / string → str -------------------------------------------
    % if ischar(value) || (isstring(value) && isscalar(value))
    %     if isstring(value); value = char(value); end
    %     h5create(filename, path, [1 1], ...
    %         'Datatype', 'H5T_STRING', ...   % variable-length UTF-8
    %         'ChunkSize', [1 1]);
    %     h5write(filename, path, value);
    %     h5writeatt(filename, path, '__pytype__', 'str');
    %     return
    % end
    % ---- char / string → str -------------------------------------------
    if ischar(value) || (isstring(value) && isscalar(value))
        if isstring(value); value = char(value); end
        write_vlen_string(filename, path, {value});
        h5writeatt(filename, path, '__pytype__', 'str');
        return
    end

    % % ---- cell array of strings → list ----------------------------------
    % if iscell(value) && all(cellfun(@ischar, value(:)))
    %     % Store as variable-length string dataset
    %     h5create(filename, path, numel(value), ...
    %         'Datatype', 'H5T_STRING', ...
    %         'ChunkSize', max(1, numel(value)));
    %     h5write(filename, path, value(:).');
    %     h5writeatt(filename, path, '__pytype__', 'list');
    %     h5writeatt(filename, path, 'dtype', 'object');
    %     return
    % end
    % ---- cell array of strings → list ----------------------------------
    if iscell(value) && all(cellfun(@ischar, value(:)))
        write_vlen_string(filename, path, value(:).');
        h5writeatt(filename, path, '__pytype__', 'list');
        h5writeatt(filename, path, 'dtype', 'object');
        return
    end

    % ---- numeric array (double, single, int*, uint*, complex) ----------
    if isnumeric(value)
        dtype_str = class(value);                    % 'double','single', etc.
        pytype    = 'ndarray';
        if isscalar(value)
            pytype = dtype_str;                      % 'int32', 'float', …
        end

        sz = size(value);
        if isscalar(value)
            h5create(filename, path, [1 1], 'Datatype', matlab_to_h5type(dtype_str));
        else
            h5create(filename, path, sz, 'Datatype', matlab_to_h5type(dtype_str));
        end
        h5write(filename, path, value);
        h5writeatt(filename, path, '__pytype__', pytype);
        h5writeatt(filename, path, 'dtype',      dtype_str);
        return
    end

    % ---- fallback: JSON-encode as string -------------------------------
    warning('dict_to_hdf:unsupportedType', ...
        'Path %s: type ''%s'' not natively supported; JSON-encoding.', ...
        path, class(value));
    json_str = jsonencode(value);
    h5create(filename, path, [1 1], 'Datatype', 'H5T_STRING', 'ChunkSize', [1 1]);
    h5write(filename, path, json_str);
    h5writeatt(filename, path, '__pytype__', 'json');
end

