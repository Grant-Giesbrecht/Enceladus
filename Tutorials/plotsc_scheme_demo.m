radius = linspace(.3, .8, 30);
arg = linspace(2*pi/10, 8*pi/10, 30);

g1 = polcomplex(radius, arg);

figure(1);
hold off
plotsc(g);

figure(2);
hold off;
plotsc(g, 'Scheme', 'Dark');