classdef LoadPull
% LOADPULL Class for storing, computing, and sorting load pull data
%
% 
	
	properties
		
		%************* Base Parameters (Not Derived) *********************
		
		freq
		Z0
		
		a1
		b1
		a2
		b2
		
		V1_DC
		I1_DC
		V2_DC
		I2_DC
		
		props
		
		%************ Derived Parameters (Calculated from Base) **********
		
		comp_Pload
		comp_PAE
		comp_gamma
		comp_Pdc
		comp_Pin
		comp_ZL
		comp_DrainEff
		
		dependencies
		current
		tracked
		
	end
	
	methods
		
		function obj = LoadPull(obj)
			
			% Check for optional parameter Z0
			if ~exist('Z0', 'var')
				Z0 = 50;
			end
			
			obj.freq = [];
			obj.Z0 = Z0;

			obj.a1 = [];
			obj.b1 = [];
			obj.a2 = [];
			obj.b2 = [];

			obj.V1_DC = [];
			obj.I1_DC = [];
			obj.V2_DC = [];
			obj.I2_DC = [];

			obj.props = {};
			
			
			
			obj.comp_Pload = [];
			obj.comp_PAE = [];
			obj.comp_gamma = [];
			obj.comp_Pdc = [];
			obj.comp_Pin = [];
			obj.comp_ZL = [];
			obj.comp_DrainEff = [];
			
			
			% Create 'current' as an empty list of strings.
			% 'current' is a list of all tracked values with values that
			% are up-to-date/current.
			obj.current = "";
			obj.current(1) = [];
			
			obj.tracked = ["GAMMA", "P_LOAD", "Z_L", "PAE", "P_IN", "P_DC", "DRAIN_EFF"]; %List of all values tracked for currency. Same as function names but capitolized
			
			% 'dependencies' is a struct. The field name indicates a
			% tracked value, the value is a list of other tracked values
			% upon which the field-name is dependent. (ie. GAMMA is
			% dependent on Z_L
			obj.dependencies = [];
			obj.dependencies.GAMMA = ["Z_L"];
			obj.dependencies.PAE = ["P_IN", "P_LOAD", "P_DC"];
			obj.dependencies.DRAINEFF = ["P_LOAD", "P_DC"];
		end
		
		%==================================================================
		%====             Sort and Filter Functions                    ====
		%==================================================================
		
		function filter(obj) %=============================================
			
		end %======================== END FILTER ==========================
		
		function organize(obj, varargin) %=================================
			
		end %======================== END ORGANIZE ========================
		
		
		%==================================================================
		%====        Functions for Calculating Derived Parameters      ====
		%==================================================================
		
		function v = gamma(obj) %==========================================
		%GAMMA Return the reflection coefficient
			
			% Make sure data is up to date
			if ~obj.isCurrent("GAMMA")
				obj.comp_gamma = ab2gamma(obj.a2, obj.b2);
				obj.setCurrent("GAMMA")
			end
			
			% Return value
			v = obj.comp_gamma;
		end %============================ END GAMMA =======================
		
		function v = p_load(obj) %=========================================
		%P_LOAD Calculate power delivered to the load
			
			% Make sure data is up to date
			if ~obj.isCurrent("P_LOAD")
				
				% Equation from Pozar (4th ed.) eq. 4,62. NOTE: I flipped a
				% & b because I think Pozar is using an unconventional
				% description of a vs. b.
				obj.comp_Pload = 0.5 .* abs(obj.b2).^2 - 0.5 .* abs(obj.a2).^2;
				
				obj.setCurrent("P_LOAD");
			end
			
			% Return value
			v = obj.comp_Pload;
		end %=========================== END P_LOAD =======================
		
		function v = p_in(obj) %===========================================
			
			% Make sure data is up-to-date
			if ~obj.isCurrent("P_IN")
				
				% Taken from p_load function and modified to work for input
				obj.comp_Pin = 0.5 .* abs(obj.a1).^2 - 0.5 .* abs(obj.b1).^2;
				
				obj.setCurrent("P_IN");
			end
			
			v = obj.comp_Pin;
			
		end %=========================== END P_IN =========================
		
		function v = p_dc(obj) %===========================================
			
			if ~obj.isCurrent("P_DC")
				obj.comp_Pdc = abs(obj.V1_DC .* obj.I1_DC) + abs(obj.V2_DC .* obj.I2_DC);				
				obj.setCurrent("P_DC");
			end
			
			v = obj.comp_Pdc;
			
		end %=========================== END P_DC =========================
		
		function v = z_l(obj) %==========================================
		% Converts the load pull gammas to impedances
		
			if ~obj.isCurrent("Z_L")
				% NOTE: USes calls to gamma to make sure gamma is current
				obj.comp_ZL = obj.Z0 .* (1 + obj.gamma())./(1 - obj.gamma());
				obj.setCurrent("Z_L");
			end
			
			% Return value
			v = obj.comp_ZL;
		end %========================== END Z_L ===========================
		
		function v = pae(obj) %============================================
			
			if ~obj.isCurrent("PAE")
				obj.comp_PAE = 100.*(abs(obj.p_load()) - abs(obj.p_in()))./obj.p_dc;
				obj.setCurrent("PAE");
			end
			
			% Return value
			v = obj.comp_PAE;
			
		end %========================== END PAE ===========================
		
		function v = drain_eff(obj) %=======================================
			
			if ~obj.isCurrent("DRAIN_EFF")
				obj.comp_DrainEff = 100.* abs(obj.p_load() ./ obj.p_dc());
				obj.setCurrent("DRAIN_EFF");
			end
			
			v = obj.comp_DrainEff;
			
		end %========================== END DRAINEFF ======================
		
		%==================================================================
		%====              Functions for tracking currency             ====
		%==================================================================
		
		function tf = isCurrent(obj, name) %===============================
		%ISCURRENT Check if a variable is current
			tf = any(name == obj.current);
		end %========================== END ISCURRENT =====================
		
		function setCurrent(obj, name, status) %===========================
		% SETCURRENT Update the status of a variable as current or
		% not-current
		%
		% If status=true, sets to up-to-date, if false, to out-of-date.
			
			% Check for optional arguments
			if ~exist('status', 'var')
				status = true;
			end
			
			% Convert all to uppercase
			name = upper(name);
			
			% If name is not in list of all tracked variables, quit
			if ~any(name == obj.current_tracked)
				warning("Invalid tracking name.");
				return;
			end
			
			% Update status
			if status % Add to current
				if ~any(obj.current == name)
					obj.current = addTo(obj.current, name);
				end
			else % Remove from current
				if any(obj.current == name)
					idx = find(obj.current==name, 1, 'first');
					obj.current(idx) = [];
				end
			end
			
			% Go through dependencies and update their statuses if top
			% level status was set to out-of-date
			if ~status && isfield(obj.dependencies, name)
				
				% Scan through all dependencies and set to out-of-date
				for d = obj.dependencies.(name)
					obj.setCurrent(d, false);
				end
				
			end
			
		end %=================== END SETCURRENT ===========================
		
		function reset(obj) %==============================================
			
			obj.current = "";
			obj.current(1) = [];
			
		end %=================== END RESET ================================
		
	end
	
end