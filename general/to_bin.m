function str = to_bin(d,numBits, M)
	%TO_BIN Convert decimal integer to its binary representation
	%   DEC2BIN(D) returns the binary representation of D as a character
	%   vector. D must be an integer.
	%
	%   DEC2BIN(D,numBits) produces a binary representation with at least
	%   numBits bits. Set to -1 for automatic (default).
	%
	%	DEC2BIN(..., M) places decimals after every M letters.
	%
	%   Example
	%      dec2bin(23) returns '10111'
	%
	%   See also BIN2DEC, DEC2HEX, DEC2BASE, FLINTMAX.
	
	if exist('numBits', 'var') && (numBits > 0)
		str = dec2bin(d, numBits);
	else
		str = dec2bin(d);
	end
	
	
	if exist('M', 'var')
		
		% Loop over output string
		idx = M;
		while (idx < length(str))
			
			% Add decimal
% 			str = [str(1:M) , '.' , str(M+1:end)];
			str = [str(1:end-idx) , '.' , str(end-idx+1:end)];
			
			% Move idx
			idx = idx + 1 + M;
		end
	end


end