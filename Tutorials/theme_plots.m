[f, ax, fprop] = themefig(1);

% hold on;
% plot(sin(1:.1:10));
% lgd = legend('data1');
% grid on;


ddf = DDFIO;
ddf.load("table1.ddf");
ddf.assignAll();

avg_eta_obo = mean(eta_obo, 2);
avg_eta_sat = mean(eta_sat, 2);

hold on;
scatter(BW, avg_eta_obo, 100, 'Marker', '*');
scatter(BW, avg_eta_sat, 100, 'Marker', '*');
ax.ColorOrderIndex = 1;
scatter(BW(end), avg_eta_obo(end), 160, 'Marker', 'o');
scatter(BW(end), avg_eta_sat(end), 160, 'Marker', 'o');
grid on;
xlabel("Bandwidth (GHz)");
ylabel("Drain Efficiency");
lgd = legend("Backoff", "Saturation");
% title("Table-I Data", 'Color', fprop.title_color);
title("Test");

posttheme(fprop, lgd);