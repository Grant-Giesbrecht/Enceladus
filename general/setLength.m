function v = setLength(vec, l, newval)
% SETLENGTH Changes a vector to be a specific length
%
%	SETLENGTH(VEC, L) Add or remove elements to VEC to resize it to length
%	L. If VEC is a numeric type or empty, zeros will be added if new
%	elements are required. Otherwise, the last elemnt of the vector will be
%	duplicated until the correct length is met. If elements must be
%	removed, they will be removed from back to front.
%
%	SETLENGTH(VEC, L, NEWVAL) Add or remove elements to VEC t resize it to
%	length L. If new elements are required, the value of these elements
%	will be NEWVAL. If elements must beremoved, they will be removed from
%	back to front.
%


	% Verify matrix dimensions are not out of bounds
	[r, c] = size(vec);
	if r > 1
		error("setLength() cannot operate on 2+ dimension matrices.");
	end

	% Check if 'newval' provided
	if ~exist('newval','var') % If not...	
		% If it is a number, or no type is specified b/c len=0
		if isnumeric(vec) || isempty(vec)
			newval = 0; % Fill with zeros
		else 
			newval = vec(end) % Fill with repeats of last value
		end
	end
	
	% Repair vector size
	if length(vec) > l % Check if vector is too long
		vec(l+1:end) = []; % Delete extra elements
	end
	
	% Fill with 'newval' until reach new length
	while length(vec) < l
		vec = addTo(vec, newval);
	end
	
	v = vec;

end