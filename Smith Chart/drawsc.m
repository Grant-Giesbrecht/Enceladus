function drawsc(AH)

	% Check if axes handle provided
	if ~exist('AH', 'var')
		AH = gca;
	end

	% Delete previous objects
	cla(AH)
	
	% Turn off X and Y label lines
% 	set(AH, 'XColor', 'none');
% 	set(AH, 'YColor', 'none');
	
	% Draw SC circles
	hold on
	drawsccircles();

	% Set data to be square
	daspect([1, 1, 1])

end