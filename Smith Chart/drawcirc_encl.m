function h = drawcirc_encl(x,y,r, varargin)
	
	N = 100;
	mirror = false;
	
	% If HandleVisibility option is not set, add it as false.
	[hasN, idx] = cellContains(varargin, 'N', true);
	if hasN
		
		% Update N
		N = varargin{idx+1};
		
		% Delete from varargin
		varargin(idx+1) = [];
		varargin(idx) = [];
		
	end
	
	[hasM, idx] = cellContains(varargin, 'Mirror', true);
	if hasM
		
		% Update N
		mirror = varargin{idx+1};
		
		% Delete from varargin
		varargin(idx+1) = [];
		varargin(idx) = [];
		
	end

	% Calculate X and Y values
	theta = linspace(0, 2*3.1415926535, N);
	Xs = r * cos(theta) + x;
	Ys = r * sin(theta) + y;
	
	% Define enclosure parameters
	r_bound = 1;
	x_bound = 0;
	y_bound = 0;
	
	% Find where cross enclosure
	dist = sqrt((Xs-x_bound).^2 + (Ys-y_bound).^2);
	Xencl = []
	Yencl = []
	for n = 1:numel(Xs)
		if dist(n) <= r_bound
			Xencl = addTo(Xencl, Xs(n));
			Yencl = addTo(Yencl, Ys(n));
		end
	end
	
	h = plot(Xencl, Yencl, varargin{:});
	
	if mirror
		plot(Xencl, -1.*Yencl, varargin{:});
	end
	
end