function db = lin2dB(x)
% LIN2DB Takes a linear value and converts it to decibels.
%
%	LIN2DB(X) Calculates X in dB
%
%	See also DB2LIN

	db = 20.*log10(x);

end