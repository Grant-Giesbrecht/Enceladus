%% --- Write ---
data.config.name       = 'experiment_1';
data.config.version    = int32(3);
data.config.is_valid   = true;
data.signal            = randn(1, 1024);          % 1×1024 double
data.matrix            = single(magic(4));        % 4×4 single
data.tags              = {'alpha', 'beta', 'gamma'};

% list of dicts: 1×N struct array
data.channels(1).id    = int32(0);  data.channels(1).gain = 1.5;
data.channels(2).id    = int32(1);  data.channels(2).gain = 2.0;

dict_to_hdf(data, 'test.h5');

%% --- Read back ---
result = hdf_to_dict('test.h5');
disp(result.config.name)          % 'experiment_1'
disp(result.signal)               % 1×1024 double
disp(result.channels(2).gain)     % 2.0