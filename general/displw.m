function displ(varargin)
%DISPL Displays a list of input variables and wraps contents.
%
%	DISPL(...) For each argument passed to DISPL, the argument is converted
%	to a string, concatanated together, and displayed via DISP. Input
%	arguments that are a numeric type according to ISNUMERIC are converted
%	using NUM2STR, all other inputs are fed to STRING constructor. If no
%	input arguments are provided, it prints a blank newline.
%
%	See also DISP.

	disp_str = "";
	
	for id = 1:nargin		
		
		%Get net argument
		x = varargin{id};
		
		%Convert to a string
		if isnumeric(x) %Conversion law for numbers
			x = num2str(x);
		else
			x = string(x);
		end
		
		%Append to master string
		disp_str = strcat(disp_str, x);
		
	end
	
	%Display the final string
	if nargin == 0 %If not arguments, print a blank newline
		disp(" ") %Display a space to print a new line
	else %Display the master string
		disp(disp_str);
	end

end