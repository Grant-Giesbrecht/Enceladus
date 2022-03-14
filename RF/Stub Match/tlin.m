function abcd = tlin(Z0, theta)

	abcd = [cos(theta), sqrt(-1)*Z0*sin(theta);...
			sqrt(-1)/Z0*sin(theta), cos(theta)];

end