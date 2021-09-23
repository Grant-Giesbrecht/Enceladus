function idxs = bfindall(A, num, len, use_linear)
% BFINDALL Binomial search of sorted vector for all instances of target
%
% Searches the vector A for the value num and returns all indexes of num.
%
% IDX = BFINDALL(A, NUM) Searches A for the value num. Returns the indecies
% where num was found.
%
% IDX = BFINDALL(A, NUM, LEN) Searches A for the value num. Returns the 
% indecies where num was found. Uses LEN as the length of A instead of 
% recounting. 
%
% IDX = BFINDALL(A, NUM, LEN, USE_LINEAR) Searches A for the value num.  
% Returns the indecies where num was found. Uses LEN as the length of A  
% instead of recounting. use_linear specifies, once the first occurance
% of num is found, whether a linear of binomial search is used to find the
% ends of the matched region. vectors with many repeated values, binomial
% is faster. Default is to use a linear search.
%
% See also: bfind, findallhits, find

	if ~exist('len', 'var')
		len = length(A);
	end
	
	if ~exist('use_linear', 'var')
		use_linear = true;
	end

	left = 1;
	right = len;
	idxs = [];

	% While not through entire array...
	while left <= right
		
		% Find middle of focused region
		mid = ceil((left + right) / 2);

% 		displ("bfindall: L: ", left, " M: ", mid, " R: ", right);

		
		if A(mid) == num % If value was found...
			
			idxs = findallhits(A, num, mid, left, right, use_linear);
			break;
			
		elseif A(mid) > num % If value 
			right = mid - 1;
		else
			left = mid + 1;
		end
	end

end

