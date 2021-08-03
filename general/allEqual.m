function tf = allEqual(varargin)

	tf = true;

	% Check that enough elements exist
	if nargin < 2
		error("Required at least two input arguments.");
	end

	% Check all elements
	for i=2:nargin
		
		a = varargin(i-1);
		b = varargin(i);
		
		% Check that i and i-1 elements are same size
		if ~all(size(a{:}) == size(b{:}))
			tf = false;
			return;
		end
		
		% Check if i and i-1 elements match
		if ~all(a{:} == b{:} )
			tf = false;
			return;
		end
	end
	
end