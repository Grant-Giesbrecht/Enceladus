function ssa = mergesolutions(ss1, ss2)

	% Initialize output array
	ssa = ss1(1);
	ssa(1) = [];
	
	% Scan over all permutations
	for s1 = ss1 
		for s2 = ss2
			% Create new rfnet
			newnet = rfnet(s1.mats(1), s1.ZS, s2.ZL);
			
			% Add all other elements
			for i = 2:numel(s1.mats)
				newnet.add(s1.mats(i));
			end
			
			% Add all elements for 2nd solution
			for i = 1:numel(s2.mats)
				newnet.add(s2.mats(i));
			end
			
			% Update name
			newnet.name = "[S1: " + s1.name + "] to [S2: " + s2.name+"]";
			
			% Push back
			ssa(end+1) = newnet;
		end
	end

end