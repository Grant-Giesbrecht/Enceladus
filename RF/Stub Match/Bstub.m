function B = Bstub(RL, XL, Z1, t)
	
	B = (RL.^2.*t - (Z1-XL.*t).*(XL+Z1.*t))./(Z1.*(RL.^2 + (XL + Z1.*t).^2));

% 	B = fliplr(B);
	
end