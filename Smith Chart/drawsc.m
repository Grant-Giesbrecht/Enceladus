function ndrawn = drawsc(AH)

	style = 'circle';
	fill = false;

	% Check if axes handle provided
	if ~exist('AH', 'var')
		AH = gca;
	end

	% Delete previous objects
	cla(AH)
	
	if strcmp(style, 'simple')
		% Turn background on
		set(AH, 'visible', 'on');
	else
		%Turn background off
		set(AH, 'visible', 'on');
		set(AH, 'color', [240, 240, 240]./255);
		fill = true;
		
		% Create legend, set color to white, hide until called back
		lgnd = legend(AH);
		set(lgnd, 'Color', [1,1,1]);
		set(lgnd, 'Visible', 'off');
	end
	
	% Turn off X and Y label lines
	set(AH, 'XColor', 'none');
	set(AH, 'YColor', 'none');
	
	% Draw SC circles
	hold on
	ndrawn = drawsccircles(fill);

	% Set limits
	xlim([-1.01, 1.01]);
	ylim([-1.01, 1.01]);
	
	% Set data to be square
	daspect([1, 1, 1])
	pbaspect([2, 1, 1])
	
	% Reset color order
	set(AH, 'ColorOrderIndex', 1);

end