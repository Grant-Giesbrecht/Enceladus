function [h, contours_out] = xcontoursc(lp, val_name, varargin)
% CONTOURSC Plot smith chart contours
%

	ih = ishold;

	% Return if no data provided
	if isempty(lp.gamma())
		return;
	end

	expectedSchemes = {'Light', 'Dark'};

	p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('ContourLabel', "", @(x) isstring(x) || ischar(x) );
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
	p.addParameter('Color', [0, 0, .8], @isnumeric );
	p.addParameter('ContourLevels', [], @isnumeric);
	p.parse(varargin{:});
	
	% Get plot arguments
    tmp = [fieldnames(p.Unmatched),struct2cell(p.Unmatched)];
    plotArgs = reshape(tmp',[],1)'; 

	num_real = 100;
	num_imag = 100;

	contour_color = p.Results.Color;
% 	contour_color = [.8, 0, 0];
% 	contour_color = [.6667, .0157, .9765];
% 	contour_color = [.6667, .4157, .9765];
% 	contour_color = [.7667, .5157, .9765];

	contour_levels = p.Results.ContourLevels;
	if isempty(contour_levels)
		contour_levels = 5:5:95;
	end
	
% 	% Remove duplicate points (will cause a warning to be printed and would
% 	% take the average by default). Keep the point with the maximum value
% 	rdupls = getMultiples(re_gamma);
% 	idupls = getMultiples(im_gamma);

	% Split into subcontours for each drive condition
	lp_list = lp.getAllDriveLPs();
	
	% Create struct to contain all contours of ea. drive condition, sorted
	% by level
	conts_by_level = {};
	for cl = contour_levels
		valstr = strrep(string(cl), ".", "x");
		conts_by_level.("VAL"+valstr) = {};
	end
	
	for lpidx = 1:numel(lp_list) %NOTE: Can change this to parfor to parallel computing
		
		% Get load pull object from list
		lpi = lp_list(lpidx);

		if lpi.numpoints() < 3
			continue;
		end
		
		% Get gamma points
		gamma = lpi.gamma();
		
		% Generate a grid over the region covered by gamma
		re_gamma = real(gamma);
		im_gamma = imag(gamma);
		[R, I] = meshgrid(linspace(min(re_gamma), max(re_gamma), num_real ), linspace( min(im_gamma), max(im_gamma), num_imag ));
		
		% Get values
		val = lpi.getArrayFromName(val_name);
	
		% Remove points that are NaN
		nan_idxs = isnan(val);
		re_gamma(nan_idxs) = [];
		im_gamma(nan_idxs) = [];
		val(nan_idxs) = [];
		
		% Interpolate the data in 'val' over the new grid
		V = griddata(re_gamma, im_gamma, val, R, I);

		% Get correct vector shapes for 'contourc'
		re_vec = R(1,:);
		im_vec = I(:,1);

		% Calculate contours
		if numel(contour_levels) == 1
			CM = contourc(re_vec, im_vec, V, [contour_levels, contour_levels]);
		else
			CM = contourc(re_vec, im_vec, V, contour_levels);
		end
		sa = cm2struct(CM);
		
		% Sometimes contourc will give multiple contours when 1 was requested.
		% This removes the extra contours
		if numel(p.Results.ContourLevels) == 1 && numel(sa) > 1
			sa = sa(1);
		elseif numel(p.Results.ContourLevels) == 1 && isempty(sa)
			sa = [];
		end

		sa_len = numel(sa);
		
		% Process each contour
% 		for arr = sa
		for sa_idx = 1:sa_len

			arr = sa(sa_idx);
			
			% Create gamma points from struct 'arr'
			g = arr.x + arr.y.*sqrt(-1);

			% Save gamma points 
			valstr = strrep(string(arr.level), ".", "x");
			conts_by_level.("VAL"+valstr){lpidx} = g;
			
		end
	end
		
	% For each level, merge contours
	master_contours = polyshape([1,2,3,4], [1,2,3,4]);
	master_contours(1) = [];
	master_levels = [];
	master_holeType = []; 
	for level = contour_levels
		
		shape_union = [];
		
		% Loop over every bias/drive condition at this level
		valstr = strrep(string(level), ".", "x");
		for cstruct = conts_by_level.("VAL"+valstr)
			
			% Get data out of cell
			cont_data = cstruct{:};
			
			% Skip empty cells (ie. bias combos which did not produce
			% contours at this level)
			if isempty(cont_data) || numel(cont_data) < 4
				continue;
			end
			
			xs = real(cont_data);
			ys = imag(cont_data);
			
			if collinear([xs',ys'], 1e-14)
				continue;
			end

			if any(isnan(xs)) || any(isnan(ys))
				displ("");
			end
			
			% Create new shape
			newshape = simplify(polyshape(xs, ys, 'KeepCollinearPoints', true), 'KeepCollinearPoints', false);
			
			if any(isnan(newshape.Vertices(:,1))) || any(isnan(newshape.Vertices(:, 2)))
				displ("");
			end
			
			% Union new shape with master
			if ~isempty(shape_union)
				
				if any(isnan(newshape.Vertices(:,1))) || any(isnan(newshape.Vertices(:, 2))) || any(isnan(shape_union.Vertices(:,1))) || any(isnan(shape_union.Vertices(:, 2)))
					displ("");
				end
				
				shape_union_last = shape_union;
				
				shape_union = union(shape_union, newshape);
				
				if any(isnan(newshape.Vertices(:,1))) || any(isnan(newshape.Vertices(:, 2))) || any(isnan(shape_union.Vertices(:,1))) || any(isnan(shape_union.Vertices(:, 2)))
					displ("");
				end
			else
				shape_union = newshape;
			end
			
		end
		
		% Save shape if shape exists
		if ~isempty(shape_union)
			
			% For each region in union shape...
			regs = regions(shape_union);
			pits = holes(shape_union);
			for nsi = 1:numel(regs)
				master_levels(end+1) = level; % Add to master level
				master_contours(end+1) = simplify(rmholes(regs(nsi)), 'KeepCollinearPoints', false); % Add to master shapes and remove holes
				master_holeType(end+1) = false; % Specify as region
			end
			
			for psi = 1:numel(pits)
				master_levels(end+1) = level; % Add to master 
				master_contours(end+1) = simplify(pits(psi), 'KeepCollinearPoints', false); % Add to master shapes
				master_holeType(end+1) = true; % Specify as hole
			end
			
		end
			
		
	end
	
	% Draw contours
	contours_out = [];
	count = 0;
	for c = master_contours
		
		% Increment count
		count = count + 1;
		
		% Calculate gamma from X & Y
		g = c.Vertices(:,1)' + sqrt(-1) .* c.Vertices(:,2)';
		
		% Remove any NaN
		if any(isnan(g))
			displ();
		end
		
% 		h = plot(c, 'EdgeColor', 'none');
		try
			ph = plotsc(g, 'Color', contour_color, 'Marker', 'None', 'LineStyle', '-', 'ContourValue', arr.level, 'ContourLabel', p.Results.ContourLabel, 'Scheme', p.Results.Scheme);
		catch
			displ("Oops!");
		end
		
% 		% Turn off legend indexing for all but last contour
% 		if count ~= length(sa)
% 			set( get( get( ph, 'Annotation'), 'LegendInformation' ), 'IconDisplayStyle', 'off' );
% 		end
		
		new_cont = {};
		new_cont.value = master_levels(count);		
		new_cont.gamma = g;
		contours_out = [contours_out, new_cont];
		
		hold on;
		
		h = ph;
	end
	
	
	
	
end