function sa = cm2struct(CM)
% CM2STRUCT Converts a contour matrix (as created by contour) to an array
% of structs with fields: level, n, x, y
	
	[rows, cols] = size(CM);
	if rows ~= 2
		error("matrix is wrong size! must have exactly 2 rows.");
	end

	sa = [];
	
	c = 1;
	while c <= cols
		
		% Create new struct
		ns = struct;
		
		% Copy level and length
		ns.level = CM(1, c);
		ns.n = CM(2, c);
		
		% Copy in data
		ns.x = CM(1, c+1:c+ns.n);
		ns.y = CM(2, c+1:c+ns.n);
		
		% Increment column pointer
		c = c + 1 + ns.n;
		
		% Save struct
		sa = addTo(sa, ns);
	end

end