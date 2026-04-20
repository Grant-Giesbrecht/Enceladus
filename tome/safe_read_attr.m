function val = safe_read_attr(filename, path, attr_name)
% Read an HDF5 attribute; return '' if it does not exist.
    try
        val = h5readatt(filename, path, attr_name);
        if iscell(val); val = val{1}; end
        val = char(val);
    catch
        val = '';
    end
end


