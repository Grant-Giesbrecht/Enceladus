function lp = lpanalyze(filename, refresh)
% LPANALYZE Plot Load Pull data from an MDF File
%
% Accepts an MDF filename as an input and plots the data. Note that it uses
% file2loadpull to minimize number of MDF reads, so if the data in the MDF
% file changes, use the refresh flag to force the data to be reloaded.
%
%	LP = LPANALYZE(filename) Plot the data in the specified MDF file and
%	return a LoadPull object.
%
%	LP = LPANALYZE(filename, refresh) If refresh is true, forces the MDF file
%	to be read and overwrites any backup MAT file.
%
% See also: file2loadpull, LoadPull

	if ~exist("refresh", "var")
		refresh = false;
	elseif isa(refresh, 'string') || isa(refresh, 'char')
		refresh = str2bool(refresh);
	end

	[lp, ~, ~] = file2loadpull(filename, "Refresh", refresh);
	
	%========================= Impedance Trajectories =========================
	
						%===== Max PAE vs. Frequency =====
	
	freqs = unique(lp.freq);
	lp_fig1 = lp.get(lp.listfilter("PAE", "MAX", "Freq", freqs', "MinMaxCount", 10));
	[gamma1, stdev1] = lp_fig1.average("Gamma", "Freq", freqs');
	sch = 'Light';
	
	figure(1);
	hold off
	errorcircsc(gamma1, stdev1./2, 'ColorVar', freqs, 'Scheme', sch);
	plotsc(gamma1, 'LineStyle', ':', 'Marker', '*', 'Scheme', sch, 'ColorVar', freqs,'Color', [.9, .7, .5]);
	title("Impedance Trajectory of max PAE over Frequency");
	c1 = colorbar('Ticks', freqs./1e9);
	c1.Label.String = 'Frequency (GHz)';
	caxis([min(freqs)./1e9, max(freqs)./1e9]);
	
						%===== Max PAE vs. Pout =====
	
	% Get Pload bins
	pload_divs = linspace(min(lp.p_load()), max(lp.p_load()), 51);
	pload_bins = binrange(pload_divs, (pload_divs(2)-pload_divs(1))/100 );
	
	% Filter LoadPull
	lp_fig3 = lp.get(lp.listfilter("PAE", "MAX", "Pload", pload_bins, "MinMaxCount", 10));
	[gamma3, stdev3] = lp_fig3.average("Gamma", "Pload", pload_bins);
	
	figure(2);
	n_colorbar_ticks = 10;
	hold off
	errorcircsc(gamma3, stdev3./2, 'ColorVar', pload_bins(:,2)', 'Scheme', sch );
	hold on
	plotsc(gamma3, 'LineStyle', ':', 'Marker', '*', 'Scheme', sch, 'ColorVar', pload_bins(:,2)' ,'Color', [.9, .7, .5]);
	% pause(1);
	title("Impedance Trajectory of max PAE over P_{Out}");
% 	c3 = colorbar('Ticks', pload_bins(:,2)' );
	c3 = colorbar('Ticks', linspace(min(pload_divs), max(pload_divs), n_colorbar_ticks));
	c3.Label.String = 'P_{Out} (W)';
	caxis([min(pload_divs), max(pload_divs)]);
	
						%===== Max PAE vs. Pout (over Freq) =====
	
	pload_divs = linspace(min(lp.p_load()), max(lp.p_load()), 21);
	pload_bins = binrange(pload_divs, (pload_divs(2)-pload_divs(1))/100 );
						
% 	% Filter LoadPull
% 	lp_fig8A = lp.get(lp.listfilter("PAE", "MAX", "Pload", pload_bins, "MinMaxCount", 10, "Freq", 4e9));
% 	[gamma8A, stdev8A, bins8A] = lp_fig8A.average("Gamma", "Pload", pload_bins);
% 	
% 	lp_fig8B = lp.get(lp.listfilter("PAE", "MAX", "Pload", pload_bins, "MinMaxCount", 10, "Freq", 5e9));
% 	[gamma8B, stdev8B, bins8B] = lp_fig8B.average("Gamma", "Pload", pload_bins);
% 	
% 	lp_fig8C = lp.get(lp.listfilter("PAE", "MAX", "Pload", pload_bins, "MinMaxCount", 10, "Freq", 6e9));
% 	[gamma8C, stdev8C, bins8C] = lp_fig8C.average("Gamma", "Pload", pload_bins);
% 	
% 	bins8A = bins8A{:};
% 	bins8B = bins8B{:};
% 	bins8C = bins8C{:};
% 	
% 	figure(3);
% 	hold off
% 	errorcircsc(gamma8A, stdev3./2, 'ColorVar', pload_bins(:,2)', 'Colormap', colormap('parula'), 'Scheme', sch );
% 	hold on
% 	errorcircsc(gamma8B, stdev3./2, 'ColorVar', pload_bins(:,2)', 'Colormap', colormap('bone'), 'Scheme', sch );
% 	errorcircsc(gamma8C, stdev3./2, 'ColorVar', pload_bins(:,2)', 'Colormap', colormap('jet'), 'Scheme', sch );
% 	plotsc(gamma8A, 'LineStyle', ':', 'Marker', '*', 'Scheme', sch, 'ColorVar', bins8A(:,2)' ,'Color', [.9, .7, .5], 'Colormap', colormap('parula'));
% 	plotsc(gamma8B, 'LineStyle', ':', 'Marker', '*', 'Scheme', sch, 'ColorVar', bins8B(:,2)' ,'Color', [.9, .7, .5], 'Colormap', colormap('bone'));
% 	plotsc(gamma8C, 'LineStyle', ':', 'Marker', '*', 'Scheme', sch, 'ColorVar', bins8C(:,2)' ,'Color', [.9, .7, .5], 'Colormap', colormap('jet'));
	
	%============================= Contour Plots ==============================
	
	contourplot2_gui(lp, "PAE", "PLOAD", 7, 'Scheme', sch, 'ContourLabel1', "PAE (%)", 'ContourLabel2', "Pload (W)", 'Color2', [.8, 0, 0]); %'Color2', [212, 58, 248]./255);

end











