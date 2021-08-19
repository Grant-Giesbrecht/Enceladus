function h = fillcirc(x,y,r,C, varargin)
	
	N = 100;
	
	% If HandleVisibility option is not set, add it as false.
	[hasN, idx] = cellContains(varargin, 'N', true);
	if hasN
		
		% Update N
		N = varargin{idx+1};
		
		% Delete from varargin
		varargin(idx+1) = [];
		varargin(idx) = [];
		
	end

	theta = linspace(0, 2*3.1415926535, N);
	x = r * cos(theta) + x;
	y = r * sin(theta) + y;
	h = patch(x, y, C, varargin{:});
	
	set( get( get( h, 'Annotation'), 'LegendInformation' ), 'IconDisplayStyle', 'off' );
end