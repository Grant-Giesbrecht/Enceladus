function force0y()
% FORCE0Y Forces the y limits so that Y=0 appears in the plot.

	yl = ylim;
	if yl(1) > 0
		yl(1) = 0;
	end
	if yl(2) < 0
		yl(2) = 0;
	end
	ylim(yl);
end