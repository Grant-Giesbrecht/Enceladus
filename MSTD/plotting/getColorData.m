function c = getColorData(v, cmap)

	[N, c] = size(cmap);
	
	x1 = max(v);
	x0 = min(v);
	
	m = (N-1)/(x1-x0);
	b = 1;
	
	y = round(m.*(v-x0) + b);
	
	c=[];
	for idx = y
		c = [c;cmap(idx, :)];
	end
	
% 	f = N.*(v - min() + 1)./();

end