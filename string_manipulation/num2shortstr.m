function s = num2shortstr(v, zeropoint)

	% TODO: sprintf isn't good enough. Look at .002 for example. It pads
	% the exponent with '-04' instead of just -4 and will pad the leading
	% number with extra zeros. So scientific format for .003 gave
	% "3.00e-04" which is absurd when "3e-4" works just as well. Result is
	% 'g' formatting wont print as 'engineering' values (ie. 2.3 prints as
	% '2.3' and -.1 prints as '100e-3' or likewise. This needs to be fixed!


	% Get optional zeropoint argument
	if ~exist('zeropoint', 'var')
		zeropoint = 1e-6;
	end
	
	imagchar = 'i';
	formatstr = '%0.2g';
	junctionchar = '+';
	

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
		si = [imagchar, sprintf(formatstr, imag(v))];
		s = string([sr, junctionchar, si]);
		return;
	end

end