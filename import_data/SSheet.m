classdef SSheet < handle
	
	properties
		cells
	end
	
	methods
		
		function obj = SSheet(nc)
			obj.cells = nc;
		end
		
		function rdata = range(obj, tl_br)
			
			tl_br = char(tl_br);
			
			idx = find(tl_br==':', 1, 'First');
			tl = tl_br(1:idx-1);
			br = tl_br(idx+1:end);
			
			% Get char arrays
			tlc = char(tl);
			brc = char(br);
			
			% Find where becomes numeric in TLC
			idx = 1;
			for c = tlc
				if  isstrprop(c,'digit')
					break;
				end
				idx = idx + 1;
			end
			tl_r = str2double(tlc(idx:end));
			tl_c = SSheet.xlcol2num(tlc(1:idx-1));
			
			% Find where becomes numeric in TLC
			idx = 1;
			for c = brc
				if  isstrprop(c,'digit')
					break;
				end
				idx = idx + 1;
			end
			br_r = str2double(brc(idx:end));
			br_c = SSheet.xlcol2num(brc(1:idx-1));
			
			
			rdata = obj.cells(tl_r:br_r, tl_c:br_c);
			
			
		end
	end
	
	methods (Static)
		
		function xlcol_num=xlcol2num(xlcol_addr)
		% By Praveen Bulusu on MathWorks Answers. Accessed 26-6-2021
		%
		% https://www.mathworks.com/matlabcentral/answers/248797-i-need-to-convert-a-number-into-its-column-name-equivalent
		
		% xlcol_addr - upper case character
			if ischar(xlcol_addr) && ~any(~isstrprop(xlcol_addr,"upper"))
				xlcol_num=0;
				n=length(xlcol_addr);
				for k=1:n
					xlcol_num=xlcol_num+(double(xlcol_addr(k)-64))*26^(n-k);
				end
			else
				error('not a valid character')
			end
		end
		
	end
	
end