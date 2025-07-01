function plotBandwidth(ss, freqs, spr, spc, optBW_param)

	if ~exist('optBW_param', 'var')
		optBW_param = -20;
	end

	for idx = 1:numel(ss)
		
		% Select subplot
		subplot(spr, spc, idx);

		% Plot traces
		hold off;
% 		plot(freqs./1e9, lin2dB(abs(ss(idx).S(1,1, ZL, ZS))));
		plot(freqs./1e9, lin2dB(abs(ss(idx).G_in())));
		hold on;
% 		plot(freqs./1e9, lin2dB(abs(ss(idx).S(2,1, ZL, ZS))));
		
		% Label graph
% 		legend("|S_{1,1}|", "|S_{2,1}|");
		xlabel("Frequency (GHz)");
		ylabel("S-Parameter (dB)");
		title(ss(idx).name);
		
		% Calculate bandwidth
		[bw, f0, f1]=ss(idx).bandwidth( "Absolute", optBW_param);
		
		% Plot Bandwidth Region
		if ~isempty(bw)
			%fillregion([f0./1e9, f1./1e9], [NaN, NaN], [0, .8, 0], .2);
			vlin(f0./1e9, 'Color', [.3, .3, .3], 'LineStyle', '--');
			vlin(f1./1e9, 'Color', [.3, .3, .3], 'LineStyle', '--');
% 			displ(ss(idx).name, " BW (MHz): ", bw./1e6);
		end
		
		% Add finishing touches to graph
		grid on;
		ylim([-50, 0]);

	end
	
	
	
% 	subplot(2, 2, 3);
% 	hold off;
% 	plot(freqs./1e9, lin2dB(abs(ss(3).S(1,1, ZL))));
% 	hold on;
% 	plot(freqs./1e9, lin2dB(abs(ss(3).S(2,1, ZL))));
% 	legend("|S_{1,1}|", "|S_{2,1}|");
% 	title("Open Stub Solution 1");
% 	[bw, f0, f1]=solns(3).bandwidth("Absolute");
% 	if ~isempty(bw)
% 		%fillregion([f0./1e9, f1./1e9], [NaN, NaN], [0, .8, 0], .2);
% 		vlin(f0./1e9, 'Color', [.3, .3, .3], 'LineStyle', '--');
% 		vlin(f1./1e9, 'Color', [.3, .3, .3], 'LineStyle', '--');
% 		displ("Open Stub Solution 1 BW (MHz): ", bw./1e6);
% 	end
% 	grid on;
% 	ylim([-50, 0]);
% 	subplot(2, 2, 4);
% 	hold off;
% 	plot(freqs./1e9, lin2dB(abs(ss(4).S(1,1, ZL))));
% 	hold on;
% 	plot(freqs./1e9, lin2dB(abs(ss(4).S(2,1, ZL))));
% 	legend("|S_{1,1}|", "|S_{2,1}|");
% 	title("Open Stub Solution 2");
% 	[bw, f0, f1]=solns(3).bandwidth("Absolute");
% 	if ~isempty(bw)
% 		%fillregion([f0./1e9, f1./1e9], [NaN, NaN], [0, .8, 0], .2);
% 		vlin(f0./1e9, 'Color', [.3, .3, .3], 'LineStyle', '--');
% 		vlin(f1./1e9, 'Color', [.3, .3, .3], 'LineStyle', '--');
% 		displ("Open Stub Solution 2 BW (MHz): ", bw./1e6);
% 	end
% 	grid on;
% 	ylim([-50, 0]);

end