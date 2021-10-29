function [h, polyi, iarea] = vennsc(contour_list, varargin)
% VENNSC 
%

	% Return if no data provided
	if isempty(contour_list)
		return;
	end

	expectedSchemes = {'Light', 'Dark'};

	p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('ContourLabel', "Z", @(x) isstring(x) || ischar(x) );
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
	p.addParameter('Color', [0, 0, .8], @isnumeric );
	p.parse(varargin{:});

	num_real = 100;
	num_imag = 100;

	% Scan over each contour...
	plot_contours = [];
	for c = contour_list
		
		% Verify contour is not empty
		if isempty(c.values)
			continue
		end
		
		% Plot contour
		[h, cont_data] = contoursc(c.gamma, c.values, 'ContourLabel', c.labelstr, 'ContourLevels', c.venn_min, 'Color', c.color);
		
		% Save all contours (to find overlap later)
		plot_contours = [plot_contours, cont_data];
		
	end

	
	
	x1 = real(plot_contours(1).gamma);
	y1 = imag(plot_contours(1).gamma);
	p1 = polyshape(x1, y1);
	x2 = real(plot_contours(2).gamma);
	y2 = imag(plot_contours(2).gamma);
	p2 = polyshape(x2, y2);
	
% 	plot(p1);
% 	plot(p2);
	polyi = intersect(p1, p2);
	h = plot(polyi, 'EdgeColor', 'none');
	
	iarea = area(polyi);
	
end