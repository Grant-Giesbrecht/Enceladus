
% -------------------------------------------------------------------------
function out = read_group(filename, path, info)
% Reconstruct a MATLAB struct from an HDF5 group.

    pytype = safe_read_attr(filename, path, '__pytype__');

    % ---- list_of_dicts --------------------------------------------------
    if strcmp(pytype, 'list_of_dicts')
        n = numel(info.Groups);
        % Pre-read first element to get fieldnames for pre-allocation
        sub_path = sprintf('%s%d', ensure_slash(path), 0);
        sub_info = h5info(filename, sub_path);
        first    = read_group(filename, sub_path, sub_info);
        out(n)   = first;               % pre-allocate struct array
        out(1)   = first;
        for idx = 1 : n-1
            sp       = sprintf('%s%d', ensure_slash(path), idx);
            si       = h5info(filename, sp);
            out(idx+1) = read_group(filename, sp, si);
        end
        return
    end

    % ---- dict (regular group) ------------------------------------------
    out = struct();

    % Sub-groups (nested dicts or list_of_dicts)
    for i = 1 : numel(info.Groups)
        sub_info  = info.Groups(i);
        sub_name  = sub_info.Name;                   % full path like /a/b
        key       = name_to_key(sub_name);
        out.(key) = read_group(filename, sub_name, sub_info);
    end

    % Datasets (leaf values)
    for i = 1 : numel(info.Datasets)
        ds_info = info.Datasets(i);
        ds_name = ds_info.Name;                      % just the leaf name
        ds_path = [ensure_slash(path), ds_name];
        key     = valid_fieldname(ds_name);
        out.(key) = read_dataset(filename, ds_path);
    end
end


