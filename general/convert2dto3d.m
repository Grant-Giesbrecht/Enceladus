function [X,Y,Z]=convert2dto3d(xs, ys, zs)
	
	uxs = unique(xs);
	uys = unique(ys);
	
	% Make Xs and Ys
	[X,Y] = meshgrid(uxs, uys);
	
	%========= Filter Zs ==========
	
	Z = ones(numel(uys), numel(uxs));
	
	% Scan over X values
	xidx = 0;
	for xv = uxs
		xidx = xidx + 1;
		
		% Scan over Y values
		yidx = 0;
		for yv = uys
			yidx = yidx + 1;
			
			% Find index
			idx = (xs == xv) & (ys == yv);
			
			Z(yidx, xidx) = zs(idx);
		end
	end
end