function [h, polyi, iarea] = vennsc_internal(x1, y1, x2, y2)
% VENNSC 
%
	
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

% 	p1 = polyshape(x1, y1);
% 	p2 = polyshape(x2, y2);
	
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

	h = [];
	
end