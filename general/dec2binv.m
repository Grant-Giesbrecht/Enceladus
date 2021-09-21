function bv = dec2binv(varargin)

	% Get binary value (as string)
	bin_char = dec2bin(varargin{:});
	
	bv = double( bin_char == '1');
	
	bv = fliplr(bv);

end