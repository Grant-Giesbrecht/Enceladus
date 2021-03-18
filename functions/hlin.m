function hlin(y, varargin)
    xl = xlim;
    line([xl(1), xl(2)], [y, y], varargin{:});
end