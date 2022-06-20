classdef SSheetDoc
	properties
		filename
		sheets
	end
	
	
	methods
		function obj = SSheetDoc(filename)
			sheet_names = sheetnames(filename)';
			
			obj.filename = filename;
			
			for sn = sheet_names
				nss = SSheet('File', filename, 'Sheet', sn, 'LastCell', 'all');
				obj.sheets = addTo(obj.sheets, nss);
			end
		end
	end
	
end