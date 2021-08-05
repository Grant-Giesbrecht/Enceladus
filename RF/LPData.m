classdef LPData < handle
% LPDATA Contains load pull data from an MDF file and provides easy access
% to calculated parameters.
%

	properties %===========================================================
		
		% A/B Waves
		a1
		a2
		b1
		b2
		
		% Calculated Values
		gamma_vals
		pload_vals
		
		% List of Calculated Values that are up-to-date
		current % Up-to-date values
		current_tracked % List of all tracked values
	end %========================== END PROPERTIES ========================
	
	methods %==============================================================
		
		function obj = LPData() %==========================================
			obj.a1 = [];
			obj.a2 = [];
			obj.b1 = [];
			obj.b2 = [];
			
			obj.gamma_vals = [];
			obj.pload_vals = [];
			
			obj.current = "";
			obj.current(1) = [];
			obj.current_tracked = ["GAMMA", "P_LOAD"];
			
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
				obj.pload_vals = (obj.a2).^2;
				obj.setCurrent("P_LOAD");
			end
			
			% Return value
			v = obj.gamma_vals;
		end %=========================== END P_LOAD =======================
		
		function tf = isCurrent(obj, name) %===============================
		%ISCURRENT Check if a variable is current
			tf = any(name == obj.current);
		end %========================== END ISCURRENT =====================
		
		function setCurrent(obj, name, status) %===========================
		%SETCURRENT Update the status of a variable as current or
		%not-current
			
			% CHeck for optional arguments
			if ~exist('status', 'var')
				status = true;
			end
			
			name = upper(name);
			
			if ~any(name == obj.current_tracked)
				warning("Invalid tracking name.");
				return;
			end
			
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
		end %=================== END SETCURRENT ===========================
	
	end %========================= END METHODS ============================
		
end %=========================== END CLASSDEF =============================