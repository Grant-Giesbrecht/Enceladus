[x,y] = ndgrid(-5:0.8:5);
z = sin(x.^2 + y.^2) ./ (x.^2 + y.^2);
figure(1);
subplot(1, 2, 1);
surf(x,y,z)

F = griddedInterpolant(x,y,z, 'spline');

[xq,yq] = ndgrid(-5:0.1:5);
vq = F(xq,yq);

subplot(1, 2, 2);
surf(xq,yq,vq)