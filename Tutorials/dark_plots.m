x = linspace(0, 10, 200);
y1 = 2.*sin(x);
y2 = sin(x).^2./x;
y3 = 3.8.*(sin(10-x).^2./(10-x))-1;
y4 = x./5;
y5 = tan(x);

y5(y5 > 2) = 2;
y5(y5 < -2) = -2;

c1 = [255, 242, 29]./255; % Bright yellow point in 'screen-used-lcars'
c2 = [137, 125, 233]./255; %  % Darker purle grid in 'screen-used-lcars'
c3 = [150, 222, 221]./255; % Blueish from top circle in 208897-20
c4 = [202, 129, 1]./255; % Brightestst orange in the circle aroudn the blue circle (c3), both in top, of 208897-20.

c_grid = [212, 217, 255]./255; % Lighter purpley gray from bigger circle around planet in 'screen-used-lcars'

hold off;
plot(x, y1, 'LineStyle', '--', 'Color', c1);
hold on;
plot(x, y2, 'Color', c2);
plot(x, y3, 'Color', c3);
plot(x, y4, 'Color', c4);
plot(x, y5, 'Color', c_grid);
grid on;
set(gca,'Color','k');
set(gca, 'GridColor', c_grid);
set(gca, 'GridAlpha', .3); % Default is .15
lgnd = legend(gca);
set(lgnd, 'Color', [1,1,1]);
set(lgnd, 'Visible', 'off');
legend('Data 1', 'Data 2', 'Data 3', 'Data 4', 'Data 5');