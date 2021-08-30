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
		
		function get(obj, varargin)
			
			lpd = LPData;
			
			for d = obj.data
% 				if d.props(
% 					
% 				end
			end
			
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