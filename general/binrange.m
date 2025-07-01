function bins = binrange(R, delta)

	%Check for optional argumet delta
	if ~exist('delta', 'var')
		delta = 0;
	end

	% Initialize bins array
	bins = zeros(length(R)-1, 2);
	
	% Populate bins
	for ridx = 1:length(R)-1
		if ridx ~= 1
			bins(ridx, :) = [R(ridx)+delta, R(ridx+1)];
		else
			bins(ridx, :) = [R(ridx), R(ridx+1)];
		end
	end

end