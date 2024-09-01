function setFigArrangement(fig_data)
		
	% Loop over figure numbers
	for fd = fig_data
		
		% Get figure handle
		fh = figure(fd.figNum);
		
		% Set position/size
		fh.Position = fd.Position;
		
	end
	
end