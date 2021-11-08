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
		
		function venn_freq(obj, pae_spec, pout_spec, hidePlots)
			
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
				c1 = ContourSpec(lpfilt.gamma(), lpfilt.pae(), "PAE (%)", pae_spec, [], [0, .5, 0]); % PAE >= 50%
				c2 = ContourSpec(lpfilt.gamma(), lpfilt.p_load(), "Pout (W)", pout_spec , [], [0, 0, .8]); %Pout >= 4,4W

				% Generate vennsc
				hold off
				[~,~,a] = vennsc([c1, c2], 'HidePlots', hidePlots);
% 				plotsc(lpfilt.gamma(), 'Scatter', true, 'Marker', '+', 'MarkerEdgeColor', [.6, 0, 0]);
				obj.fom_vs.freq(count) = a;
				legend('PAE', "P_{out}", 'Location', 'SouthEast');
				title("Region: F="+string(f./1e9)+" GHz");

				count = count + 1;
			end
			
		end
		
		function fom_freq_vgs(obj, pae_spec, pout_spec)
			
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
			surf(unique(obj.lp.freq())./1e9, vgs, fom_sweep);
			xlabel("Frequency (GHz)");
			ylabel("V_{GS} (V)");
			zlabel("FOM");
			title("FOM over Frequency and Gate Bias");
			
		end
		
		function fom_freq_pin(obj, pae_spec, pout_spec)
			
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
			surf(unique(obj.lp.freq())./1e9, pin, fom_sweep);
			xlabel("Frequency (GHz)");
			ylabel("P_{In} (dBm)");
			zlabel("FOM");
			title("FOM over Frequency and Input Power");
			
		end
		
		function fom_freq(obj)
			figure(6);
			hold off
			plot(unique(obj.lp.freq())./1e9, obj.fom_vs.freq, 'LineStyle', '-.', 'Marker', '*', 'MarkerSize', 15, 'LineWidth', 1);
			xlabel("Frequency (GHz)");
			ylabel("FOM (\Gamma^2)");
			title("Figure of Merit over Frequency");
			grid on
			force0y;
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
		
		function lmfom(obj)
			
		end
		
	end
	
end