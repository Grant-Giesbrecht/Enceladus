
% Initialize display table
mt = MTable;
mt.title("num2str vs. num2fstr");
mt.row(["x", "num2str(x)", "num2fstr"]);


mt.row([".0003", num2str(.0003), num2fstr(.0003)]);
mt.row([".00003", num2str(.00003), num2fstr(.00003)]);
mt.row(["1+j*1e-7", num2str(1+j*1e-7), num2fstr(1+j*1e-7)]);
mt.row(["1e-7+j*1", num2str(1e-7+j*1), num2fstr(1e-7+j*1)]);
mt.row(["NaN", num2str(NaN), num2fstr(NaN, 'nanstr', 'Custom!')]);

displ(mt.str());