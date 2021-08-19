close all;

G1 = [1,j,-1, -j, 1];
G2 = polcomplex([1,1,1,1,1], [pi/4, 3*pi/4, 5*pi/4, 7*pi/4, pi/4]);
Z1 = [50, 50+j*10, 100+j*10, 100];

f = figure(1);
nd=plotsc(G1);
hold on
plotsc(G2);
ph = plotsc(Z1, 'Domain', 'Z', 'Z0', 50);
legend('one', 'two', 'Z');
title("Smith Chart Demo");
