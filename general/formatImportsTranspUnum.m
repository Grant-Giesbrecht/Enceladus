function formatImportsTranspUnum(varargin)

	kvf = NaN;
	kvf_name = "";
	hasKv = false;

	for id = 1:nargin
		x = varargin{id};
		name = inputname(id);
		mods = "";
		unitsX = "";
		
		%Check if input is KvFile object
		if class(x) == 'KvFile'
			kvf = x;
			kvf_name = name;
			hasKv = true;
			continue;
		end
		
		dim = size(x);
		
		%Ensure correct dimensions
		if dim(1) > dim(2)
			x=x.';
			dim = size(x);
			if mods == ""
				mods = strcat("Transposed matrix (new dim: ", string(dim(1)), "x", string(dim(2)) ,")");
			else
				mods = strcat(mods, ", transposed matrix (New dim: ", string(dim(1)), "x", string(dim(2)) ,")");
			end
		end
		
		%Convert unit string to numbers
		if class(x) == "string"
			[xf, unitsX] = unum2float(x);
			if isnan(xf)
				disp("****************************************");
				disp("Failed to convert string list to floats.");
				disp("****************************************");
			else
				x = xf;
			end
			if mods == ""
				mods = strcat("Converted unit-strings to float (Unit: ", unitsX ,")");
			else
				mods = strcat(mods, ", converted unit-strings to float (Unit: ", unitsX ,")");
			end
		end
		
		%Update variables in workspace if modified
		if mods ~= ""
			disp(strcat( "Formatted variable '", name ,"': ", mods ));
			assignin('base', name, x);
		end
		
		%If KvFile provided, add variable to object
		if hasKv
			kvf.add(x, name, unitsX);
		end
		
	end
	
end