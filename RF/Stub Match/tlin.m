function abcd = tlin(Z0, theta)
% TLIN Create the ABCD matrix for a transmission line of length theta
% radians.


	abcd = [cos(theta), sqrt(-1)*Z0*sin(theta);...
			sqrt(-1)/Z0*sin(theta), cos(theta)];

end