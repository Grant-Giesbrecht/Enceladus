mdf = AWRLPmdf;
if ~mdf.load("LP_Data_L1_Dev.mdf")
	displ("ERROR: ", mdf.msg)
	return;
end

lps = mdf.getLPSweep();

lpd = lps.get();

figure(3);
hold off
scatter(lpd.p_load(), lpd.pae(), 200, 'Marker', '+');
hold on;
[~,~,xs, ys] = scatterbound(lpd.p_load(), lpd.pae(), 3, 4, 'Color', [0, .4, 0], 'Marker', 'v', 'LineStyle', '-.', 'Exact', true);

% lps_bound = lps.listGetSweep(lpd, "Pload", [.007, .0093], [.0072, .0094], "PAE", [1.146, 1.703], [1.147, 1.704]);
lps_bound = lps.listGetSweep(lpd, "Pload", xs, xs, "PAE", ys, ys);
lps_bound.show()
sel_data = lps_bound.get();
scatter(sel_data.p_load(), sel_data.pae(), 200, 'Marker', 'x', 'MarkerEdgeColor', [.8, .0, 0], 'MarkerFaceColor', [0, .0, 0]);
grid on;
xlabel("P_{Load} (W)");
ylabel("PAE (%)");
legend("All Points", "ScatterBound", "Selected Points");