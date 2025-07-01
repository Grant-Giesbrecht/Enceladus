function Zin=xfmr2zin(Z0, Z_l, beta_L)
%XFMR2ZIN Calculates the input impedance of a single-section transformer.
%
%	ZIN = XFMR2ZIN(Z0, Z_L, BETA_L) Calculates the input impedance of a
%	single section transformer of electrical length BETA_L, characteristic
%	impedance Z0, and terminated in a load of Z_L. BETA_L is in radians.
%
%	See also ZIN2XFMR, REFL.

	%Equation from Pozar
	i = sqrt(-1);
	Zin = Z0 .* ( Z_l + i.*Z0.*tan(beta_L) )./( Z0 + i.*Z_l.*tan(beta_L) );

end