function savefigs(figNums, directory, prefix)
% SAVEFIGS Saves a set of figures
%
%
	
	% Check optional arguments
	if ~exist('directory', 'var')
		directory = ".";
	end
	if ~exist('prefix', 'var')
		prefix = "fig_";
	end
	
	% Save each figure
	for fn = figNums
		
		% Access figure
		fh = figure(fn);
		
		% Save figure
		savefig(fh, fullfile(directory, prefix+num2str(fn)+".fig"));
	end
	
end