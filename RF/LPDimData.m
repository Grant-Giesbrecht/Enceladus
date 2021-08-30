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
			
			obj.data = []
			
			displ("");
			
		end
		
		function get(obj, f, value, varargin)
			displ("")
		end
		
	end
		
	end
	
end