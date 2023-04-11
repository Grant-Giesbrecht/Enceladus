function conf_struct = load_gconf(filename)
% LOAD_GCONF Loads configuration file
%	
%	LOAD_GCONF(filename) Loads the configuration file at the path specified
%	by filename.
%
%	Expected file format: (.gconf)
%	Format rules:
%	  - Three types of lines permitted:
%	    1. Blank
%		2. Comment: Begins with '//', remainder is ignored
%		3. Data: <name> = <value tokens>
%
	%Open file
	fid = fopen(filename);
	if fid == -1
		obj.logErr(strcat('Failed to open file "', filename, '"'));
		return;
	end
	
	lnum = 0;
	
	%Read file line by line
	while(~feof(fid)) %- - - - - - - Loop Through File - - - - - -

		sline = fgetl(fid); %Read line
		lnum = lnum+1; %Increment Line Number

		%Remove comments
		sline = trimtok(sline, '//');

		%Note: char(9) is the tab character
		sline = ensureWhitespace(sline, ';');
		words = parseIdx(sline, [" ", char(9)]);

		%Skip blank lines
		if isempty(words)
			continue
		end
		
		% Check number of tokens
		if numel(words) < 3
			warning(strcat("Incorrect number of tokens on line ", num2str(lnum), ". Skipping line."));
		end
		
		%TODO: Verify that field name is appropriate
		
		% Add to output struct
		conf_struct.(words(1).str) = sline(words(3).idx+1:end);
	end
	
end