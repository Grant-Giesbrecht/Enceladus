function confs = loadConfig(fileIn, varargin)
%LOADCONFIG loads a text file containing simple configuration data
%
% CONFS = LOADCONFIG(FILEIN) Read the file FILEIN and returns its data in a
% map CONFS.
%
% CONFS = LOADCONFIG(FILEIN, OPTIONS, ...) Reads the file FILEIN using the
% options (see available options in list below) and returns the file's data
% in a map CONFS.
%
% Options:
%	* ShowMessages:
%		- Specifies if the function is allowed to print messages to the
%		  console.
%		- Accepts argument of logical type
%					
%
%
% Accepted File Format Rules:
%	* Lines starting with two forward slashes ('//') are counted as
%	comments and are ignoreed. However, if they appear after any other
%	character, even white space, they will be interpreted as a config entry
%	instead of as a comment
%	* Config entries expect a string key which will be contiguous (not
%	broken by any whitespace) and can contain any character. After the
%	block of whitespace immediately following this first 'word' or key end,
%	the remainder of the line will be assigned as the value.
%	* The value is run through STRTRIM to remove all trailing whitespace
%	from the value. This means the value cannot start or end with a string.
%
%	Note: Suggested file extension is .conf
%
% Returns:
%	* Map with keys as the names of the properties in the conf file, and
%	values for the properties' values.
%	* Logical false if the function fails to read the specified file

	show_messages = true;

	% Scan through arguments
	for vidx = 1:2:nargin-1
		
		if nargin < vidx+1
			displ("Missing argument for option '", vargin{vidx}, "'");
			break;
		end
		
		if strcmp(varargin{vidx}, "ShowMessages")	% Option is 'ShowMessages'
			
			%Verify that argument is correct type
			if ~strcmp(class(varargin{vidx+1}), "logical")
				displ("Option 'ShowMessages' requires an argument of type 'logical'.");
			else
				% Argument is correct type
				
				% Update option
				show_messages = varargin{vidx+1};
				
			end
		else
			displ("Failed to recognize argument '", varargin{vidx}, "'.");
		end
	end

	%Create output map
	confs = containers.Map;
	
	% Open the settigns/configuration file
	fid = fopen(fileIn);
	if fid == -1
		
		% Display error message if permitted
		if show_messages
			displ('Failed to open settings file "', fileIn, '".');
		end
		
		confs = false;
		return;
	end
	
	while(~feof(fid)) %- - - - - - - Loop Through File - - - - - -
		
		%Read line
		sline = fgetl(fid); 
		
		%Parse line
		words = parseIdx(sline, [" ", char(9)]);
		if isempty(words)
			continue;
		end
		
		% Skip comments
		cfirst = char(words(1).str);
		if strcmp(cfirst(1:2), '//')
			continue;
		end
		
		% Save value
		idx_start = words(2).idx;
		confs(words(1).str) = strtrim(sline(idx_start:end));
		
	end
	

end































