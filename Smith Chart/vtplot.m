function f = vtplot(lp, optimization_var, sweep_var, sweep_var_vals, unit_o_str, unit_s_str, sweep_divisor, figno)
% Value/Trajectory Plot
% Both optimization_var and sweep_var must be filter-compatable names	

if ~exist('sweep_divisor', 'var')
		sweep_divisor = 1;
	end
	
	if ~exist('figno', 'var')
		figno = 1;
	end
	
	lp_fig1 = lp.get(lp.listfilter(optimization_var, "MAX", sweep_var, sweep_var_vals', "MinMaxCount", 10));
	[gamma1, stdev1] = lp_fig1.average("Gamma", sweep_var, sweep_var_vals');

	[pae1, stdev2] = lp_fig1.average(optimization_var, sweep_var, sweep_var_vals');
	lp_fig2 = lp.get(lp.listfilter(optimization_var, "MAX", sweep_var, sweep_var_vals', "MinMaxCount", 1));

	%Show trajectory
	f = figure(figno);
	subplot(1,2,1);
	hold off
	plotsc(gamma1, 'LineStyle', ':', 'Marker', '*', 'Scheme', 'Light', 'ColorVar', sweep_var_vals,'Color', [.9, .7, .5]);
	errorcircsc(gamma1, stdev1./2, 'ColorVar', sweep_var_vals);
	title("Impedance Trajectory of max "+optimization_var+" over "+sweep_var);
	c1 = colorbar('Ticks', sweep_var_vals./sweep_divisor);
	c1.Label.String = sweep_var+" ("+unit_s_str+")";
	caxis([min(sweep_var_vals)./sweep_divisor, max(sweep_var_vals)./sweep_divisor]);
	
	% Show PAE
	subplot(1,2,2);
	hold off
	errorbar(sweep_var_vals./sweep_divisor, pae1, stdev2, 'Marker', 'o', 'LineStyle', '--', 'LineWidth', 1.5, 'MarkerSize', 10);
	hold on;
	
	[s_sv, I] = sort(lp_fig2.getArrayFromName(sweep_var));
	ov_v = lp_fig2.getArrayFromName(optimization_var);
	plot(s_sv./sweep_divisor, ov_v(I), 'Marker', '*', 'LineStyle', '--', 'LineWidth', 1.5, 'MarkerSize', 15);
	grid on
	legend('Average of 10', 'Max', 'Location', 'SouthEast');
	ylabel("Max " + optimization_var +" ("+unit_o_str+")");
	xlabel(sweep_var+" ("+unit_s_str+")");
	force0y;
end