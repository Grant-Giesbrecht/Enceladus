function t = t_TL1pozar(RL, XL, Z0)

	t(1)  = (XL + sqrt(RL./Z0.*((Z0-RL).^2 + XL.^2 ) ))./(RL-Z0);
	t(2)  = (XL - sqrt(RL./Z0.*((Z0-RL).^2 + XL.^2 ) ))./(RL-Z0);

end