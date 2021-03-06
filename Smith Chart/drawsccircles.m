function ndrawn = drawsccircles(fill, scheme)

	dark_colors = false;

	if ~exist('fill', 'var')
		fill = false;
	end

	ndrawn = 0;

	% Define line styles
	ls_Rcirc = '-';
	ls_Cline = '-';
	ls_Xcirc = '-';
	
	% Define inner curve locations
	Z_Rcirc = [.2, .5, 1, 2, 5, 30];
	Z_Xcirc = [.2, .5, 1, 2, 5, 30];
	
	% Change to alternative colors
	if strcmp(scheme, 'Dark')
		circ_fill_color = [.3176, .3608, .4196]; %Window title bar grey
		circ_fill_color = [100, 100, 100]./255; %Window title bar grey
		col_Rcirc = [1, .6706, .2431]; % Orange
		col_Cline = col_Rcirc;
		col_Xcirc = col_Rcirc;
		col_Outcirc = col_Rcirc;
	else
		col_Xcirc = [.5, .5, .7];
		col_Cline = [.5, .5, .5];
		col_Rcirc = [.5, .5, .5];
		circ_fill_color = [1,1,1]; %White background
		col_Outcirc = [0, 0, 0];
	end
	
	% Draw outer circle
	drawcirc(0, 0, 1, 'Color', col_Outcirc, 'LineStyle', '-');
	ndrawn = ndrawn + 1;
	
	% Fill outer circle
	if fill
		fillcirc(0, 0, 1, circ_fill_color);
	end
	
	% Draw impedance circles
	G_Rcirc = Z2G(Z_Rcirc, 1);
	for G = G_Rcirc		
		drawcirc((G+1)/2, 0, (1-G)/2, 'Color', col_Rcirc, 'LineStyle', ls_Rcirc);
		ndrawn = ndrawn + 1;
	end
	
	% Draw center line
	h = line([-1, 1], [0, 0], 'Color', col_Cline, 'LineStyle', ls_Cline);
	set( get( get( h, 'Annotation'), 'LegendInformation' ), 'IconDisplayStyle', 'off' );
	ndrawn = ndrawn + 1;
	
	% Draw reactance circles
	radius = 1./Z_Xcirc;
	for r = radius
		
		% Get inner circle bounds
		inner_bounds = [0, 0, 0]; %X, Y, R
		if r > 4
			G = Z2G(1, 1);
			inner_bounds = [(G+1)/2, 0, (1-G)/2];
		elseif r > 1.5
			G = Z2G(2, 1);
			inner_bounds = [(G+1)/2, 0, (1-G)/2];
		elseif r > .25
			G = Z2G(5, 1);
			inner_bounds = [(G+1)/2, 0, (1-G)/2];
		end
		
		drawcircenc(1, r, r, 'Color', col_Rcirc, 'LineStyle', ls_Rcirc, 'Mirror', true, 'InnerBounds', inner_bounds);
		ndrawn = ndrawn + 1;
	end
	
end