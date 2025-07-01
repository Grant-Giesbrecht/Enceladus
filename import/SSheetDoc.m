classdef SSheetDoc
	properties
		filename
		sheets
	end
	
	methods
		function obj = SSheetDoc(filename, use_format_sheet, save_as_format, use_name_prefix)
		%
		% filename - File to read in its entirety
		%
		% use_format_sheet - Look for a format sheet and use it to save data to the workspace
		%
		% save_as_format - Format in which to save the data (only
		% applicable if use_format_sheet = true. Options include 'var',
		% 'cells', and 'ddf'.
		%
		% use_name_prefix - Save name in variables assigned in worksapce.
		% Only applicable if save_as_format='var'.
		%
		
			% Check optional arguments
			if ~exist('use_format_sheet', 'var')
				use_format_sheet = false;
			end
			if ~exist('save_as_format', 'var')
				save_as_ddf = 'cells';
			end
			
			sheet_names = sheetnames(filename)';
			
			obj.filename = filename;
			
			for sn = sheet_names
				nss = SSheet('File', filename, 'Sheet', sn, 'LastCell', 'all');
				obj.sheets = addTo(obj.sheets, nss);
			end
			
			if use_format_sheet
				fmt = obj.getFormat();
				
				
				if ~exist('use_name_prefix', 'var')
					use_name_prefix = (numel(fmt) > 1);
				end
				
				obj.assignAllSpec(fmt, save_as_format, use_name_prefix);
			end
		end
		
		function fmt_specs = getFormat(obj)
		% Read data import specifications from sheet within file. The rules
		% for the format document are:
		%
		%	1. Sheet must be named MATLABFormat
		%	2. Column 1 must be named 'Name' and each row contains a name
		%	   for the described table/dataset.
		%	3. Column 2 must be named 'Sheet' and each row contains a sheet
		%      name (not sheet number).
		%	4. Column 3 must be named TL and each row contains a new
		%      top-left Excel coordinate (eg. B3)
		%	5. Column 4 must be named BR and each row contains a new
		%	   bottom-right Excel coordinate (eg. H8)
		%	6. The aforementioned naming requirements are not case
		%	   sensitive.
		%	7. Additional columns after BR are ignored, but additional rows
		%	   below the format table are not allowed.
		%
		% Returns the data as an array of structs
		
			
			found_sheet = false;
			
			for ss = obj.sheets
				if strcmpi(ss.sheet_name, "MATLABFormat")
					
					% Get dimensions of data
					[nfr, nfc] = size(ss.cells);
					
					% Ensure 4 columns exist and at least 2 rows
					if nfc < 4 && nfr < 2
						break;
					end
					
					% Check column names
					if ~strcmpi(ss.cells{1,1}, 'Name')
						break;
					end
					if ~strcmpi(ss.cells{1,2}, 'Sheet')
						break;
					end
					if ~strcmpi(ss.cells{1,3}, 'TL')
						break;
					end
					if ~strcmpi(ss.cells{1,4}, 'BR')
						break;
					end
					
					found_sheet = true;
					
					fmt_data.name = "";
					fmt_data.sheet = "";
					fmt_data.TL = "";
					fmt_data.BR = "";
					fmt_specs = repmat(fmt_data, 1, nfr-1);
					
					for fsi = 1:nfr-1
						fmt_specs(fsi).name = ss.cells{fsi+1, 1};
						fmt_specs(fsi).sheet = ss.cells{fsi+1, 2};
						fmt_specs(fsi).TL = ss.cells{fsi+1, 3};
						fmt_specs(fsi).BR = ss.cells{fsi+1, 4};
					end
					
% 					assignin('base', 'format_specs', fmt_specs);
					
				end
			end
			
			if ~found_sheet
				warning("Failed to find MATLAB formatting sheet");
			end
		end
		
		function cr = spec2range(obj, fmt)
		% Takes a format struct (from getFormat, which gets the format from
		% the spreadsheet itself) and returns a range of data from it.
			
			% Find sheet
			for ss = obj.sheets
				if strcmpi(ss.sheet_name, fmt.sheet)
					
					% Return range
					cr = ss.range(string(fmt.TL)+":"+string(fmt.BR));
				end
			end
			
		end
		
		function assignAllSpec(obj, fmts, save_as_format, use_name_prefix)
		% Takes a format struct, or list of format structs (from getFormat)
		% and assigns all specified formats' data cells to the workspace.
		%
		% fmts - List of format specifier structs to define ranges to
		% extract
		%
		% save_as_format - String represeting the format for the data saved
		% to the workspace. Options include 'var', 'cells', and 'ddf'.
		%
		% use_name_prefix - Option to save format_spec name to variable
		% names to differentiate between similar variables between multiple
		% format specs. Only applicable when save_as_format = 'var'.
		%
			if ~exist('save_as_format', 'var')
				save_as_format = 'cells';
			end
			
			if ~exist('use_name_prefix', 'var')
				use_name_prefix = (numel(fmts) > 1);
			end

			prefix = "";
			
			for fmt = fmts
				
				% Add prefix if requested
				if use_name_prefix
					prefix = fmt.name;
				end
				
				cr = obj.spec2range(fmt);
				fixed_name = strrep(fmt.name, ' ', '_');
				
				% Convert to DDF if requested
				if strcmpi(save_as_format, 'DDF') % Save as DDF object
					cr = cells2ddf(cr);
					assignin('base', fixed_name, cr);
				elseif strcmpi(save_as_format, 'var') % Save as variables in workspace
					cells2wkspc(cr, prefix);
				elseif strcmpi(save_as_format, 'cells') % Save as cell array
					assignin('base', fixed_name, cr);
				end
				
				
			end
			
		end
		
	end
	
end