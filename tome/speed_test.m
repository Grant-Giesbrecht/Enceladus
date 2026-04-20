t0 = tic(); 

x=0;
for i = 1:100000
    x=x+i;
end

toc(t0)
disp(x);