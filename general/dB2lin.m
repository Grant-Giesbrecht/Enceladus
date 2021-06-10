function l = dB2lin(x)
% DB2LIN Takes a linear value and converts it to decibels.
%
%	DB2LIN(X) Calculates the linear value for the decibel value X.
%
%	See also LIN2DB

	l = 10.^(x./20);

end