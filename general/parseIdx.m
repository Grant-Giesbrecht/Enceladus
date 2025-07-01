function words=parseIdx(input, delims, varargin)

	protect_strings = false;
	
	if nargin > 2
		if varargin{1}
			protect_strings = true;
		end
	end

	if protect_strings
		words = parseIdxPSCont(input, delims, [], 0);
	else
		words = parseIdxCont(input, delims, [], 0);
	end
end