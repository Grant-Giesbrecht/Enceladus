classdef ContourSpec < handle
	
	properties
		
		gamma % Reflection coefficients corresponding to ea. point in 'values'
		values % Y-values of parameter
		
		labelstr % How to label parameter in the plot
		
		venn_min % For vennsc(), value must be >= (ignored if empty)
		venn_max % For vennsc(), vlaue must be <= (ignored if empty)
		
		color % Color to plot contours
		
	end
	
	methods
		
		function obj = ContourSpec(gamma, values, labelstr, venn_min, venn_max, color)
			obj.gamma = gamma;
			obj.values = values;
			
			if exist('labelstr', 'var')
				obj.labelstr = labelstr;
			end
			
			if exist('venn_min', 'var')
				obj.venn_min = venn_min;
			end
			
			if exist('venn_max', 'var')
				obj.venn_max = venn_max;
			end
			
			if exist('color', 'var')
				obj.color = color;
			end
		end
		
	end
	
end

















