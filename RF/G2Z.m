function ZL=G2Z(G, Z0)

	if ~exist('Z0', 'var')
		Z0 = 50;
	end

	ZL = Z0.*(1 + G)./(1 - G);
end