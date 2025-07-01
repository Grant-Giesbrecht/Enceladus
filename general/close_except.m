function close_except(keep_list)
    % Thanks to https://stackoverflow.com/questions/16680622/close-all-figures-in-matlab-except-specific-ones
    
	% Get list of all open figures
	all_figs = findobj(0, 'type', 'figure');
	
	% Scan over all open figures
	close_figs = [];
	for fidx = 1:numel(all_figs)

		% If open fig is not in keep_list...
		if ~any(all_figs(fidx).Number == keep_list)

			% Add to list of handles to close
			close_figs = [close_figs, all_figs(fidx)];
		end
	end
	
	% Close all specified handles
    close(close_figs);
end
