function Z0=zin2xfmr(Zin, Z_l, beta_L)
%ZIN2XFMR Returns the characteristic impedance of a transmission line of a
%specific electrical length that has a specified load and input impedance.
%
%	Z0 = ZIN2XFMR(ZIN, Z_L, BETA_L) Calculates the impedance of a
%	transmission line of length BETA_L that displays an input impedance of
%	ZIN when terminated in a load of Z_L.
%
%	See also XFMR2ZIN, REFL.

	%Equation from: https://www.wolframalpha.com/input/?i=a%3Dz*%28r%2Bi*z*b%29%2F%28z%2Br*i*b%29+solve+for+z
	Z0 = sqrt( -Zin.^2 + 4.*Zin.*tan(beta_L).^2.*Z_l + 2.*Zin.*Z_l - Z_l.^2 )./(2.*tan(beta_L));
end