function [solns, BW_list, f] = stubmatch(ZS, ZL, N, varargin)
	
	
	
	% Verify, if given as string, convert to number
	if ~isnumeric(ZS)
		ZS = str2num(ZS);
	end
	if ~isnumeric(ZL)
		ZL = str2num(ZL);
	end
	if ~isnumeric(ZL)
		ZL = str2num(ZL);
	end
	if ~isnumeric(N)
		N = str2num(N);
	end
	
	
	try
		[solns, BW_list, f] = stubmatch_internal(ZS, ZL, N, varargin{:});
	catch
		[solns, BW_list, f] = stubmatch_internal(ZL, ZS, N, varargin{:});
		warning("Flip inputs");
	end
	
end