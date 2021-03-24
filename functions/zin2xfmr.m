function Z0=zin2xfmr(Zin, Z_l, beta_L)
	%Equation from: https://www.wolframalpha.com/input/?i=a%3Dz*%28r%2Bi*z*b%29%2F%28z%2Br*i*b%29+solve+for+z
	Z0 = sqrt( -Zin.^2 + 4.*Zin.*tan(beta_L).^2.*Z_l + 2.*Zin.*Z_l - Z_l.^2 )./(2.*tan(beta_L));
end