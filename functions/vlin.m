function vlin(x, varargin)
    yl = ylim;
    line([x, x], [yl(1), yl(2)], varargin{:});
end