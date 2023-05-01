function abcd = tlind(Z0, thetad)
% TLIN Create the ABCD matrix for a transmission line of length theta
% radians.

	warning("This function is deprecated in favor of microsim's tlin()");

	abcd = tlin(Z0, thetad*pi/180);
end
