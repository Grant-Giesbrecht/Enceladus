function setytick(spacing, trim_bounds)
	
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
			xdmin = min([c.YData]);
			xdmax = max([c.YData]);

			% Get global extrema
			min_val = min(min_val, xdmin);
			max_val = max(max_val, xdmax);
		end
		
		xl = [min_val, max_val];
	else
		%Simpler way to find bounds:
		xl = ylim();
	end
	
	set(gca,'Ytick',xl(1):spacing:xl(2))
	ylim(xl);
end