function arrangement = getFigArrangement(figNums)
		
	% Loop over figure numbers
	for fni = numel(figNums):-1:1
		
		% Get figure number
		fn = figNums(fni);
		
		% Get figure handle
		fh = figure(fn);
		
		% Get position, add to cell
		fh_data = struct('Position', fh.Position, 'figNum', fn);
		arrangement(fni) = fh_data;
		
	end
	
end