function nm = resamplecmap(map, N)
%RESAMPLECMAP Resamples a colormap for N points. Intended to be used with
%regular plots.
	
	% Get colormap if not numeric
	if ~isnumeric(map)
		map = colormap(map);
	end
	
	%Get size of current map
	[N0, r] = size(map);
	
	% Errorcheck
	if r ~= 3
		error("Invalid map submitted");
		nm = [];
		return;
	end
	if N0 < N
		warning("Map has fewer points than requested! You should fix this and add interpolation!")
		nm = [];
		return;
	end
	
	% Resample
	delta = (N0-1)/(N-1);
	idx = 1+round(linspace(0,N-1,N).*delta);
	nm = map(idx, :);
end