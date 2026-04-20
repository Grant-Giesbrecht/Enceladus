% =========================================================================
%  hdf_utils.m  –  Read/write the Python dict_to_hdf / hdf_to_dict format
%
%  Public API
%  ----------
%    dict_to_hdf(data, filename)          – write a scalar struct to HDF5
%    data = hdf_to_dict(filename)         – read back as a scalar struct
%
%  Type mapping  (mirrors Python __pytype__ attribute)
%  ----------------------------------------------------
%    Python type        HDF5 storage            MATLAB type
%    -----------        ------------            -----------
%    dict               Group + pytype=dict     struct
%    list[dict]         Group + pytype=list_of_dicts   struct array (1×N)
%    np.ndarray         Dataset + pytype=ndarray        double/single/int…
%    list               Dataset + pytype=list           array or cell array
%    str                Dataset + pytype=str            char
%    bool               Dataset + pytype=bool           logical
%    int/float          Dataset + pytype=int/float      double
%    json (fallback)    Dataset + pytype=json           char (raw JSON)
%
%  Requirements: MATLAB R2011b+ (h5read / h5write / h5create native HDF5)
% =========================================================================

function dict_to_hdf(data, filename)

    if exist(filename, 'file')
        delete(filename);
    end

    % --- CREATE the file first using low-level API ---
    fcpl = H5P.create('H5P_FILE_CREATE');
    fapl = H5P.create('H5P_FILE_ACCESS');
    fid  = H5F.create(filename, 'H5F_ACC_TRUNC', fcpl, fapl);
    H5P.close(fcpl);
    H5P.close(fapl);
    H5F.close(fid);
    % --- File now exists on disk; safe to use h5writeatt ---

    h5writeatt(filename, '/', '__pytype__', 'dict');

    write_struct(data, filename, '/');
end