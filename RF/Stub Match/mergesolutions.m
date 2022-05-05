function ssa = mergesolutions(ss1, ss2, is_recursive, varargin)

	% Add default state to is_recursive option
	if ~exist('is_recursive', 'var')
		is_recursive = false;
	end

	% Initialize output array
	ssa = ss1(1);
	ssa(1) = [];
	
	% Get list of IDs
	all_ids = zeros(1, numel(ss1)+numel(ss2));
	idx = 1;
	for s = [ss1, ss2]
		all_ids(idx) = s.ID;
		idx = idx + 1;
	end
	
	% Scan over all permutations
	for s1 = ss1 
		for s2 = ss2
			% Create new rfnet
			newnet = rfnet(s1.mats(1), s1.ZS, s2.ZL);
			newnet.ZS_design = s1.ZS_design;
            newnet.ZL_design = s2.ZL_design;
            
			% Add all other elements
			for i = 2:numel(s1.mats)
				newnet.add(s1.mats(i));
			end
			
			% Add all elements for 2nd solution
			for i = 1:numel(s2.mats)
				newnet.add(s2.mats(i));
			end
			
			% Update ID
			newnet.ID = max(all_ids)+1;
			all_ids(end+1) = newnet.ID;
			
			% Update name
			newnet.name = "[S1: " + s1.name + "] -> [S2: " + s2.name+"]";
			
			% Push back
			ssa(end+1) = newnet;
		end
	end

end