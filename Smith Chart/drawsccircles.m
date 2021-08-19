function ndrawn = drawsccircles(fill)

	if ~exist('fill', 'var')
		fill = false;
	end

	ndrawn = 0;

	circ_fill_color = [1,1,1];
	
	col_Rcirc = [.5, .5, .5];
	ls_Rcirc = '-';
	
	col_Cline = [.5, .5, .5];
	ls_Cline = '-';
	
	col_Xcirc = [.5, .5, .7];
	ls_Xcirc = '-';
	
	Z_Rcirc = [.2, .5, 1, 2, 5, 30];
	
	Z_Xcirc = [.2, .5, 1, 2, 5, 30];
	
	% Draw outer circle
	drawcirc(0, 0, 1, 'Color', [0, 0, 0], 'LineStyle', '-');
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