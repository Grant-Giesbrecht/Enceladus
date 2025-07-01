classdef DeviceAnalysis < handle
	
	properties
		
		% Loadpull data
		lp
		lp_unmodified
		
		% Struct, field names are the independent variable (ie. FOM vs
		% Field). List FOM values for 
		fom_vs
		
		% List of ContourSpecs which together define the criteria for the
		% FOM pass.
		fom_specs 
		
		% Name of device for plots
		device_name
		
	end
	
	methods
		
		function obj = DeviceAnalysis(lp, dev_name)			
			
			if ~exist("dev_name", 'var')
				dev_name = "Unnamed Device";
			end
			
			obj.lp = lp;
			obj.lp_unmodified = lp.get(1:lp.numpoints());
			
			obj.fom_vs = {};
			
			obj.fom_specs = [];
			
			obj.device_name = dev_name;
		end
		
		function ntrim = trimNonphysical(obj)
			
			ntrim = obj.lp.trimNonphysical();
			
		end
		
		function nfilt = filter(obj, varargin)
		% FILTER Filters points by passing filter commands to the LoadPull
		% filter function.
		%
		% See also: reset
		
			obj.lp = obj.lp.gfilter(varargin{:});
			
			nfilt = obj.lp_unmodified.numpoints() - obj.lp.numpoints();
		end
		
		function reset(obj)
		% RESET Resets all filters applied to the LoadPull class
		%
		% Resets all applied filters by duplicating the unmodified LoadPull
		% and overwritting the filtered LoadPull with it. 
		%
		% See also: filter, reset
		
			obj.lp = obj.lp_unmodified.get(1:obj.lp_unmodified.numpoints());
		end
		
		function dda = dupl(obj)
		% DUPL Duplicates the DeviceAnalysis class
		%
		% Makes a copy of the LoadPull fields (lp and lp_unmodified) and
		% returns the new DeviceAnalysis object.
		%
		% See also: reset
		
			dda = DeviceAnalysis(obj.lp_unmodified);
			
		end
		
		function showfn(obj)
			displ("venn_freq");
			displ("vt_pae_vs_freq");
			displ("vt_pout_vs_freq");
		end
		
		function showv(obj)			
			
			% DEclare lists
			names = [];
			quants = [];
			names_one = [];
			
			
			% Get num freqs
			nfreq = numel(unique(obj.lp.freq));
			
			% Categorize freqs
			if nfreq ~= 1
				names = [names, string("FREQ")];
				quants = [quants, nfreq];
			else
				names_one = [names_one, "FREQ"];
			end

			% Loop through properties and categorize each
			for fc = string(fieldnames(obj.lp.props))'
				f = fc{:};
				num_prop = numel(unique(obj.lp.props.(f)));
				if num_prop ~= 1
					names = [names, string(f)];
					quants = [quants, num_prop];
				else
					names_one = [names_one, string(f)];
				end
			end
			
			% Display multi-value properties
			barprint("Varying Properties:");
			for i = 1:numel(names)
				
				namestr = names(i);
				if ~strcmpi(namestr, "FREQ")
					namestr = "PROPS."+namestr;
				end
				
				valstr = "";
				if quants(i) < 10
					ddfi = DDFItem(unique(obj.lp.getArrayFromName(namestr)), "StringGenerator", "");
					valstr = ddfi.getValueStr();
					valstr = ", " + valstr;
				end
				displ("    ", namestr, ": ", quants(i) , " unique values", valstr); 
			end
			
			barprint("Single-Valued Properties:");
			for i = 1:numel(names_one)
				namestr = names_one(i);
				if ~strcmpi(namestr, "FREQ")
					namestr = "PROPS."+namestr;
				end
				displ("    ", namestr, " = ", unique(obj.lp.getArrayFromName(namestr))); 
			end
			
		end
		
		function h = venn_freq(obj, pae_spec, pout_spec, hidePlots)
			
			freqs = unique(obj.lp.freq());
			
			if ~exist('hidePlots', 'var')
				hidePlots = false;
			end
			
			if ~exist('pout_spec', 'var')
				pout_spec = 3;
			end
			
			if ~exist('pae_spec', 'var')
				pae_spec = 30;
			end
			
			figure(5);
			subplot(2, 3, 1);

			count = 1;
			obj.fom_vs.freq = zeros(1, length(freqs));
			for f = freqs

				% Specify subplot for vennsc
				if count <= 6 && ~hidePlots
					subplot(2, 3, count);
				end
				
				% Filter LP to specific points
				lpfilt = obj.lp.get(obj.lp.filter("Freq", f));

				% Create contour-spec classes
				c1 = ContourSpec(lpfilt.gamma(), lpfilt.pae(), "PAE (%)", pae_spec, [], [0, .5, 0], "PAE", lpfilt); % PAE >= 50%
				c2 = ContourSpec(lpfilt.gamma(), lpfilt.p_load(), "Pout (W)", pout_spec , [], [0, 0, .8], "Pload", lpfilt); %Pout >= 4,4W

				% Generate vennsc
				hold off
				[hn,~,a] = vennsc([c1, c2], 'HidePlots', hidePlots);
