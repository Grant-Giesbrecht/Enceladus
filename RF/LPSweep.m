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
		
	end
			
end