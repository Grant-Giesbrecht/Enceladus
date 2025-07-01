function ddf = cells2ddf(cells, varargin)
% Provided a 2D cell array, creates a series of vectors with names to
% represent the data

	% Configure input parser
	expectedPos = {'Horiz', 'Vert'};
	p = inputParser;
	p.addParameter('NamePos', 'Horiz' , @(x) any(validatestring(char(x),expectedPos)));
	p.addParameter('Assign', false , @islogical);
	p.addParameter('AppendDDF', [] , @(x) true);
	p.addParameter('VarNamePrefix', "" , @(x) true);
	p.parse(varargin{:});

	% Transpose cells if vertical
	if strcmp(p.Results.NamePos, 'Vert')
		cells = cells.';
	end
	
	if ~strcmpi(p.Results.VarNamePrefix, "")
		vnp = p.Results.VarNamePrefix + "_";
	else
		vnp = "";
	end
	
	% Get data size
	[r, c] = size(cells);
	
	% Pull off titles
	titles = [];
	for tc = cells(1,:)
		titles = addTo(titles, string(tc{1}));
	end

	% Ensure each value in each param/list have same type
	dataTypes = [];
	for col = 1:c
		
		% Get type of item in first row (below name)
		c_ij = cells(2, col);
		type = class(c_ij{1});
		
		% Save to list
		dataTypes = addTo(dataTypes, string(type));
		
		% For each row...
		for row = 3:r
			
			c_ij = cells(row, col);
			
			% Ensure all cells have same type...
			if ~isa(c_ij{1}, type)
				dataTypes(col) = "MISMATCH"; % Else save all as strings
				break;
			end
		end
		
	end
	
	% Initialize data cells
	data = {};
	for col = 1:c
		data{col} = [];
	end

	
	% Get corresponding data, convert from cell matrix to cell of 'type'
	% matrices
	for col = 1:c
		for row = 2:r
			
			c_ij = cells(row, col);
			
			if strcmp(dataTypes(col), "MISMATCH") || strcmp(dataTypes(col), "string") || strcmp(dataTypes(col), "char")
				val = string(c_ij{1});
			elseif strcmp(dataTypes(col), "double")
				if isa(c_ij{1}, 'string')
					val = str2double(c_ij{1});
				else
					val = double(c_ij{1});
				end			
			elseif strcmp(dataTypes(col), "logical")
				if isa(c_ij{1}, 'string')
					val = str2logical(c_ij{1});
				else
					val = logical(c_ij{1});
				end	
			else
				val = string(c_ij{1});
			end 
				
			
			data{col} = addTo(data{col}, val);
		end
	end
	
	% Assign in workspace
	if p.Results.Assign
		for i=1:c
			var_name = vnp + titles(i);
			var_name = strrep(var_name, " ", "_");
			var_name = strrep(var_name, "(", "");
			var_name = strrep(var_name, ")", "");
			var_name = strrep(var_name, "[", "");
			var_name = strrep(var_name, "]", "");
			var_name = strrep(var_name, "{", "");
			var_name = strrep(var_name, "}", "");
			var_name = strrep(var_name, ">", "");
			var_name = strrep(var_name, "<", "");
			var_name = strrep(var_name, string(char(9)), "_");
			assignin('base', var_name, data{i});
		end
	end
	
	% Get DDFIO Object
	if isempty(p.Results.AppendDDF)
		ddf = DDFIO;
	else
		
		if isa(p.Results.AppendDDF, 'DDFIO')
			ddf = p.Results.AppendDDF;
		else
			ddf = DDFIO;
		end
	end
	
	% Assign to DDF
	idx = 0;
	for t = titles
		idx = idx + 1;
		
		var_name = strrep(t, " ", "_");
		var_name = strrep(var_name, string(char(9)), "_");
		
		ddf.add(data{idx}, var_name, "");
		
	end

end