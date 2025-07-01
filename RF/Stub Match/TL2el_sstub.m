function el = TL2el_sstub(Btl1, Z0_2)

	el = 1./2./pi.*atan(1./Z0_2./Btl1);
	
	for i = 1:numel(el)
		if el(i) < 0
			el(i) = el(i) + .5;
		end
	end
	

end