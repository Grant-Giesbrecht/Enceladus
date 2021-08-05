function s = num2fstr(v, varargin)
% NUM2FSTR Convert numbers to strings with advanced formatting
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

%**************************************************************************
% KNOWN ISSUES:															  *
%**************************************************************************
%
% Fixed notation printing gives misleading answer if precision (ie. number
% after decimal in format string) is too low. For example, '%0.2a' will
% cause .003 to print as zeros. This is a results of sprintf's behaviors
% with 'f' type formatting.
%
% Complex and real components currently must have same formatting. This
% could be bad if one were large and one were small.
%
% Engineering format ignores precision specified in format string.
%
% trimzeros() doesn't trim zeros in exponent of many numbers, including
% those in engineering format returned by num2estr().
%
%**************************************************************************

	% TODO: sprintf isn't good enough. Look at .002 for example. It pads
	% the exponent with '-04' instead of just -4 and will pad the leading
	% number with extra zeros. So scientific format for .003 gave
	% "3.00e-04" which is absurd when "3e-4" works just as well. Result is
	% 'g' formatting wont print as 'engineering' values (ie. 2.3 prints as
	% '2.3' and -.1 prints as '100e-3' or likewise. This needs to be fixed!

	%================== Run Input Parser on Varargin ======================
	
	expectedScaling = {'auto', 'engineering', 'scientific', 'fixed'};

	emptyMap = containers.Map();
	
	p = inputParser;
		
	p.addParameter('ImagStr', 'i*', @(x) isstring(x) || ischar(x)); % String to indicate imaginary numbers
	p.addParameter('JunctionStr', ' + ', @(x) isstring(x) || ischar(x)); %String to indicate 
	p.addParameter('JunctionStrNeg', ' - ', @(x) isstring(x) || ischar(x));
	p.addParameter('NanStr', 'NaN', @(x) isstring(x) || ischar(x));
	
	p.addParameter('FormatStr', '%0.2a', @(x) isstring(x) || ischar(x));
	p.addParameter('Scaling', 'auto', @(x) any(validatestring(x,expectedScaling)) );
	p.addParameter('Units', '', @(x) isstring(x) || ischar(x)); %TODO
	
	p.addParameter('Threshold', 1e3, @isnumeric);
	p.addParameter('ZeroPoint', 1e-6, @isnumeric);
	
	p.addParameter('FormatOptions', emptyMap , @(x) isa(x, 'containers.Map'));
	p.parse(varargin{:});
	
	% Read optional arguments
	opt = p.Results;
	
	% Convert any chars in optional arguments to strings
	opt.ImagStr = string(opt.ImagStr);
	opt.JunctionStr = string(opt.JunctionStr);
	opt.JunctionStrNeg = string(opt.JunctionStrNeg);
	opt.NanStr = string(opt.NanStr);

	
	%======== Overwrite defaults with any values in FormatOptions =========
	
	if ~opt.FormatOptions.isempty() % Check that FormatOptions is not empty
	
		% Get list of options using defualts
		defaults = ccell2mat(p.UsingDefaults); 
		
		% For each option in FormatOptions...
		for kc = opt.FormatOptions.keys
			
			k = kc{:};
			
			% Check if it is both a valid key, and not overridden in
			% function arguments
			if any(k == defaults)
								
				% Overwrite defualt value with value from FormatOptions
				opt.(k) = opt.FormatOptions(k);
			end
		end
	end
	
	%==================== Return early if is NaN ==========================
	if isnan(v)
		s = string(opt.NanStr);
		return;
	end
	
	%============ Handle Auto-Formatting (ie. A-tpye) =====================
	
	% Calculate thresholds for auto formatting
	t_hi = abs(opt.Threshold);
	t_lo = abs(1/opt.Threshold);
	if t_hi < t_lo
		t_hi = t_lo;
		t_lo = abs(opt.Threshold);
	end
	
	% Handle 'a'/'A' formatting
	use_eng = false;
	if strcmp(opt.Scaling, 'auto')
		
		if abs(v) <= t_lo || abs(v) >= t_hi % Use scientific
			opt.FormatStr = strrep(opt.FormatStr, "a", "e");
			opt.FormatStr = strrep(opt.FormatStr, "A", "E");
		else % Use fixed
			opt.FormatStr = strrep(opt.FormatStr, "a", "f");
			opt.FormatStr = strrep(opt.FormatStr, "A", "f");
		end

	elseif strcmp(opt.Scaling, 'engineering')
		use_eng = true;
	elseif strcmp(opt.Scaling, 'fixed')
		opt.FormatStr = strrep(opt.FormatStr, "a", "g");
		opt.FormatStr = strrep(opt.FormatStr, "A", "G");
	elseif strcmp(opt.Scaling, 'scientific')
		
		opt.FormatStr = strrep(opt.FormatStr, "a", "e");
		opt.FormatStr = strrep(opt.FormatStr, "A", "E");
		
	end
	
	%============== Truncate Sub-Zero Point Values ========================
	
	% Check which real/imag components need to be truncated
	if abs(real(v)) < opt.ZeroPoint && abs(imag(v)) < opt.ZeroPoint % If both R & I are truncated
		s = "0";
	elseif abs(real(v)) < opt.ZeroPoint % If only R is truncated
		
		if use_eng
			vs = num2estr(imag(v));
		else
			vs = sprintf(opt.FormatStr, imag(v));
		end
		
		s = string(strcat(opt.ImagStr, vs));
	elseif abs(imag(v)) < opt.ZeroPoint % If only I is truncated
		
		if use_eng
			vs = num2estr(real(v));
		else
			vs = sprintf(opt.FormatStr, real(v));
		end
		
		s = string(vs);
	else % If none are truncated
		
		if use_eng
			sr = num2estr(real(v));
			vs = num2estr(imag(v));
		else
			sr = sprintf(opt.FormatStr, real(v));
			vs = sprintf(opt.FormatStr, imag(v));
		end
		
		if imag(v) > 0
			si = strcat(opt.ImagStr, vs);
			s = string(strcat(sr, opt.JunctionStr, si));
		else
			si = strcat(opt.ImagStr, vs);
			s = string(strcat(sr, opt.JunctionStrNeg, si));
		end
	end
	
	% Return Result
	s = string(s);
% 	s = trimzeros(s);
end





