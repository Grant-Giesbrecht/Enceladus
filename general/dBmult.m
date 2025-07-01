function c = dBmult(a, mult, L)
% DBMULT Calcaultes the product of a coefficient with a decibel value
%
%	DBMULT(A, MULT) Multiplies the decibel value, A, by the coefficient
%	MULT. Returns the result as a decibel. Both A and the result are
%	assumed to be base-20 decibels.
%
%	DBMULT(A, MULT, L) Sets whether A and the result are base-10 or base-20
%	decibels. Set L=10 for base-10 decibels. 
%
%	See also DBSUM, DB2LIN, LIN2DB
%
	% Check for optional variables
	if ~exist('L', 'var')
		L = 20;
	end
	
	% Convert decibels to linear
	A = dB2lin(a, L);
	
	% Take product
	c = lin2dB(A*mult, L);

end