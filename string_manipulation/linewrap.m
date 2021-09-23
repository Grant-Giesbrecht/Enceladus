function fs = linewrap(s, varargin)
% LINEWRAP Wrap to limit the length of a string.
%
%	FS = LINEWRAP(S) Limits the length of S to 80 characters per line,
%	wrapping the string as neccesary and adding hyphens if a word is
%	broken.
%
%	FS = LINEWRAP(..., Name, Value) Specifies line wrapping behavior using
%	one or more Name,Value pair arguments.
%
%	Name,Value pair options:
%
%	NAME: BreakRule
%	VALUE: Specifies behavior when string must be wrapped. Options are:
%		preserveWords - Do not split words unless word is longer than line
%		justifyShowBreak - Break line exactly at length limit, using
%		BreakSym to indicate the break.
%		justifyIgnoreBreak - Break line exactly at length limit and do not
%		add a BreakSym at break location.
%	DEFAULT: preserveWords
%
%	NAME: Limit
%	VALUE: Maximum line length allowed. Accepts any integer.
%	DEFAULT: 80
%
%	NAME: BreakSym
%	VALUE: String to add when a word is broken over lines and the break is
%	shown. Accepts strings and character arrays.
%	DEFAULT: '-'
%
% See also strtrim.

	%TODO: Don't start with spaces

	ruleOptions = {'preserveWords', 'justifyShowBreak', 'justifyIgnoreBreak'};

	p = inputParser();
	p.addParameter('Limit', 80, @isnumeric);
	p.addParameter('BreakRule', 'preserveWords', @(x) any(validatestring(char(x),ruleOptions)) );
	p.addParameter('BreakSym', '-', @(x) isstring(x) || ischar(x));
	p.parse(varargin{:});
	
	brksym = char(p.Results.BreakSym);
	fs = "";
	s = char(s);
	
	if strcmp(p.Results.BreakRule, 'justifyIgnoreBreak')
		
		% Break apart string into subsections
		while true
			
			% Check for completion condition
			if length(s) <= p.Results.Limit
				fs = strcat(fs, string(s));
				break;
			end
			
			% Else add another line
			fs = strcat(fs, string(s(1:p.Results.Limit)), string(newline));
			
			% And shorten variable
			s = s(p.Results.Limit + 1:end);
			
		end
		
	elseif strcmp(p.Results.BreakRule, 'preserveWords')
		
		% Break apart string into subsections
		while true
					
			% Check for completion condition
			if length(s) <= p.Results.Limit
				fs = strcat(fs, string(s));
				break;
			end
			
			% Find break index that preserves all words
			idx = find(s(1:p.Results.Limit+1)==' ', 1, 'last');
			
			% If word is longer than limit, break word and indicate
			if isempty(idx)
				
				% Add string to output
				ls = length(brksym);
				fs = strcat(fs, s(1:p.Results.Limit-ls), brksym, string(newline));
				
				% Trim string variable
				s = s(p.Results.Limit-ls + 1:end);
				
			else % Found word where to break
				
				% Add string to output
				fs = strcat(fs, s(1:idx), string(newline));
				
				% Trim string variable
				s = s(idx + 1:end);
				
			end
			
		end
		
	elseif strcmp(p.Results.BreakRule, 'justifyShowBreak');
		
		% Break apart string into subsections
		while true
					
			% Check for completion condition
			if length(s) <= p.Results.Limit
				fs = strcat(fs, string(s));
				break;
			end
				
			% Add string to output
			ls = length(brksym);
			fs = strcat(fs, s(1:p.Results.Limit-ls), brksym, string(newline));

			% Trim string variable
			s = s(p.Results.Limit-ls + 1:end);
			
		end
		
	end
	
	
end