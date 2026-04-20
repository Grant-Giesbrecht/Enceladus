
% =========================================================================
function data = hdf_to_dict(filename)
% HDF_TO_DICT  Read an HDF5 file written by dict_to_hdf (Python or MATLAB).
%
%   data = hdf_to_dict(filename)
%
%   Returns a scalar struct mirroring the hierarchy of the HDF5 file.
%   list_of_dicts groups are returned as 1×N struct arrays.

    info = h5info(filename, '/');
    data = read_group(filename, '/', info);
end

