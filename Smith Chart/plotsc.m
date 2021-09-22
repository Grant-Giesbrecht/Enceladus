function ph = plotsc(data, varargin)

	if isnan(data)
		return
	end

	expectedDomain = {'Z', 'G'};
	expectedSchemes = {'Light', 'Dark'};

    p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('Domain', "G", @(x) any(validatestring(char(x),expectedDomain)) );
	p.addParameter('Ax', gca, @(x) isa(x, 'matlab.graphics.axis.Axes') || isa(x, 'matlab.graphics.GraphicsPlaceholder'));
    p.addParameter('Z0', 50, @isnumeric);
	p.addParameter('ColorVar', [], @isnumeric);
	p.addParameter('Colormap', [], @isnumeric);
	p.addParameter('Scatter', false, @islogical);
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
	p.addParameter('MSizes', [], @(x) true );
	p.addParameter('ContourValue', [], @isnumeric );
	p.addParameter('ContourLabel', [], @(x) isstring(x) || ischar(x) );

    p.parse(varargin{:});
	
	% Get axes
% 	if p.Results.Ax == []
% 		ax = gca;
% 	else
% 		ax = p.Results.Ax;
% 	end
	ax = p.Results.Ax;
	
    % Get plot arguments
    tmp = [fieldnames(p.Unmatched),struct2cell(p.Unmatched)];
    plotArgs = reshape(tmp',[],1)'; 

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
	
	% Plot results
	if p.Results.Scatter
		ph = scatter(ax, x, y, p.Results.MSizes, plotArgs{:});
	else
		ph = plot(ax, x,y, plotArgs{:});
	end
	
	% Add color map to markers
	if ~isempty(p.Results.ColorVar)
		
		if ~isempty(p.Results.Colormap)
			cmap = p.Results.Colormap;
		else
			cmap = colormap;
		end
		
		c = getColorData(p.Results.ColorVar, cmap);
		ph = scatter(ax, x, y, p.Results.MSizes, c, 'Marker', '+');
	end

	% Set datatip to custom format
	if isempty(p.Results.ContourValue) || isempty(p.Results.ContourLabel)
		formatdatatipsc(ph, p.Results.Z0);
	else
		formatdatatipsc2(ph, p.Results.Z0, p.Results.ContourLabel, p.Results.ContourValue);
	end
	
end