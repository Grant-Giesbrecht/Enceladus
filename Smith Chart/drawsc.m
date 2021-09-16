function ndrawn = drawsc(AH, scheme)

	if ~exist('scheme', 'var')
		scheme = 'Light';
	end
	
	if strcmp(scheme,'Light')
		background_color = [240, 240, 240]./255;
		legend_color = [1,1,1];
	else
		background_color = [240, 240, 240]./255;
		legend_color = [.6, .6, .6];
	end

	style = 'circle';
	fill = false;

	% Check if axes handle provided
	if ~exist('AH', 'var')
		AH = gca;
	end

	% Delete previous objects
	cla(AH)
	
	if strcmp(style, 'simple') % This mode is simpler
		% Turn background on
		set(AH, 'visible', 'on');
	elseif strcmp(style, 'circle') % This mode looks more professional and is optimized to work with schemes
		
		%Turn background off
		set(AH, 'visible', 'on');
		set(AH, 'color', background_color);
		fill = true;
		
		% Create legend, set color to white, hide until called back
		lgnd = legend(AH);
		set(lgnd, 'Color', legend_color);
		set(lgnd, 'Visible', 'off');
	end
	
	% Turn off X and Y label lines
	set(AH, 'XColor', 'none');
	set(AH, 'YColor', 'none');
	
	% Draw SC circles
	hold on
	ndrawn = drawsccircles(fill, scheme);

	% Set limits
	xlim([-1.01, 1.01]);
	ylim([-1.01, 1.01]);
	
	% Set data to be square
	daspect([1, 1, 1])
	pbaspect([2, 1, 1])
	
	% Ensure grid is off
	grid off
	
	% Reset color order
	set(AH, 'ColorOrderIndex', 1);
	
	
	% Change color order to dark if in dark scheme
	if strcmp(scheme, 'Dark')
		darkcolors = [200, 0, 255;255, 17, 0; 68, 255, 0]./255;
		colororder(AH, darkcolors);
	end

end