classdef ContourSpec < handle
	
	properties
		
		gamma % Reflection coefficients corresponding to ea. point in 'values'
		values % Y-values of parameter
		
		labelstr % How to label parameter in the plot
		
		venn_min % For vennsc(), value must be >= (ignored if empty)
		venn_max % For vennsc(), vlaue must be <= (ignored if empty)
		
		color % Color to plot contours
		
		values_str
		lp
	end
	
	methods
		
		function obj = ContourSpec(gamma, values, labelstr, venn_min, venn_max, color, values_str, lp)
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
			
			if exist('values_str', 'var')
				obj.values_str = values_str;
			end
			
			if exist('lp', 'var')
				obj.lp = lp;
			end
		end
		
	end
	
end

















