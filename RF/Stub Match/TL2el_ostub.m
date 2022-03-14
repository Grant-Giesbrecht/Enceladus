function el = TL2el_ostub(Btl1, Z0_2, Bsrc)

	el = -1./2./pi.*atan(Btl1.*Z0_2);

	for i = 1:numel(el)
		if el(i) < 0
			el(i) = el(i) + .5;
		end
	end
	
end