% 				plotsc(lpfilt.gamma(), 'Scatter', true, 'Marker', '+', 'MarkerEdgeColor', [.6, 0, 0]);
				obj.fom_vs.freq(count) = a;
				legend('PAE', "P_{out}", 'Location', 'SouthEast');
				title("Region: F="+string(f./1e9)+" GHz");

				if ~isempty(hn)
					h = hn;
				end
				
				count = count + 1;
			end
			
		end
		
		function h=fom_freq_vgs(obj, pae_spec, pout_spec)
			
			if ~exist('pout_spec', 'var')
				pout_spec = 3;
			end
			
			if ~exist('pae_spec', 'var')
				pae_spec = 30;
			end
			
			% Get VGS or die trying
			try
				vgs = unique(obj.lp.props.V_GS);
			catch
				warning("Faield to sweep Vgs. Could not find property 'props.V_GS'");
				return;
			end
			
			% Create a new DA for each V_GS point
			fom_sweep = [];
			count = 1;
			for v = vgs
				da = obj.dupl();
				da.filter("props.V_GS", v);
				da.venn_freq(pae_spec, pout_spec, true);
				fom_sweep(count, :) = da.fom_vs.freq;
				count = count + 1;
			end
			
			figure(2);
			h=surf(unique(obj.lp.freq())./1e9, vgs, fom_sweep);
			xlabel("Frequency (GHz)");
			ylabel("V_{GS} (V)");
			zlabel("FOM");
			title("FOM over Frequency and Gate Bias");
			
		end
		
		function h=fom_freq_pin(obj, pae_spec, pout_spec)
			
			if ~exist('pout_spec', 'var')
				pout_spec = 3;
			end
			
			if ~exist('pae_spec', 'var')
				pae_spec = 30;
			end
			
			% Get VGS or die trying
			try
				pin = unique(obj.lp.props.Pin_dBm);
			catch
				warning("Faield to sweep Pin. Could not find property 'props.V_GS'");
				return;
			end
			
			% Create a new DA for each V_GS point
			fom_sweep = [];
			count = 1;
			for v = pin
				da = obj.dupl();
				da.filter("props.Pin_dBm", v);
				da.venn_freq(pae_spec, pout_spec, true);
				fom_sweep(count, :) = da.fom_vs.freq;
				count = count + 1;
			end
			
			figure(4);
			h=surf(unique(obj.lp.freq())./1e9, pin, fom_sweep);
			xlabel("Frequency (GHz)");
			ylabel("P_{In} (dBm)");
			zlabel("FOM");
			title("FOM over Frequency and Input Power");
			
		end
		
		function h = fom_freq(obj)
			figure(6);
			hold off
			h = plot(unique(obj.lp.freq())./1e9, obj.fom_vs.freq, 'LineStyle', '-.', 'Marker', '*', 'MarkerSize', 15, 'LineWidth', 1);
			xlabel("Frequency (GHz)");
			ylabel("FOM (\Gamma^2)");
			title("Figure of Merit over Frequency");
			grid on
			force0y;
		end
		
		function f = vt_pae_vs_pin(obj)
			f = vtplot(obj.lp, "PAE", "props.Pin_dBm", unique(obj.lp.props.Pin_dBm), "%", "dBm", 1, 1);
			ylim([0, 100]);
		end
		
		function f = vt_pae_vs_freq(obj)
			f = vtplot(obj.lp, "PAE", "Freq", unique(obj.lp.freq()), "%", "GHz", 1e9, 1);
			ylim([0, 100]);
		end
		
		function f = vt_pout_vs_freq(obj)
			f = vtplot(obj.lp, "Pload", "Freq", unique(obj.lp.freq()), "W", "GHz", 1e9, 3);
			ylo = ylim;
			
