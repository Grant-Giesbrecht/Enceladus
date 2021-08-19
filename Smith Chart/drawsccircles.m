function drawsccircles()

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
	
	% Draw impedance circles
	G_Rcirc = Z2G(Z_Rcirc, 1);
	for G = G_Rcirc		
		drawcirc((G+1)/2, 0, (1-G)/2, 'Color', col_Rcirc, 'LineStyle', ls_Rcirc);
	end
	
	% Draw center line
	line([-1, 1], [0, 0], 'Color', col_Cline, 'LineStyle', ls_Cline)
	
	% Draw reactance circles
% 	G_Xcirc = Z2G(Z_Xcirc, 1);
	radius = 1./Z_Xcirc./2;
	for r = radius
		drawcirc(1, r, r, 'Color', col_Rcirc, 'LineStyle', ls_Rcirc);
% 		drawcirc_encl(1, (G-1)/2, (1-G)/2, 'Color', col_Xcirc, 'LineStyle', ls_Xcirc);
% 		drawcirc_encl(1, -1*(G-1)/2, (1-G)/2, 'Color', col_Xcirc, 'LineStyle', ls_Xcirc);
	end
	

end