function result = ccell2mat(ca)

	% Get input size
	[rows,cols] = size(ca);
	
	% Create output array
	result = "";
	
	% Convert array and copy into output
	for r = 1:rows
		for c = 1:cols
			cv = ca(r,c);
			result(r,c) = string(cv{:});
		end
	end

end