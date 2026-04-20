function write_vlen_string(filename, path, str_cell)
% Write a cell array of strings as a variable-length UTF-8 string dataset.
    fid  = H5F.open(filename, 'H5F_ACC_RDWR', 'H5P_DEFAULT');

    % Create a variable-length string type
    tid  = H5T.copy('H5T_C_S1');
    H5T.set_size(tid, 'H5T_VARIABLE');
    H5T.set_cset(tid, H5ML.get_constant_value('H5T_CSET_UTF8'));

    % Create dataspace
    n    = numel(str_cell);
    if n == 1
        sid = H5S.create('H5S_SCALAR');
    else
        sid = H5S.create_simple(1, n, n);
    end

    % Create and write dataset
    dcpl = H5P.create('H5P_DATASET_CREATE');
    did  = H5D.create(fid, path, tid, sid, dcpl);
    if n == 1
        H5D.write(did, tid, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', str_cell{1});
    else
        H5D.write(did, tid, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', str_cell);
    end

    H5D.close(did);
    H5P.close(dcpl);
    H5S.close(sid);
    H5T.close(tid);
    H5F.close(fid);
end