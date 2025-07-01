function setxtick(spacing, trim_bounds)
	
	% Find optional arugments
	if ~exist('trim_bounds', 'var')
		trim_bounds = true;
	end
	
	% Get axes limits
	if trim_bounds
		ax = gca;
		ch = ax.Children;
		min_val = NaN;
		max_val = NaN;
		for c = ch

			% Get local extrema
			xdmin = min([c.XData]);
			xdmax = max([c.XData]);

			% Get global extrema
			min_val = min(min_val, xdmin);
			max_val = max(max_val, xdmax);
		end
		
		xl = [min_val, max_val];
	else
		%Simpler way to find bounds:
		xl = xlim();
	end
	
	set(gca,'Xtick',xl(1):spacing:xl(2))
	xlim(xl);
end