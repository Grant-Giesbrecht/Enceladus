x = linspace(1, 1e6, 1e6);

t0 = tic;
xs = sort(x, 'ascend');
t_sort = toc(t0);

t0 = tic;
find(x==500e3);
t_find_500k = toc(t0);

t0 = tic;
find(x==1e3);
t_find_1k = toc(t0);

t0 = tic;
bfind(x, 500e3);
t_bfind_500k = toc(t0);

t0 = tic;
bfind(x, 1e3);
t_bfind_1k = toc(t0);

t0 = tic;
bfindall(x, 500e3);
t_bfalin_500k = toc(t0);

t0 = tic;
bfindall(x, 500e3, length(x), false);
t_bfabin_500k = toc(t0);

t0 = tic;
bfindall(x, 1e3);
t_bfalin_1k = toc(t0);

t0 = tic;
bfindall(x, 1e3, length(x), false);
t_bfabin_1k = toc(t0);

mt = MTable;
mt.row(["Function", "Target", "Bin./Lin.", "Elapsed Time (ms)"]);
mt.row(["sort()", "N/A", "-", num2fstr(t_sort.*1e3)]);
mt.row(["find()", "500k", "-", num2fstr(t_find_500k .*1e3)]);
mt.row(["find()", "1k", "-", num2fstr(t_find_1k .*1e3)]);
mt.row(["bfind()", "500k", "Bin.", num2fstr(t_bfind_500k .*1e3)]);
mt.row(["bfind()", "1k", "Bin.", num2fstr(t_bfind_1k .*1e3)]);
mt.row(["bfindall()", "500k", "Lin.", num2fstr(t_bfalin_500k .*1e3)]);
mt.row(["bfindall()", "500k", "Bin.", num2fstr(t_bfabin_500k .*1e3)]);

displ(mt.str())