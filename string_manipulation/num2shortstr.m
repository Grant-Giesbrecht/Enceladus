function s = num2shortstr(v, varargin)

	% TODO: sprintf isn't good enough. Look at .002 for example. It pads
	% the exponent with '-04' instead of just -4 and will pad the leading
	% number with extra zeros. So scientific format for .003 gave
	% "3.00e-04" which is absurd when "3e-4" works just as well. Result is
	% 'g' formatting wont print as 'engineering' values (ie. 2.3 prints as
	% '2.3' and -.1 prints as '100e-3' or likewise. This needs to be fixed!


	p = inputParser;
	p.addParameter('Zeropoint', 1e-6, @isnumeric);
	p.addParameter('imagchar', 'i', @(x) isstring(x) || ischar(x));
	p.addParameter('junctionchar', '+', @(x) isstring(x) || ischar(x));
	p.addParameter('junctioncharneg', '-', @(x) isstring(x) || ischar(x));
	p.addParameter('nanstr', 'NaN', @(x) isstring(x) || ischar(x));
	p.addParameter('formatstr', '%0.2g', @(x) isstring(x) || ischar(x));
	p.parse(varargin{:});
	
	% Get optional zeropoint argument
	zeropoint = p.Results.Zeropoint;
	imagchar = p.Results.imagchar;
	junctionchar = p.Results.junctionchar;
	junctioncharneg = p.Results.junctioncharneg;
	nanchar = p.Results.nanstr;
	formatstr = p.Results.formatstr;
	
	
	if isnan(v)
		s = string(nanchar);
		return;
	end

	if abs(real(v)) < zeropoint && abs(imag(v)) < zeropoint % If both R & I are truncated
		s = "0";
		return;
	elseif abs(real(v)) < zeropoint % If only R is truncated
		s = string([imagchar, sprintf(formatstr, imag(v))]);
		return;
	elseif abs(imag(v)) < zeropoint % If only I is truncated
		s = string(sprintf(formatstr, real(v)));
		return;
	else % If none are truncated
		sr = sprintf(formatstr, real(v));
		if imag(v) > 0
			si = [imagchar, sprintf(formatstr, imag(v))];
			s = string([sr, junctionchar, si]);
		else
			si = [imagchar, sprintf(formatstr, abs(imag(v)))];
			s = string([sr, junctioncharneg, si]);
		end
		return;
	end

end