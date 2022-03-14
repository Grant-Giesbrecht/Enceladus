function t = t_TL1(RL, XL, Z1, Z0)

	if RL == Z1^2/Z0
		t = (-XL.^2 - Z1.^4./Z0.^2 + Z1.^2)./(2.*XL.*Z1);
	else
		t_den = (Z0.*RL./Z1 - Z1);
		t_n1 = XL./t_den;
		t_n2 = sqrt(RL.*(Z0+XL.^2.*Z0./Z1.^2) - RL.^2.*(1+Z0.^2./Z1.^2) + RL.^3.*(Z0./Z1.^2))./t_den;
		
		t = [t_n1+t_n2, t_n1-t_n2];
		
	end

end