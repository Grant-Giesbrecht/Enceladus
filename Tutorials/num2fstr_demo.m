
% Initialize display table
mt = MTable;
mt.title("num2str vs. num2fstr");
mt.row(["x", "num2str(x)", "num2fstr"]);


mt.row([".003", num2str(.003), num2fstr(.003)]);
mt.row([".0003", num2str(.0003), num2fstr(.0003)]);
mt.row([".00003", num2str(.00003), num2fstr(.00003)]);
mt.row(["1+j*1e-7", num2str(1+j*1e-7), num2fstr(1+j*1e-7)]);
mt.row(["1e-7+j*1", num2str(1e-7+j*1), num2fstr(1e-7+j*1)]);
mt.row(["NaN", num2str(NaN), num2fstr(NaN, 'NanStr', 'Custom!')]);

displ(mt.str());

% Can apply many formatting options to multiple calls by defining them in a
% map and passing them as FormatOptions

fopt = containers.Map;
fopt('NanStr') = '--';
fopt('ImagStr') = 'j*';
displ(num2fstr(i*1200, 'FormatOptions', fopt));
displ(num2fstr(nan, 'FormatOptions', fopt));
