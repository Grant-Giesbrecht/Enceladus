function c = dBsum(a, b, L12, L2)
% DBSUM Calculates the sum of two decibel values
%
%	DBSUM(A, B) Calculates the sum of the two values, A and B, represented
%	in decibels. Assumes A and B are base-20 dB, and returns the result in
%	base-20 dB.
%
%	DBSUM(A, B, L) L Sets whether A, B, and the result are base-10 or
%	base-20 log. Set L = 10 for base-10 log.
%
%	DBSUM(A, B, L1, L2) Set the log base of A and B individually; L1 sets
%	the base for A and the result, L2 sets the base for B.
%
%	See also DB2LIN, LIN2DB

	% Check for optional variables
	if ~exist('L12', 'var')
		L12 = 20;
	end
	if ~exist('L2', 'var')
		L2 = L12;
	end
	
	% Convert decibels to linear
	A = dB2lin(a, L12);
	B = dB2lin(b, L2);
	
	% Sum
	c = lin2dB(A+B, L12);

end