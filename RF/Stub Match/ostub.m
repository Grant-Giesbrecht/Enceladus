function abcd = ostub(Z0, theta)

	Y0 = sqrt(-1)/Z0*tan(theta);

	abcd = [1, 0;Y0, 1];

end