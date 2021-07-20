classdef TrimState < handle
	
	properties
		trim_enabled
		alignment
		len
	end
	
	methods
		
		function obj = TrimState(en, al, l)
		
			% Verify correct alignment type provided
			if ~strcmp(al, "r") && ~strcmp(al, "l") && ~strcmp(al, "c")
				obj.alignment = 'c';
			end
			
			obj.trim_enabled = en;
			obj.alignment = al;
			obj.len = l;
			
		end
		
	end
	
end