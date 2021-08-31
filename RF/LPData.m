classdef LPData < handle
% LPDATA Contains load pull data and automates access to observable
% parameters such as Pload or reflection coefficient, saving previous
% calculations and minimizing number of computations.
%

	properties %===========================================================
		
		% A/B Waves
		a1
		a2
		b1
		b2
		
		% DC Bias point
		V1_DC
		V2_DC
		I1_DC
		I2_DC
		
		% Propteries
		props
		
		% Normalization impedance
		Z0
		
		% Calculated Values
		gamma_vals
		pload_vals
		zl_vals
		pae_vals
		
		% List of Calculated Values that are up-to-date
		current % Up-to-date values
		current_tracked % List of all tracked values
		dependencies % Struct, field is tracked values, value of field is list of names of other values dependent on this field
	end %========================== END PROPERTIES ========================
	
	methods %==============================================================
		
		function obj = LPData(Z0) %========================================
			
			% Check for optional parameter Z0
			if ~exist('Z0', 'var')
				Z0 = 50;
			end
			
			obj.a1 = [];
			obj.a2 = [];
			obj.b1 = [];
			obj.b2 = [];
			
			obj.V1_DC = [];
			obj.I1_DC = [];
			obj.V2_DC = [];
			obj.I2_DC = [];
			
			obj.Z0 = Z0;
			
			obj.gamma_vals = [];
			obj.pload_vals = [];
			obj.zl_vals = [];
			obj.pae_vals = [];
			
			% Create 'current' as an empty list of strings.
			% 'current' is a list of all tracked values with values that
			% are up-to-date/current.
			obj.current = "";
			obj.current(1) = [];
			
			obj.current_tracked = ["GAMMA", "P_LOAD", "Z_L", "PAE"]; %List of all values tracked for currency
			
			% 'dependencies' is a struct. The field name indicates a
			% tracked value, the value is a list of other tracked values
			% upon which the field-name is dependent. (ie. GAMMA is
			% dependent on Z_L
			obj.dependencies = [];
			obj.dependencies.GAMMA = ["Z_L"];
			
			
		end %=========================== END INITAILIZER ==================
		
		function v = gamma(obj) %==========================================
		%GAMMA Return the reflection coefficient
			
			% Make sure data is up to date
			if ~obj.isCurrent("GAMMA")
				obj.gamma_vals = ab2gamma(obj.a2, obj.b2);
				obj.setCurrent("GAMMA")
			end
			
			% Return value
			v = obj.gamma_vals;
		end %============================ END GAMMA =======================
		
		function v = p_load(obj) %=========================================
		%P_LOAD Calculate power delivered to the load
			
			% Make sure data is up to date
			if ~obj.isCurrent("P_LOAD")
				
				% Equation from Pozar (4th ed.) eq. 4,62
				obj.pload_vals = 0.5 .* abs(obj.a2).^2 - 0.5 .* abs(obj.b2).^2;
				
				obj.setCurrent("P_LOAD");
			end
			
			% Return value
			v = obj.pload_vals;
		end %=========================== END P_LOAD =======================
		
		function v = z_l(obj) %==========================================
		% Converts the load pull gammas to impedances
		
			if ~obj.isCurrent("Z_L")
				obj.gamma(); % Make sure gamma has been calculated
				obj.zl_vals = obj.Z0 .* (1 + obj.gamma_vals)./(1 - obj.gamma_vals);
				obj.setCurrent("Z_L");
			end
			
			% Return value
			v = obj.zl_vals;
		end %========================== END Z_L ===========================
		
		function v = pae(obj) %============================================
			
			if ~obj.isCurrent("PAE")
				obj.pae_vals = (obj.p_load() - obj.p_in())./obj.p_dc;
				obj.setCurrent("PAE");
			end
			
			% Return value
			v = obj.pae_vals;
			
		end %========================== END PAE ===========================
		
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
	
	end %========================= END METHODS ============================
		
end %=========================== END CLASSDEF =============================