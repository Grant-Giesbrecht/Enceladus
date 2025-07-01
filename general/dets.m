function dets(arr)

	[r,c] = size(arr);

	displ("type: ", class(arr) ," Min: ", min(arr), " Max: ", max(arr)); %, " Size: [ ", r, " x ", c, " ]");
	displ("Size: [", r, "x", c, "] No. Unique: ", numel(unique(arr)) );

end