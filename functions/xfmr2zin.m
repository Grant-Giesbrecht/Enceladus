function Zin=xfmr2zin(Z0, Z_l, beta_L)
	%Equation from Pozar
	i = sqrt(-1);
	Zin = Z0 .* ( Z_l + i.*Z0.*tan(beta_L) )./( Z0 + i.*Z_l.*tan(beta_L) );

end