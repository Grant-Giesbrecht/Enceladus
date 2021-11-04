classdef DeviceAnalysis < handle
	
	properties
		
		% Loadpull data
		lp
		
		% Struct, field names are the independent variable (ie. FOM vs
		% Field). List FOM values for 
		fom_vs
		
		% List of ContourSpecs which together define the criteria for the
		% FOM pass.
		fom_specs 
		
	end
	
	methods
		
		function obj = DeviceAnalysis(lp)			
			obj.lp = lp;
			
			obj.fom_vs = {};
			
			obj.fom_specs = [];
		end
		
		function showvars(obj)			
			
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
% 				if quants(i) < 10
% 					ddfi = DDFItem(obj.lp.getArrayFromName(namestr), "StringGenerator", "");
% 					valstr = ddfi.getValueStr();
% 					valstr = ", " + valstr;
% 				end
				displ("    ", namestr, ": ", quants(i) , " unique values", valstr); 
			end
			
			barprint("Single-Valued Properties:");
			for i = 1:numel(names_one)
				namestr = names_one(i);
				if ~strcmpi(namestr, "FREQ")
					namestr = "PROPS."+namestr;
				end
				displ("    ", namestr);%, " = ", obj.lp.getArrayFromName(namestr)); 
			end
			
		end
		
		function venn_freq(obj, pae_spec, pout_spec)
			
			freqs = unique(obj.lp.freq());
			
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
				subplot(2, 3, count);

				% Filter LP to specific points
				lpfilt = obj.lp.get(obj.lp.filter("Freq", f));

				% Create contour-spec classes
				c1 = ContourSpec(lpfilt.gamma(), lpfilt.pae(), "PAE (%)", pae_spec, [], [0, .5, 0]); % PAE >= 50%
				c2 = ContourSpec(lpfilt.gamma(), lpfilt.p_load(), "Pout (W)", pout_spec , [], [0, 0, .8]); %Pout >= 4,4W

				% Generate vennsc
				hold off
				[~,~,a] = vennsc([c1, c2]);
% 				plotsc(lpfilt.gamma(), 'Scatter', true, 'Marker', '+', 'MarkerEdgeColor', [.6, 0, 0]);
				obj.fom_vs.freq(count) = a;
				legend('PAE', "P_{out}", 'Location', 'SouthEast');
				title("Region: F="+string(f./1e9)+" GHz");

				count = count + 1;
			end
			
		end
		
		function vt_pae_vs_freq(obj)
			vtplot(obj.lp, "PAE", "Freq", unique(obj.lp.freq()), "%", "GHz", 1e9, 1);
			ylim([0, 100]);
		end
		
		function vt_pout_vs_freq(obj)
			vtplot(obj.lp, "Pload", "Freq", unique(obj.lp.freq()), "W", "GHz", 1e9, 3);
			ylim([0, 5.5]);
		end
		
	end
	
end