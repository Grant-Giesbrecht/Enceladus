function  smithcontour(rg, ig, val, Z0)
	
	%Check for optional Z0
	if ~exist('Z0', 'var')
		Z0 = 50;
	end

% 	zl = refl2zl(g, Z0);
	re = rg; %real(zl);
	im = ig; %imag(zl);
	
	% If meshgrid, convert
	[rr,cr] = size(re);
	[ri, ci] = size(im);
	if rr ~= 1 && ri ~= 1
		re = re(1,:);
		im = im(:,1);
	end

	% Calculate contours
	CM = contourc(re, im, val);
	sa = cm2struct(CM);
	
	hold on
	
	% Plot each contour
	for arr = sa
		
		g = arr.x + arr.y.*sqrt(-1);
		
		% Convert real, imag data to reflection coefficient
% 		g = (z - Z0)./(z + Z0);
		
		hold on
		smithplot(g, 'Color', [0, 0, .8], 'Marker', 'none', 'LineStyle', '-');
	end
	
	
end