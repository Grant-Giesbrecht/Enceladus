classdef StringIdx
% StringIdx String object for representing substrings
%	String object with start and end indecies referring to its
%	location in a larger string.

	properties
		str % String value
		idx % Index where string value ended in some larger string
		sidx
	end
	methods
		function obj=StringIdx(val, start_idx)
			% Constructor
			
			obj.str = string(val);
			obj.idx = start_idx;
			obj.sidx = -1;
		end
	end
end