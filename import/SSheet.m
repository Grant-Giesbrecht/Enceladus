classdef SSheet < handle
	
	properties
		cells
		filename
		sheet_name
	end
	
	methods
		
		function obj = SSheet(varargin)
			
			p = inputParser;
			p.addParameter('Data', {}, @iscell);
			p.addParameter('File', "", @(x) isstring(x) || ischar(x));
			p.addParameter('LastCell', "all", @(x) isstring(x) || ischar(x));
			p.addParameter('Sheet', "", @(x) isstring(x) || ischar(x));
			p.parse(varargin{:});
			
			obj.cells = {};
			
			% If cell provided
			if numel(p.Results.Data) > 0
				obj.cells = p.Results.Data;
			end
			
			% If file provided
			if ~strcmp(p.Results.File, "")
				
				obj.filename = p.Results.File;
				obj.sheet_name = p.Results.Sheet;
				
				trc = "A1"; % Changing this will break indexing later
				
				names = [];
				[br_let, br_num] = SSheet.splitExcelAddr(p.Results.LastCell);
				for i=1:SSheet.xlcol2num(br_let)
					names = addTo(names, string(SSheet.num2xlcol(i)));
				end
				
				% Create import options
% 				opt = spreadsheetImportOptions;
				opt = detectImportOptions("DemoSpreadsheet.xlsx")
				if ~strcmp(p.Results.LastCell, "all")
					opt.VariableNames = names; % Must change number of variable names before adjusting data range or will throw error
					opt.DataRange = strcat(trc, ":", p.Results.LastCell);
				else
					opt.DataRange = 'A1';
				end
				opt.Sheet = p.Results.Sheet;
				
				obj.cells = readcell(p.Results.File, opt);
			end
			
		end
		
		function rdata = range(obj, tl_br)
			
			[topLeft, botRight] = SSheet.splitExcelRange(tl_br);
			[tl_c, tl_r] = SSheet.splitExcelAddr(topLeft);
			[br_c, br_r] = SSheet.splitExcelAddr(botRight);
			
			tl_c = SSheet.xlcol2num(tl_c);
			br_c = SSheet.xlcol2num(br_c);
			
			rdata = obj.cells(tl_r:br_r, tl_c:br_c);
			
		end
		
		function rdata = autorange(obj, seedcell)
			
			seedrow = -1;
			seedcol = -1;
			
			pop = obj.getPopulated();
			
			% Check if autofind seed
			if ~exist('seedcell', 'var')
				seedcell = 'auto';
			end
			
			% Auto-seed if requested
			if strcmpi(seedcell, 'auto')
				idx1 = find(pop, 1, 'first');
				
				% If all missing
				if isempty(idx1)
					rdata = [];
				end
				
				[r1,c1] = ind2sub(size(pop), idx1);
				seedcell = [char(SSheet.num2xlcol(c1)), char(num2str(r1))];
				
				seedrow = r1;
				seedcol = c1;
			else
				[seedrow, seedcol] = SSheet.excelAddr2RC(seedcell);
			end
			
			% Find contiguous block
			[tl, br] = find_contiguous_block(pop, seedrow, seedcol);
			
			tl_c = tl.col;
			tl_r = tl.row;
			br_c = br.col;
			br_r = br.row;
			
			
			
			
			
% 			[topLeft, botRight] = SSheet.splitExcelRange(tl_br);
% 			[tl_c, tl_r] = SSheet.splitExcelAddr(topLeft);
% 			[br_c, br_r] = SSheet.splitExcelAddr(botRight);
% 			
% 			tl_c = SSheet.xlcol2num(tl_c);
% 			br_c = SSheet.xlcol2num(br_c);
			
			rdata = obj.cells(tl_r:br_r, tl_c:br_c);
			
		end
		
		function pop = getPopulated(obj)
			% Show which cells are populated (true) vs missing (false)
			
			[nrows, ncols] = size(obj.cells);
			
			pop = false(nrows, ncols);
			
			% Loop over all, check if populated
			for r = 1:nrows
				for c = 1:ncols
					pop(r,c) = ~isa(obj.cells{r,c}, 'missing');
				end
			end
			
		end
			
		
	end
	
	methods (Static)
		
		function xlcol_num=xlcol2num(xlcol_addr)
		% By Praveen Bulusu on MathWorks Answers. Accessed 26-6-2021
		% Modified by G. Giesbrecht
		%
		% https://www.mathworks.com/matlabcentral/answers/248797-i-need-to-convert-a-number-into-its-column-name-equivalent
		
		% xlcol_addr - upper case character
		
			% Ensure input is char vec and upper case
			xlcol_addr = char(xlcol_addr);
			xlcol_addr = upper(xlcol_addr);
		
			if ~any(~isstrprop(xlcol_addr,"alpha"))
				xlcol_num=0;
				n=length(xlcol_addr);
				for k=1:n
					xlcol_num=xlcol_num+(double(xlcol_addr(k)-64))*26^(n-k);
				end
			else
				error(strcat("ERROR: '", xlcol_addr, "' is not a valid character"));
			end
		end
		
		function xlcol_addr=num2xlcol(col_num)
		% By Praveen Bulusu on MathWorks Answers. Accessed 27-6-2021
		%
		% https://www.mathworks.com/matlabcentral/answers/248797-i-need-to-convert-a-number-into-its-column-name-equivalent
		
		% col_num - positive integer greater than zero
			n=1;
			while col_num>26*(26^n-1)/25
				n=n+1;
			end
			base_26=zeros(1,n);
			tmp_var=-1+col_num-26*(26^(n-1)-1)/25;
			for k=1:n
				divisor=26^(n-k);
				remainder=mod(tmp_var,divisor);
				base_26(k)=65+(tmp_var-remainder)/divisor;
				tmp_var=remainder;
			end
			xlcol_addr=char(base_26); % Character vector of xlcol address
		end
		
		function [tl, br] = splitExcelRange(rangeStr)
			
			rangeStr = char(rangeStr);
			idx = find(rangeStr==':', 1, 'First');
			tl = rangeStr(1:idx-1);
			br = rangeStr(idx+1:end);
			
		end
		
		function [let, num] = splitExcelAddr(addrStr)
			
			addrStr = char(addrStr);
			
			idx = 1;
			for c = addrStr
				if  isstrprop(c,'digit')
					break;
				end
				idx = idx + 1;
			end
			num = str2double(addrStr(idx:end));
			let = addrStr(1:idx-1);
			
		end
		
		function [r,c] = excelAddr2RC(addrStr)
			
			[let, r] = SSheet.splitExcelAddr(addrStr);
			c = SSheet.xlcol2num(let);
			
		end
		
	end
	
end