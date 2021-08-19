function ph = plotsc(data, varargin)

	expectedDomain = {'Z', 'G'};

    p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('Domain', "G", @(x) any(validatestring(char(x),expectedDomain)) );
	p.addParameter('Ax', gca, @(x) isa(x, 'matlab.graphics.axis.Axes') || isa(x, 'matlab.graphics.GraphicsPlaceholder'));
    p.addParameter('Z0', 50, @isnumeric);

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
		nd = drawsc(ax);
	end
	
	% Get x & y coordinates from gamma
	mag = abs(G);
	arg = angle(G);
	x = mag.*cos(arg);
	y = mag.*sin(arg);
	
	% Plot results
	ph = plot(ax, x,y, plotArgs{:});

	% Set datatip to custom format
	formatdatatipsc(ph, p.Results.Z0);
	
end