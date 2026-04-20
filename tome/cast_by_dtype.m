
function value = cast_by_dtype(raw, dtype)
% Cast a raw h5read result to the dtype string recorded at write time.
    if isempty(dtype)
        value = raw; return
    end
    try
        value = cast(raw, dtype);
    catch
        value = raw;
    end
end