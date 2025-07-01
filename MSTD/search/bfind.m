function idx = bfind(A, num, len)
% BFIND Binomial search of sorted vector
%
% Searches the vector A for the value 'num' and returns the index of 'num'.
% Note: If multiple instances of 'num' are present, it is not defined which
% instance's index will be returned. 
%
% IDX = BFIND(A, NUM) Searches A for the value num. Returns the index where
% num was found.
%
% IDX = BFIND(A, NUM, LEN) Searches A for the value num. Returns the index
% where num was found. Uses LEN as the length of A instead of recounting.
%
% See also: bfindall, findallhits, find

	if ~exist('len', 'var')
		len = length(A);
	end

	left = 1;
	right = len;
	idxs = [];

	% While not through entire array...
	while left <= right
		
		% Find middle of focused region
		mid = ceil((left + right) / 2);

% 		displ("bfind: L: ", left, " M: ", mid, " R: ", right);

		
		if A(mid) == num % If value was found...
			
			idx = mid;
			return;
			
		elseif A(mid) > num % If value 
			right = mid - 1;
		else
			left = mid + 1;
		end
	end

end

