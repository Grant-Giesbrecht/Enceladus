function force0z()
% FORCE0Y Forces the y limits so that Y=0 appears in the plot.

	zl = zlim;
	if zl(1) > 0
		zl(1) = 0;
	end
	if zl(2) < 0
		zl(2) = 0;
	end
	zlim(zl);
end