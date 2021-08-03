function s = num2fstr(v, varargin)
%
%
%
%
%	NAME: Zeropoint
%	VALUE: Sets point at which values are truncated.
%	DEFAULT: 1e-6
%
%	NAME: imagchar
%	VALUE: String appended to the imaginary component.
%	DEFAULT: 'i'
%	
%	NAME: junctionchar
%	VALUE: String used to join real to positive imaginary component
%	DEFAULT: '+'
%
%	NAME: junctioncharneg
%	VALUE: String used to join real and negative imaginary components
%	DEFUALT: '-'
%
%	NAME: nanstr
%	VALUE: String returned when value is NaN
%	DEFAULT: 'NaN'
%	
%	NAME: formatstr
%	VALUE: String used to format value, according to sprintf(). Can be
%	overwritten from default. Note: num2fstr adds additional letter
%	formatting option 'a' or 'A' which functions similarly to 'g' and 'G'
%	in that it automatically switches between scientific and fixed, however
%	a/A uses num2fstr's switching algorithm.
%
%	NAME: Scaling
%	VALUE: How automatic scaling (as specified with 'A' in formatstr) is
%	deceided.
%	OPTIONS: 'auto', 'engineering'
%	DEFAULT: 'auto'

	% TODO: sprintf isn't good enough. Look at .002 for example. It pads
	% the exponent with '-04' instead of just -4 and will pad the leading
	% number with extra zeros. So scientific format for .003 gave
	% "3.00e-04" which is absurd when "3e-4" works just as well. Result is
	% 'g' formatting wont print as 'engineering' values (ie. 2.3 prints as
	% '2.3' and -.1 prints as '100e-3' or likewise. This needs to be fixed!

	expectedScaling = {'auto', 'engineering'};

	p = inputParser;
	p.addParameter('Zeropoint', 1e-6, @isnumeric);
	p.addParameter('imagchar', 'i', @(x) isstring(x) || ischar(x));
	p.addParameter('junctionchar', '+', @(x) isstring(x) || ischar(x));
	p.addParameter('junctioncharneg', '-', @(x) isstring(x) || ischar(x));
	p.addParameter('nanstr', 'NaN', @(x) isstring(x) || ischar(x));
	p.addParameter('formatstr', '%0.2A', @(x) isstring(x) || ischar(x));
	p.addParameter('Scaling', 'auto', @(x) any(validatestring(x,expectedForms)) );
	p.parse(varargin{:});
	
	% Get optional zeropoint argument
	zeropoint = p.Results.Zeropoint;
	imagchar = p.Results.imagchar;
	junctionchar = p.Results.junctionchar;
	junctioncharneg = p.Results.junctioncharneg;
	nanchar = p.Results.nanstr;
	formatstr = p.Results.formatstr;
	
	
	
	% Return early if is NaN
	if isnan(v)
		s = string(nanchar);
		return;
	end
	
	% Handle 'a'/'A' formatting
	if strcmp(p.Results.Scaling, 'auto')
		
		if abs(v) < 10e-3 || abs(v) > 1e3 % Use scientific
			formatstr = strrep(formatstr, "a", "e");
			formatstr = strrep(formatstr, "A", "E");
		else % Use fixed
			formatstr = strrep(formatstr, "a", "f");
			formatstr = strrep(formatstr, "A", "f");
		end

	elseif strcmp(p.Results.Scaling, 'engineering')
		
		
		
	end
	
	% Check which real/imag components need to be truncated
	if abs(real(v)) < zeropoint && abs(imag(v)) < zeropoint % If both R & I are truncated
		s = "0";
	elseif abs(real(v)) < zeropoint % If only R is truncated
		s = string([imagchar, sprintf(formatstr, imag(v))]);
	elseif abs(imag(v)) < zeropoint % If only I is truncated
		s = string(sprintf(formatstr, real(v)));
	else % If none are truncated
		sr = sprintf(formatstr, real(v));
		if imag(v) > 0
			si = [imagchar, sprintf(formatstr, imag(v))];
			s = string(strcat(sr, junctionchar, si));
		else
			si = [imagchar, sprintf(formatstr, abs(imag(v)))];
			s = string(strcat(sr, junctioncharneg, si));
		end
	end
	
	s = string(s);
% 	s = trimzeros(s);
end