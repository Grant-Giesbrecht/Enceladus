rng('default')
xy = -2.5 + 5*rand([200 2]);
x = xy(:,1);
y = xy(:,2);
v = x.*exp(-x.^2-y.^2);

[xq,yq] = meshgrid(-2:.2:2, -2:.2:2);
vq = griddata(x,y,v,xq,yq);

mesh(xq,yq,vq)
hold on
plot3(x,y,v,'o')
xlim([-2.7 2.7])
ylim([-2.7 2.7])