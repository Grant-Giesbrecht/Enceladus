function [topLeft, botRight] = find_contiguous_block(input_data, seedrow, seedcol)
% Given an array of logical data, finds the top left and bottom right
% coordinates of a contiguous block of ones. Adjacent cells are considered
% contiguous. Seedrow and seedcol indicate the cell in which to begin the
% search.

	% check input type
	if ~islogical(input_data)
		error("Requires logical input data");
	end

	% Create struct with seed
	seed.row = seedrow;
	seed.col = seedcol;
	
	% Create struct
	dummy.val = false;
	dummy.checked = false;
	dummy.max_row = -1;
	dummy.max_col = -1;
	dummy.min_row = -1;
	dummy.min_col = -1;
	
	% Create data array
	[nr, nc] = size(input_data);
	data = repmat(dummy, nr, nc);
	
	% Populate with input data
	for r = 1:nr
		for c = 1:nc
			if input_data(r,c)
				data(r, c).val = true;
			end
		end
	end
	
	[all_rows, all_cols] = trace_contiguous(data, seed);
	
	topLeft.col = min(all_cols);
	topLeft.row = min(all_rows);
	
	botRight.col = max(all_cols);
	botRight.row = max(all_rows);
	

end