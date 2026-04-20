function key = name_to_key(full_path)
% Extract the last component of an HDF5 path and make it a valid fieldname.
    parts = strsplit(full_path, '/');
    parts = parts(~cellfun('isempty', parts));
    key   = valid_fieldname(parts{end});
end


