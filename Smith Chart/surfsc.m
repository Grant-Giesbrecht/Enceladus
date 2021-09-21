function surfsc(gamma, val, varargin)

	expectedDomain = {'Z', 'G'};
	expectedSchemes = {'Light', 'Dark'};

    p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('Domain', "G", @(x) any(validatestring(char(x),expectedDomain)) );
	p.addParameter('Ax', gca, @(x) isa(x, 'matlab.graphics.axis.Axes') || isa(x, 'matlab.graphics.GraphicsPlaceholder'));
    p.addParameter('Z0', 50, @isnumeric);
% 	p.addParameter('ColorVar', [], @isnumeric);
% 	p.addParameter('Colormap', [], @isnumeric);
% 	p.addParameter('Scatter', false, @islogical);
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
% 	p.addParameter('MSizes', [], @(x) true );

    p.parse(varargin{:});
	
	ax = p.Results.Ax;
	
	% Get plot arguments
    tmp = [fieldnames(p.Unmatched),struct2cell(p.Unmatched)];
    plotArgs = reshape(tmp',[],1)'; 
	
	% Get input data as a reflection coefficient
	if p.Results.Domain == "Z"
		G = Z2G(gamma, p.Results.Z0);
	else
		G = gamma;
	end
	
	% If hold is not applied, redraw smith chart
	if ~ishold
		nd = drawsc(ax, p.Results.Scheme);
	end

	num_real = 100;
	num_imag = 100;

	% Generate a grid over the region covered by gamma
	re_gamma = real(gamma);
	im_gamma = imag(gamma);
	[R, I] = meshgrid(linspace(min(re_gamma), max(re_gamma), num_real ), linspace( min(im_gamma), max(im_gamma), num_imag ));
	
	% Interpolate the data in 'val' over the new grid
	V = griddata(re_gamma, im_gamma, val, R, I);

	surf(R, I, V);

	daspect([1, 1, max(val)]);
	
end