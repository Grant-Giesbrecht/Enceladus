function scatterbound(x, y, numpt, order, varargin)

	p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter("ShowDetail", false, @islogical);
	p.addParameter('Ax', gca, @(x) isa(x, 'matlab.graphics.axis.Axes') || isa(x, 'matlab.graphics.GraphicsPlaceholder'));

    p.parse(varargin{:});
	ax = p.Results.Ax;
	
    % Get plot arguments
    tmp = [fieldnames(p.Unmatched),struct2cell(p.Unmatched)];
    plotArgs = reshape(tmp',[],1)'; 

	showDetail = false;

	xo = [];
	yo = [];
	
	nth = 1;
	
	steps = linspace(min(x), max(x), numpt);
	
	% Show step lines
	if showDetail
		for s = steps
			vlin(s, 'LineStyle', '--', 'Color', [.3, .3, .3]);
		end
	end
	
	% Compute an x tolerance
	tol = (steps(2)-steps(1))*.15;
	
	% At each step..
	for s = steps
		
		% Find indeces with x in bounds of the step
		% Returns all Y in array y_inbound that are in the x bound
		idx = (x >= s-tol) & (x <= s+tol);
		y_inbound = y(idx);
		x_inbound = x(idx);
		
		% Skip point is empty
		if isempty(y_inbound)
			continue;
		end
		
		% Sort in ascending order by Y
		[y_inbound, si] = sort(y_inbound);
		x_inbound = x_inbound(:, si);
		
		% Find value
		if numel(y_inbound) >= nth
			yv = y_inbound(end-nth+1);
			xv = x_inbound(end-nth+1);
		else
			yv = y_inbound(1);
			xv = x_inbound(1);
		end
		
		% Add to fit points
		yo = addTo(yo, yv);
		xo = addTo(xo, xv);
		
	end
	
	% Show fit points
	if showDetail
		scatter(ax, xo, yo, 'Marker', '*', 'MarkerFaceColor', [.8, 0, 0], 'MarkerEdgeColor', [.8, 0, 0]);
	end
	
	% Get fit parameters
	fit = polyfit(xo, yo, order);
	
	% Draw fit line
	plot(ax, xo, polyval(fit, xo), plotArgs{:});
	
end
