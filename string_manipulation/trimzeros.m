function str = trimzeros(in)
% Takes a string in scientific notation and trims leading zeros off the
% exponent and trailing zeros of the mantissa

	cs = char(in);

	noexp = false;
	nodec = false;
	
	% Find end of mantissa
	idxmantissa = find(cs == 'E' | cs == 'e');
	if numel(idxmantissa) > 1
		error("Input string has too many 'e' characters.");
	elseif isempty(idxmantissa)
		
		% Mark no exponent present
		noexp = true;
	end
	
	% Find decimal
	idxdec = find(cs == '.' | cs == ',');
	if numel(idxdec) > 1
		error("Input string has too many decimal characters.");
	elseif isempty(idxdec)
		
		% Mark no dec present
		nodec = true;
	end
	
	% Find start of exponent
	if ~noexp
		
		% CHeck that exponent ends in digit
		if ~isstrprop(cs(end),'digit')
			error("Exponent value does not end in a digit");
		end
		
		% Find end of exponent
		idxexp = -1;
		for i=length(cs)-1:-1:1
			if ~isstrprop(cs(i),'digit')
				idxexp = i;
				break;
			end
		end
		
		% Check index was found
		if idxexp == -1
			error("No exponent value was found.");
		end
	end	
	
	% Trim exponent
	if ~noexp
		
		% Scan over decimal places...
		trimno = 0;
		for i=idxexp:length(cs)

			% Exit when last non-zero value found
			if cs(i) == '0'
				trimno = trimno + 1;
			else
				break;
			end
		end

		% Trim specified number of characeters
		cs = [cs(1:idxexp), cs(idxexp+1+trimno:end)];
		
	end
	
	%Trim mantissa
	if ~nodec
		
		if noexp % No exponent, trim from end to decimal
			
			
			% Scan over decimal places...
			trimno = 0;
			trimall = true;
			for i=length(cs):-1:idxdec+1
				
				% Exit when last non-zero value found
				if cs(i) ~= '0'
					trimno = trimno + 1;
				else
					trimall = false;
					break;
				end
			end
			
			% If all decimal places are removed, trim decimal too
			if trimall
				trimno = trimno + 1;
			end
			
			% Trim specified number of characeters
			cs = cs(1:length(cs)-trimno);
			
		else % Exponent present, trim from exponent to decimal
			
			% Scan over decimal places...
			trimno = 0;
			trimall = true;
			for i=idxmantissa-1:-1:idxdec+1
				
				% Exit when last non-zero value found
				if cs(i) == '0'
					trimno = trimno + 1;
				else
					trimall = false;
					break;
				end
			end
			
			% If all decimal places are removed, trim decimal too
			if trimall
				trimno = trimno + 1;
			end
			
			% Trim specified number of characeters
			cs = [cs(1:idxmantissa-1-trimno), cs(idxmantissa:end)];
			
		end
		
	end
	
	% Trim beginning of mantissa
	while length(cs) > 1
		if cs(1) == '0' && isstrprop(cs(2),'digit')
			cs = cs(2:end);
		else
			break;
		end
	end
	
	str = string(cs);

end