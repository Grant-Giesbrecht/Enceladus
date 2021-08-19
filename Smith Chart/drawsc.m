function drawsc(AH)

	% Check if axes handle provided
	if ~exist('AH', 'var')
		AH = gca;
	end

	% Delete previous objects
	cla(AH)
	
	% Turn background on
	set(AH, 'visible', 'on');
	
	% Turn off X and Y label lines
	set(AH, 'XColor', 'none');
	set(AH, 'YColor', 'none');
	
	% Draw SC circles
	hold on
	drawsccircles();

	% Set limits
	xlim([-1.1, 1.1]);
	ylim([-1.1, 1.1]);
	
	% Set data to be square
	daspect([1, 1, 1])

end