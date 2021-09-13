function idxs = findallhits(vals, target, start, leftlim, rightlim, useLinear)
% FINDALLHITS Find all occurances a value
%
% Given a starting index pointing to the target value, and left and right
% search limits, finds all indecies of target value. Can use a linear or
% binomial search patttern. 
%
% IDXS = FINDALLHITS(VALS, TARGET, START, LEFTLIM, RIGHTLIM, USELINEAR)
% Searches the array vals for all indecies with value target. start is the
% index where the search starts, and must point to the target value.
% leftlime and rightlim specify bounds to the search range. useLinear
% allows you to opt for a binomial or linear search.
%
% See also: bfindall

	llim = -1;
	rlim = -1;
	
	% Return early if starting position does not match
	if vals(start) ~= target
		warning("Starting posiiton misses correct value!");
		return;
	end
	
	% Return early if indecies invalid
	if leftlim > start || rightlim < start
		warning("Invalid indecies! Requires: leftlim <= start <= rightlim");
		return;
	end
	
	% Use linear search
	if useLinear
		
		% Find upper limit
		for i = start:rightlim
			% Look for value change
			if vals(i) ~= target
				rlim = i-1; % Record last match index
				break;
			end			
		end
		
		% Find lower limit
		for i = start:-1:leftlim
			% Look for value change
			if vals(i) ~= target
				llim = i+1; % Record last match index
				break;
			end			
		end
		
	else % Use binary search
		
		% Find lower limit
		llim = leftlim;
		rlim = rightlim;
		rb = start;
		lb = leftlim;
		while lb <= rb
			
			% Find middle
			mid = ceil((rb+lb)/2);

% 			displ("L: ", lb, " M: ", mid, " R: ", rb);
			
			% Check if still in match region
			if vals(mid) == target
				
				% Check if 'mid' is the last match
				if vals(mid-1) ~= target
					% Save mid as left limit
					llim = mid;
					break;
				end
				
				% Update search range
				rb = mid;
				
			else
				
				% Check if 'mid' is the first mismatch
				if vals(mid+1) == target
					% Save mid+1 as left limit
					llim = mid+1;
					break;
				
				end
				
				% Update search range
				lb = mid;
			end
			
		end
		
		% Find upper limit
		rb = rightlim;
		lb = start;
		while lb <= rb
			
			% Find middle
			mid = ceil((rb+lb)/2);

% 			displ("L: ", lb, " M: ", mid, " R: ", rb);
			
			% Check if still in match region
			if vals(mid) == target
				
				% Check if 'mid' is the last match
				if vals(mid+1) ~= target
					% Save mid as left limit
					rlim = mid;
					break;
				end
				
				% Update search range
				lb = mid;
				
			else
				
				% Check if 'mid' is the first mismatch
				if vals(mid-1) == target
					% Save mid+1 as left limit
					rlim = mid-1;
					break;
				end
			end
			
			% Update search range
			rb = mid;
			
		end
		
	end
	
	idxs = llim:1:rlim;

end