% 			ylim([0, 5.5]);
			if ylo(2) < 10
				ylim([0, 10]);
			else
				force0y;
			end
		end
		
		function [freqs, lmfoms] = lmfom_freq(obj, save_img_video, vidpath, filename2)
			
			if ~exist('save_img_video', 'var')
				save_img_video = false;
			end
			
			if ~exist('vidpath', 'var')
				vidpath = obj.device_name + 'LMFOM_vs_Freq.avi';
			end
			
			% Get frequency points
			freqs = unique(obj.lp.freq());
			
			lmfoms = zeros(1, numel(freqs));
			
			vid_frames = getframe(gcf);
			vid_frames(1) = [];
			
			% Find LM-FOM at ea. Frequency Point
			count = 0;
			for f = freqs
				
				count = count + 1;
				
				% Create new DA object 
				daf = obj.dupl();
				
				daf.filter("Freq", f); % Filter specific frequency
				lmfoms(count) = daf.lmfom_overall(); % Calculate LM-FOM
				zlabel("Load Modulation Figure of Merit (f = " + string(f./1e9) +" GHz)", 'color', [245, 196, 2]./255);
				
				% Save frame
				vid_frames(count) = getframe(gcf);
			end
			
			figure(2);
			h = plot(freqs./1e9, lmfoms, 'LineStyle', ':', 'Marker', '+');
			xlabel("Frequency (GHz)");
			ylabel("LM-FOM");
			title("Load Modulation Figure of Merit");
			grid on;
			force0y;
			
			if save_img_video
				
				% create the video writer with 1 fps
				vw = VideoWriter(vidpath);
				vw.FrameRate = 2;
				
				open(vw);
				for fi = 1:numel(vid_frames)
					writeVideo(vw, vid_frames(fi));
				end
				close(vw);
				
				saveas(h, filename2);
			end
			
		end
		
		function [lmfom, h] = lmfom_overall(obj, useDark)

			if ~exist('useDark', 'var')
				useDark = true;
			end
			
			% Find point of maximum Pout
			lp_Pmax = obj.lp.gfilter("Pload", "MAX");

			P_max = unique(lp_Pmax.p_out());
			P_OBO = P_max - 3;

			% Plot 6 dB Contour
			figure(1);
			hold off;
			if useDark
				plotsc(lp_Pmax.gamma(), 'Marker', '*', 'Scheme', 'Dark', 'Color', [200, 0, 255]./255);
			else
				plotsc(lp_Pmax.gamma(), 'Marker', '*', 'Scheme', 'Light', 'Color', [200, 0, 255]./255, 'MarkerSize', 8);
			end
			hold on;
			% contoursc3(lp.gamma(), lp.p_out(), 'HeightMax', 1, 'Color', [.9, .7, .7]);
			if useDark
				h1 = xcontoursc3(obj.lp, "Pload", 'HeightMax', 1, 'Color', [2, 103, 245]./255, 'ContourLevels', .5:.5:3, 'Scheme', 'Dark');
			else
				h1 = xcontoursc3(obj.lp, "Pload", 'HeightMax', 1, 'Color', [0, .2, .8], 'ContourLevels', .5:.5:3, 'Scheme', 'Light');
			end
			% [h, cont_data] = contoursc(lp.gamma(), lp.p_out(), 'ContourLabel', "P_{Out} (dBm)", 'ContourLevels', P_OBO, 'Color', [ 68, 255, 0]./255);
			try
				if useDark
					[h, cont_data] = xcontoursc(obj.lp, "PAE", 'ContourLabel', "P_{Out} (dBm)", 'ContourLevels', P_OBO, 'Color', [ 68, 255, 0]./255);
				else
					[h, cont_data] = xcontoursc(obj.lp, "PAE", 'ContourLabel', "P_{Out} (dBm)", 'ContourLevels', P_OBO, 'Color', [ .8, 0, 0], 'LineWidth', 1.7);
				end
			catch
				h = h1;
				lmfom = 0;
				return;
			end
			% [h, cont_data] = contoursc(lp.gamma(), lp.p_out(), 'ContourLabel', "P_{Out} (dBm)", 'ContourLevels', 32, 'Color', [ 68, 255, 0]./255);

			% Merge all gammas (only used if multiple contours returned)
			all_gammas = [];
			for cdi = 1:numel(cont_data)
				all_gammas = [all_gammas, cont_data(cdi).gamma];
			end
			
