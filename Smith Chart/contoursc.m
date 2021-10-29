function [h, contours_out] = contoursc(gamma, val, varargin)
% CONTOURSC Plot smith chart contours
%

	% Return if no data provided
	if isempty(gamma)
		return;
	end

	expectedSchemes = {'Light', 'Dark'};

	p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('ContourLabel', "Z", @(x) isstring(x) || ischar(x) );
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
	p.addParameter('Color', [0, 0, .8], @isnumeric );
	p.addParameter('ContourLevels', [], @isnumeric);
	p.parse(varargin{:});

	num_real = 100;
	num_imag = 100;

	contour_color = p.Results.Color;
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
	if isempty(p.Results.ContourLevels)
		CM = contourc(re_vec, im_vec, V);
	elseif numel(p.Results.ContourLevels) == 1
		CM = contourc(re_vec, im_vec, V, [p.Results.ContourLevels, p.Results.ContourLevels]);
	else
		CM = contourc(re_vec, im_vec, V, p.Results.ContourLevels);
	end
	sa = cm2struct(CM);
	
	% Sometimes contourc will give multiple contours when 1 was requested.
	% This removes the extra contours
	if numel(p.Results.ContourLevels) == 1 && numel(sa) ~= 1
		sa = sa(1);
	end
	
	contours_out = [];
	
	% Plot each contour
	count = 1;
	for arr = sa
		
		% Create gamma points from struct 'arr'
		g = arr.x + arr.y.*sqrt(-1);
		
		h = plotsc(g, 'Color', contour_color, 'Marker', 'None', 'LineStyle', '-', 'ContourValue', arr.level, 'ContourLabel', p.Results.ContourLabel, 'Scheme', p.Results.Scheme);
		
		% Turn off legend indexing for all but last contour
		if count ~= length(sa)
% 			h = line([-1, 1], [0, 0], 'Color', col_Cline, 'LineStyle', ls_Cline);
			set( get( get( h, 'Annotation'), 'LegendInformation' ), 'IconDisplayStyle', 'off' );
		end
		
		new_cont = {};
		new_cont.value = arr.level;
		new_cont.gamma = g;
		contours_out = [contours_out, new_cont];
		
		count = count + 1;
	end
	
	if ~isempty(p.Results.ContourLabel)
		zlabel(p.Results.ContourLabel)
	end
	
end