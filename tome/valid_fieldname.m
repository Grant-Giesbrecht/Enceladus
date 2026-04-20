function fn = valid_fieldname(s)
% Convert an HDF5 key to a valid MATLAB struct fieldname.
% Prepends 'x' if it starts with a digit; replaces illegal chars with '_'.
    fn = regexprep(s, '[^a-zA-Z0-9_]', '_');
    if ~isempty(fn) && (fn(1) >= '0' && fn(1) <= '9')
        fn = ['x', fn];
    end
end


