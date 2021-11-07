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
	p.addParameter('HidePlots', false, @islogical );
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
		try
			[h, cont_data] = contoursc(c.gamma, c.values, 'ContourLabel', c.labelstr, 'ContourLevels', c.venn_min, 'Color', c.color);
		catch
			iarea = 0;
			polyi = [];
			h = [];
			return;
		end
		% Save all contours (to find overlap later)
		plot_contours = [plot_contours, cont_data];
		
	end

	
	
	x1 = real(plot_contours(1).gamma);
	y1 = imag(plot_contours(1).gamma);
	x2 = real(plot_contours(2).gamma);
	y2 = imag(plot_contours(2).gamma);
	
	% Abort if less than three points exist
	if numel(x1) < 3 || numel(y1) < 3 || numel(x2) < 3 || numel(y2) < 3
		iarea = 0;
		polyi = [];
		h = [];
		return;
	end
	
	% Abort if 1 or more polygons are just a line
	if  collinear([x1',y1'], 1e-14) ||  collinear([x2',y2'], 1e-14)
		iarea = 0;
		polyi = [];
		h = [];
		return;
	end
	
	lastwarn('') % Clear last warning message
	
	%NOTE: simplify and the KeepCollinearPoints specifications are
	%selected such that collinear points are ulitmately eliminated, but
	%without triggering the warning that appears by default
	p1 = simplify(polyshape(x1, y1, 'KeepCollinearPoints', true), 'KeepCollinearPoints', false);
	p2 = simplify(polyshape(x2, y2, 'KeepCollinearPoints', true), 'KeepCollinearPoints', false);
	
	
    [warnMsg, ~] = lastwarn;
    if ~isempty(warnMsg)
        p1 = simplify(polyshape(x1, y1, 'KeepCollinearPoints', true), 'KeepCollinearPoints', false);
		p2 = simplify(polyshape(x2, y2, 'KeepCollinearPoints', true), 'KeepCollinearPoints', false);
    end
	
% 	plot(p1);
% 	plot(p2);
	polyi = intersect(p1, p2);
	try
		if ~p.Results.HidePlots
			h = plot(polyi, 'EdgeColor', 'none');
		end
	catch
	end
		
	iarea = area(polyi);
	
end