function t = t_TL1_general(RL, XL, Z1, Z0)

	Y0 = 1/Z0;
	g = real(Y0);
	b = imag(Y0);

	if RL == g*Z1^2
		t = (g*XL^2 + g^3*Z1^4-g*Z1^2)/(-2*g*XL*Z1);
	else
% 		t_den = Z0*RL/Z1 - g*Z0*Z1;
% 		t_n1 = Z0*g*XL;
% 		t_n2 = sqrt( RL^3*( g*Z0^2/Z1^2 ) + RL^2*(-g^2*Z0^2-Z0^2/Z1^2) + RL*(g*Z0^2+g*XL^2*Z0^2/Z1^2) );
		
		t_den = RL/Z1 - g*Z1;
		t_n1 = g*XL;
		t_n2 = sqrt( RL^3*( g/Z1^2 ) + RL^2*(-g^2-1/Z1^2) + RL*(g+g*XL^2/Z1^2) );
		
		t = [(t_n1+t_n2)/t_den, (t_n1-t_n2)/t_den];
		
	end

	
% 	if RL == Z1^2/Z0
% 		t = (-XL.^2 - Z1.^4./Z0.^2 + Z1.^2)./(2.*XL.*Z1);
% 	else
% 		t_den = (Z0.*RL./Z1 - Z1);
% 		t_n1 = XL./t_den;
% 		t_n2 = sqrt(RL.*(Z0+XL.^2.*Z0./Z1.^2) - RL.^2.*(1+Z0.^2./Z1.^2) + RL.^3.*(Z0./Z1.^2))./t_den;
% 		
% 		t = [t_n1+t_n2, t_n1-t_n2];
% 		
% 	end

end