function S=psplit(R1, R2)

	if ~ exist('R2', 'var')
		R2 = .5;
	end
	
	S = [0,0,0];
	
	S(1) = lin2dB(R1, 10);
	
	rem = 1-R1;
	p2 = rem*R2;
	p3 = rem*(1-R2);
	
	S(2) = lin2dB(p2, 10);
	S(3) = lin2dB(p3, 10);

end