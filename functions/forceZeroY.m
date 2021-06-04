function forceZeroY()
	yl = ylim;
	if yl(1) > 0
		yl(1) = 0;
	end
	if yl(2) < 0
		yl(2) = 0;
	end
	ylim(yl);
end