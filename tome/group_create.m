% =========================================================================
%  Helpers
% =========================================================================

function group_create(filename, path)
% Create an HDF5 group (intermediate groups created automatically by fid trick).
    fid  = H5F.open(filename, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    gcpl = H5P.create('H5P_LINK_CREATE');
    H5P.set_create_intermediate_group(gcpl, true);
    gid  = H5G.create(fid, path, gcpl, 'H5P_DEFAULT', 'H5P_DEFAULT');
    H5G.close(gid);
    H5P.close(gcpl);
    H5F.close(fid);
end


