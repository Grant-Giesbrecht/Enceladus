classdef LPSweep < handle
% LPSWEEP Represents the data from swept, possibly multidimensional load
% pull. It is formatted as an array of LPPoints, and can filter said
% LPPoints to return LPData objects (from which observables such as Pload
% and gamma can be calculated).

	properties
		
		data; % List of LPPoints
		
	end
	
	methods
		
		function obj = LPSweep()
			
			obj.data = [];
						
		end
		
		function lpd = get(obj, varargin)
			
			% Create output variable
			lpd = LPData;
			
			% Create index array to filter
			idxs = 1:numel(obj.data);
			
			% Ensure correct (Divis. by 3) number of arguments
			if mod(numel(varargin), 3) ~= 0
				error("Incorrect number of arguments");
			end
			
			% Scan over all filter commands
			for vi = 1:3:numel(varargin)
				
				idxs = obj.filter(varargin{vi}, varargin{vi+1}, varargin{vi+2}, idxs);
				
			end
			
			% Populate LPData class
			for idx = idxs
				
				lpd.a1 = addTo(lpd.a1, obj.data(idx).a1(1) );
				lpd.a2 = addTo(lpd.a2, obj.data(idx).a2(1) );
				lpd.b1 = addTo(lpd.b1, obj.data(idx).b1(1) );
				lpd.b2 = addTo(lpd.b2, obj.data(idx).b2(1) );
				
				
				lpd.V1_DC = addTo(lpd.V1_DC, obj.data(idx).getProp("V1"));
				lpd.I1_DC = addTo(lpd.I1_DC, obj.data(idx).getProp("I1"));
				lpd.V2_DC = addTo(lpd.V2_DC, obj.data(idx).getProp("V2"));
				lpd.I2_DC = addTo(lpd.I2_DC, obj.data(idx).getProp("I2"));
			end
			
		end
		
		function lps = getSweep(obj, varargin)
			
			% Create output variable
			lps = LPSweep;
			
			% Create index array to filter
			idxs = 1:numel(obj.data);
			
			% Ensure correct (Divis. by 3) number of arguments
			if mod(numel(varargin), 3) ~= 0
				error("Incorrect number of arguments");
			end
			
			% Scan over all filter commands
			for vi = 1:3:numel(varargin)
				
				idxs = obj.filter(varargin{vi}, varargin{vi+1}, varargin{vi+2}, idxs);
				
			end
			
			% Populate LPSweep class
			lps.data = obj.data(idxs);
		end
		
		function idxso = filter(obj, p, v_lo, v_hi, idxsi)
			
			idxso = idxsi;
			
			% If not specified, must be equal to v_lo
			if ~exist('v_hi', 'var')
				v_hi = v_lo;
			end
			
			% If not specified, scan all indecies
			if ~exist('idxsi', 'var')
				idxsi = 1:numel(obj.data);
			end
			
			% Scan over all allow indecies
			for idx = idxsi
				
				% If value does not match...
				pv = obj.data(idx).getProp(p);
				if isempty(pv) || pv < v_lo || pv > v_hi
					
					% Find and remove from output indecies
					ri = idxso == idx;
					idxso(ri) = [];
				end
				
			end
			
		end
		
		function vals = listPropUnique(obj, p, tol)
			
			% Default tolerance = 0%
			if ~exist('tol', 'var')
				vals = unique(obj.listProp(p));
				return;
			end
			
			vals = uniquetol(obj.listProp(p), tol);
		end
		
		function vals = listProp(obj, p)
		% LISTPROP Show values for all LPPoints for specific property 'p'
		
			is_1d = true;
		
			vals = {};
			for d = obj.data
				
				if isfield(d.props, p)
					v = d.getProp(p);
					
					[r,c] = size(v);
					if r > 1 || c > 1
						is_1d = false;
					end
					
					vals{end+1} = v;
				end
				
			end
			
			% Change to list if possible
			if is_1d
				vals = [vals{:}];
			end
		
		end
		
		function show(obj)
			
			indent = "";
			rel_indent = "    ";
			
			a1_fund_only = false;
			a1_has_harms = false;
			
			start_props = true;
			props = [];
			fields_match = true;
			
			for d = obj.data
				
				% Check dimensions of A/B waves
				if numel(d.a1) == 1
					a1_fund_only = true;
				end
				if numel(d.a1) > 1
					a1_has_harms = true;
				end
				
				% Check fields
				if start_props
					props = ccell2mat(fields(d.props));
					start_props = false;
				end
				
				try
					if ~all(props == ccell2mat(fields(d.props)))
						fields_match = false;
					end
				catch
					fields_match = false;
				end
			end
			
			displ(indent, "Contains ", numel(obj.data), " LPPoints");
			if a1_fund_only && a1_has_harms
				displ(indent, rel_indent, "A/B Waves: Mixed, fundamental only and harmonics");
			elseif a1_fund_only
				displ(indent, rel_indent, "A/B Waves: Fundamental");
			elseif a1_has_harms
				displ(indent, rel_indent, "A/B Waves: Fundamental + harmonics");
			else
				displ(indent, rel_indent, "A/B Waves: ** Missing! **");
			end
			
			displ(indent, "Properties: ")
			if ~fields_match
				displ(rel_indent, "** Properties do not match! **");
			else
				for f = props
					displ(rel_indent, indent, f);
				end
			end
		end
		
	end
			
end