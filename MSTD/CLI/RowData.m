classdef RowData < handle
	
	properties
		data
	end
	
	methods 
		
		function obj = RowData()
			obj.data = [];
		end
		
		function l = len(obj)
			l = length(obj.data);
		end
		
		function add(obj, s)
			
			s = string(s);
			
			obj.data = addTo(obj.data, s);
		end
		
		function sl = strLen(obj, c)
			
			sl = strlength(obj.data(c));
			
		end
	end
	
end