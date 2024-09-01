function shrink_figs(figs, newsize)
	
	% Handle optional arguments
	if ~exist('newsize', 'var')
		newsize = [470, 290];
	end
	
	for fn = figs
		
		% Get figure handle
		f = figure(fn);
		
		% Shrink figure
		p0 = f.Position;
		f.Position = [p0(1), p0(2), newsize(1), newsize(2)];
	end

end