% 			if numel(cont_data.gamma) > 1e6
% 				displ("")
% 			end
			
			% Find VSWRs
			Z_opt = G2Z(lp_Pmax.gamma()); % Find Z of max power point
			swrs = zeros(1, numel(all_gammas));

		
			count = 0;
			try
				for g = all_gammas
					count = count + 1;

					Z_obo = G2Z(g); % FInd Z of contour point
					renorm_gamma = Z2G(Z_obo, Z_opt); % Find reflection coeff, norm to max power Z
					swrs(count) = vswr(renorm_gamma); % Find VSWR 
				end
			catch
				disp();
			end
			
			% Convert VSWRs to a scaled FOM
			func_fom = @(v) 1./(v-1); % Normalized to VSWR=2, Approaches inf as nears 1 (min VSWR)
			swr_scaled = func_fom(swrs); % Calculate load modulation figure of merit

			% PLot Load modulation Figure of Merit
			lmfom = sum(swr_scaled);
			swr_norm = swr_scaled/max(swr_scaled);

			try
				if useDark
					h = plotsc3(all_gammas, swr_norm, 'Color', [200, 0, 255]./255);
				else
					h = plotsc3(all_gammas, swr_norm, 'Color', [0, 0.6, 0], 'LineWidth', 1.7);
				end
			catch
				displ();
			end
			
			if useDark
				zlabel("Load Modulation Figure of Merit", 'color', [245, 196, 2]./255);
			else
				zlabel("Load Modulation Figure of Merit", 'color', [0, 0, 0]);
			end
			
		end
		
		function [freqs, lmfoms, deltas] = lmpaefom_freq(obj, showIntermediatePlots, alpha, beta, delta, figno)
			% Calls lmpaefom_overall for each unique frequency in the
            % dataset

			if ~exist('showIntermediatePlots', 'var')
				showIntermediatePlots = true;
			end
			
			if ~exist("alpha", 'var')
				alpha = 5; % Number of top PAEs to skip (as outliers)
			end
			
			if ~exist('beta', 'var')
				beta = 3; % Percent from top PAE to accept as 'max' PAE points
			end
			
			if ~exist('delta', 'var')
				delta = .2; % Tolerance in Watts for 6 dB OBO
			end
			
			if ~exist('figno', 'var')
				figno = 2;
			end
			
			% Get frequency points
			freqs = unique(obj.lp.freq());
			
			lmfoms = zeros(1, numel(freqs));
			deltas = zeros(1, numel(freqs));
			
			count = 0;
			for f = freqs
				
				count = count + 1;
				
				obj.filter("Freq", f);
				[lmfoms(count), deltas(count)] = obj.lmpaefom_overall(showIntermediatePlots, alpha, beta, delta);
				
				
				obj.reset();
			end
			
			figure(figno);
% 			yyaxis left;
			plot(freqs./1e9, lmfoms, 'LineStyle', ':', 'Marker', '+', 'Color', [0, 0, .6], 'LineWidth', 1, 'MarkerSize', 7);
