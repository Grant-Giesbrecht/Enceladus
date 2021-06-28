function ddf = grid2ddf(labels, data, varargin)
% Designed for copy and paste of data from spreadsheet into command window
%
%
% Will only work if data grid is all same type


	p = inputParser;
	p.addParameter('Assign', true ,@islogical );
	p.parse(varargin{:});
	
	% Make sure labels are same size as data
	if length(labels) ~= length(data) %TODO: Flatten and reshape if wrong shape
		ddf = NaN;
		return;
	end
	
	% Create DDF I/O Object
	ddf = DDFIO;
	
	% For each column
	for c = 1:length(labels)
		
		% Add to DDF
		ddf.add(data(:, c), labels(c), "");
		
		% Assign to workspace
		if p.Results.Assign
			name = strrep(labels(c), " ", "_");
			name = strrep(name, string(char(9)), "_");
			
			assignin('base', name, data(:, c));
		end
		
	end

end