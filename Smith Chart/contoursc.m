function contoursc(gamma, val, varargin)
% CONTOURSC Plot smith chart contours
%

	expectedSchemes = {'Light', 'Dark'};

	p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('ContourLabel', "Z", @(x) isstring(x) || ischar(x) );
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
	p.parse(varargin{:});

	num_real = 100;
	num_imag = 100;

	contour_color = [0, 0, .8];
% 	contour_color = [.8, 0, 0];
% 	contour_color = [.6667, .0157, .9765];
% 	contour_color = [.6667, .4157, .9765];
% 	contour_color = [.7667, .5157, .9765];

	% Generate a grid over the region covered by gamma
	re_gamma = real(gamma);
	im_gamma = imag(gamma);
	[R, I] = meshgrid(linspace(min(re_gamma), max(re_gamma), num_real ), linspace( min(im_gamma), max(im_gamma), num_imag ));
	
	% Interpolate the data in 'val' over the new grid
	V = griddata(re_gamma, im_gamma, val, R, I);
	
	% Get correct vector shapes for 'contourc'
	re_vec = R(1,:);
	im_vec = I(:,1);
	
	% Calculate contours
	CM = contourc(re_vec, im_vec, V);
	sa = cm2struct(CM);
	
	% Plot each contour
	for arr = sa
		
		% Create gamma points from struct 'arr'
		g = arr.x + arr.y.*sqrt(-1);
		
		plotsc(g, 'Color', contour_color, 'Marker', 'None', 'LineStyle', '-', 'ContourValue', arr.level, 'ContourLabel', p.Results.ContourLabel, 'Scheme', p.Results.Scheme);
% 		hold on
	end
	
	if ~isempty(p.Results.ContourLabel)
		zlabel(p.Results.ContourLabel)
	end
	
end