% 			yyaxis right;
% 			scatter(freqs./1e9, deltas, 60, 'Marker', '+', 'MarkerEdgeColor', [.6, 0, 0]);
			grid on;
			ylabel("FOM (%)");
			title("PAE Load Modulation FOM");
			xlabel("Frequency (GHz)");
		end
		
		function [FOM, deltaused] = lmpaefom_overall(obj, showPlot, alpha, beta, delta, autoDelta)
			% Give a single LM-PAE-FOM value for all points in the DA
			
			if ~exist('showPlot', 'var')
				showPlot = true;
			end
			
			if ~exist("alpha", 'var')
				alpha = 5; % Number of top PAEs to skip (as outliers)
			end
			
			if ~exist('beta', 'var')
				beta = 3; % Percent from top PAE to accept as 'max' PAE points
			end
			
			if ~exist('delta', 'var')
				delta = .2; % Tolerance in Watts for 6 dB OBO
			end
			
			if ~exist('autoDelta', 'var')
				autoDelta = true;
			end

			deltaused = delta;
			
			% Find max power, find 6 dB OBO
			max_power = max(obj.lp.p_out());
			P_obo = max_power - [6+delta, 6-delta];
			displ("Max power: ", max_power);
			displ("Pobo: [", P_obo(1), ", ", P_obo(2), "]");
			lp_Pmax = obj.lp.gfilter("Pload", "MAX");

			% Filter out points at 6 dB OBO
			lp_obo = obj.lp.gfilter("Pload", P_obo);
			
			if lp_obo.numpoints() < 1
				if ~autoDelta
					FOM = -1;
					return;
				else
					bcount = 2;
					while lp_obo.numpoints() < 1
						P_obo = max_power - [6+delta*bcount, 6-delta*bcount];
						lp_obo = obj.lp.gfilter("Pload", P_obo);
						bcount = bcount + 1;
					end
					deltaused = delta*bcount;
				end
			end

			% Find target PAE
			PAEs = sort(lp_obo.pae());
			if alpha < numel(PAEs)
				max_PAE = PAEs(end-alpha);
			else
				max_PAE = max(PAEs);
			end
			target_PAE = max_PAE - beta;
			displ("   Absolute max OBO PAE, including outliers: ", PAEs(end));
			displ("   Max PAE after removing 'alpha' outliers: ", max_PAE);
			displ("   Target PAE after adding tolerance of 'beta': ", target_PAE);

			% Filter points meeting 'max PAE' condition
			lp_maxs = lp_obo.gfilter("PAE", [target_PAE, NaN]);

			% Calculate VSWR relative to MPP
			Znorm = G2Z(lp_Pmax.gamma());
			Zs = G2Z(lp_maxs.gamma());
			Gnorm = Z2G(Zs, Znorm);
			Vnorm = vswr(Gnorm);

			% Find point with lowest VSWR
			min_VSWR = min(Vnorm);
			idx = find(Vnorm == min_VSWR);

			% Find FOM
			PAEs_maxs = lp_maxs.pae();
			FOM = PAEs_maxs(idx)/min_VSWR;

			displ("FOM: (", PAEs_maxs(idx), ")/(", min_VSWR, ") = ", FOM );
			
			if showPlot
				figure(1);
				subplot(2, 2, 1);
				hold off
				plotsc(lp_obo.gamma(), 'Scatter', true, 'Marker', '+', 'MarkerEdgeColor', [.6, 0, 0]);
				hold on;
				plotsc(lp_Pmax.gamma(), 'Scatter', true, 'Marker', '*', 'MarkerEdgeColor', [0, 0, .6]);
				title("Points meeting 6 dB OBO Condition");

				% Show histogram of selected PAEs
				subplot(2, 2, 2);
				hold off
				hist(lp_obo.pae());
				vlin(target_PAE, 'LineStyle', '--', 'Color', [.6, 0, 0], 'LineWidth', 1);
				vlin(max_PAE, 'LineStyle', '--', 'Color', [.2, .2, .2], 'LineWidth', 1);
				grid on;
				title("PAE Histogram");
				xlabel("PAE (%)");
				ylabel("Number of Points");

				subplot(2, 2, 3);
				hold off
				plotsc(lp_maxs.gamma(), 'Scatter', true, 'Marker', '+', 'MarkerEdgeColor', [.6, 0, 0]);
				hold on
				plotsc(lp_Pmax.gamma(), 'Scatter', true, 'Marker', '*', 'MarkerEdgeColor', [0, 0, .6]);
				maxs_gammas = lp_maxs.gamma();
				plotsc(maxs_gammas(idx), 'Scatter', true, 'Marker', 'o', 'MarkerEdgeColor', [0, .3, 0], 'MSizes', 60);
				title("Points meeting 6 dB OBO and max PAE Condition");
			end
			
		end
		
	end
	
end