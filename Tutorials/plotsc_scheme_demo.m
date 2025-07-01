radius = linspace(.3, .8, 30);
arg = linspace(2*pi/10, 8*pi/10, 30);

g1 = polcomplex(radius, arg);

figure(3);
hold off
plotsc(g1);

figure(4);
hold off;
plotsc(g1, 'Scheme', 'Dark');