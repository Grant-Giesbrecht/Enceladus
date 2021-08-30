function db = lin2dB(x, mult)
% LIN2DB Takes a linear value and converts it to decibels.
%
%	LIN2DB(X) Calculates X in dB
%
%	LIN2DB(X, MULT) Calculates the decibel value of the linear value X.
%	MULT sets the type of log calculated (log 20 vs. log 10). MULT is
%	expected to be either the numeric value 10 or 20.
%
%	See also DB2LIN

	if ~exist('mult', 'var')
		mult = 20;
	end

	db = mult.*log10(x);

end