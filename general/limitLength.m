function s=limitLength(str, len)
%LIMITLENGTH Limits the length of a string by replacing the middle with
%elipses.
%
%	LIMITLENGTH(STR, LEN) = Limits the length of the string STR to LEN and
%	replaces the removed middle characters with elipses.

	str = char(str);

	if length(str) > len
		
		ax = len/2-2;
		bx = length(str) - (len - len/2 - 2);
		a = str(1:ax);
		b = str(bx:end);
		
		s = string([a, '...', b]);
	else
		s = string(str);
	end
	
end


