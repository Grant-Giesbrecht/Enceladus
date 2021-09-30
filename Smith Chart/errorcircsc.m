function errorcircsc(data, stdev, varargin)

	expectedDomain = {'Z', 'G'};
	expectedSchemes = {'Light', 'Dark'};

    p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('Domain', "G", @(x) any(validatestring(char(x),expectedDomain)) );
	p.addParameter('Ax', gca, @(x) isa(x, 'matlab.graphics.axis.Axes') || isa(x, 'matlab.graphics.GraphicsPlaceholder'));
    p.addParameter('Z0', 50, @isnumeric);
	p.addParameter('ColorVar', [], @isnumeric);
	p.addParameter('Colormap', [], @isnumeric);
% 	p.addParameter('Scatter', false, @islogical);
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
% 	p.addParameter('MSizes', [], @(x) true );

    p.parse(varargin{:});
	
	ax = p.Results.Ax;

	% Get input data as a reflection coefficient
	if p.Results.Domain == "Z"
		G = Z2G(data, p.Results.Z0);
	else
		G = data;
	end
	
	% If hold is not applied, redraw smith chart
	if ~ishold
		nd = drawsc(ax, p.Results.Scheme);
	end
	
	% Get x & y coordinates from gamma
	mag = abs(G);
	arg = angle(G);
	x = mag.*cos(arg);
	y = mag.*sin(arg);

	if ~isempty(p.Results.Colormap)
		cmap = p.Results.Colormap;
	else
		cmap = colormap;
	end

	c_list = getColorData(p.Results.ColorVar, cmap);
	
	for idx = 1:length(x)		
		
		c = c_list(idx, :);
		
		p = nsidedpoly(100, 'Center', [x(idx), y(idx)], 'Radius', stdev(idx));
		plot(p, 'FaceColor', c, 'FaceAlpha', .05)
		
	end
	
end