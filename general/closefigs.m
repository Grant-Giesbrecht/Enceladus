function closefigs
% CLOSEFIGS Closes all figures, including uifigures
%
% See also: close

	all_fig = findall(0, 'type', 'figure');
	close(all_fig);
end