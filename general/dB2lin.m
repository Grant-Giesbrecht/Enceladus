function l = dB2lin(x, mult)
% DB2LIN Takes a linear value and converts it to decibels.
%
%	DB2LIN(X) Calculates the linear value for the decibel value X.
%
%	DB2LIN(X, MULT) Calculates the linear value for the decibel value X,
%	and MULT sets the type of log calculated (log 20 vs. log 10). MULT is
%	expected to be either the numeric value 10 or 20.
%
%	See also LIN2DB

	if ~exist('mult', 'var')
		mult = 20;
	end

	l = 10.^(x./mult);

end