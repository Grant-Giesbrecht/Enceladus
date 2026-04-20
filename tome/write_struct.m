
% -------------------------------------------------------------------------
function write_struct(s, filename, prefix)
% Recursively write a scalar struct into the HDF5 group at `prefix`.

    fields = fieldnames(s);
    for i = 1:numel(fields)
        fname  = fields{i};
        value  = s.(fname);
        path   = [prefix, fname];       % e.g.  /mygroup/mykey

        write_value(value, filename, path);
    end
end

