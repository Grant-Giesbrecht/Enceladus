function h = drawcircenc(x,y,r, varargin)
	
	%************************ GET PARAMETERS FROM VARARGIN ****************

	N_fine = 100;
	N_coarse = 100;
	mirror = false;
	theta_bounds = [0, 2*3.1415926535];
	
	% Define enclosure parameters
	r_bound_out = 1;
	x_bound_out = 0;
	y_bound_out = 0;
	
	r_bound_in = 0;
	x_bound_in = 0;
	y_bound_in = 0;
	
	% If HandleVisibility option is not set, add it as false.
	[hasN, idx] = cellContains(varargin, 'N', true);
	if hasN
		
		% Update N
		N_fine = varargin{idx+1};
		
		% Delete from varargin
		varargin(idx+1) = [];
		varargin(idx) = [];
		
	end
	
	% Check if mirror option is set
	[hasM, idx] = cellContains(varargin, 'Mirror', true);
	if hasM
		
		% Update N
		mirror = varargin{idx+1};
		
		% Delete from varargin
		varargin(idx+1) = [];
		varargin(idx) = [];
		
	end
	
	% Check if theta bound option is set
	[hasM, idx] = cellContains(varargin, 'Theta', true);
	if hasM
		
		% Update N
		theta_bounds = varargin{idx+1};
		
		% Delete from varargin
		varargin(idx+1) = [];
		varargin(idx) = [];
		
	end
	
	% Check if inner bound option is set
	[hasM, idx] = cellContains(varargin, 'InnerBounds', true);
	if hasM
		
		val = varargin{idx+1};
		if numel(val) ~= 3 || ~isnumeric(val)
			warning("Invalid value for 'InnerBounds'.")
		end
		
		x_bound_in = val(1);
		y_bound_in = val(2);
		r_bound_in = val(3);
		
		% Delete from varargin
		varargin(idx+1) = [];
		varargin(idx) = [];
		
	end
	
	% Check if outer bound option is set
	[hasM, idx] = cellContains(varargin, 'OuterBounds', true);
	if hasM
		
		val = varargin{idx+1};
		if numel(val) ~= 3 || ~isnumeric(val)
			warning("Invalid value for 'InnerBounds'.")
		end
		
		x_bound_out = val(1);
		y_bound_out = val(2);
		r_bound_out = val(3);
		
		% Delete from varargin
		varargin(idx+1) = [];
		varargin(idx) = [];
		
	end

	%************************ CALCULATE COARSE CIRCLE *********************
	
	% Calculate X and Y values
	theta = linspace(theta_bounds(1), theta_bounds(2), N_coarse);
	Xs = r * cos(theta) + x;
	Ys = r * sin(theta) + y;
	
	% Find where cross enclosure
	dist_out = sqrt((Xs-x_bound_out).^2 + (Ys-y_bound_out).^2);
	dist_in = sqrt((Xs-x_bound_in).^2 + (Ys-y_bound_in).^2);
	theta_start = -1;
	theta_end = -1;
	in_region = false;
	for n = 1:numel(Xs)
		if ~in_region
			% Check if was out of region, then moved into region
			if dist_out(n) <= r_bound_out && dist_in(n) >= r_bound_in
				in_region = true;
				
				% Save previous point as starting angle
				if n > 1
					theta_start = theta(n-1);
				else
					theta_start = theta(n);
				end
			end
			
		else
			% Check if was in region, then moved out of region
			if ~(dist_out(n) <= r_bound_out && dist_in(n) >= r_bound_in)
				% Save point as starting angle
				theta_end = theta(n);
				break;
			end
		end
	end
	
	if theta_end == -1
		theta_end = theta(end);
	end
	
	if theta_start == -1
		warning("Failed to find correct theta!");
	end
	
	%************************ CALCULATE FINE ARC **************************
	
	% Calculate X and Y values
	theta = linspace(theta_start, theta_end, N_fine);
	Xs = r * cos(theta) + x;
	Ys = r * sin(theta) + y;
	
	% Find where cross enclosure
	dist_out = sqrt((Xs-x_bound_out).^2 + (Ys-y_bound_out).^2);
	dist_in = sqrt((Xs-x_bound_in).^2 + (Ys-y_bound_in).^2);
	Xencl = [];
	Yencl = [];
	for n = 1:numel(Xs)
		if dist_out(n) <= r_bound_out && dist_in(n) >= r_bound_in
			Xencl = addTo(Xencl, Xs(n));
			Yencl = addTo(Yencl, Ys(n));
		end
	end
	
	h = plot(Xencl, Yencl, varargin{:});
	
	if mirror
		plot(Xencl, -1.*Yencl, varargin{:});
	end
	
end