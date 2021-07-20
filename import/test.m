trc = "A1"; % Changing this will break indexing later
			
last_cell = "D14";

names = [];
for i=1:SSheet.xlcol2num(last_cell)
	names = addTo(names, SSheet.num2xlcol(i));
end

% Create import options
opt = spreadsheetImportOptions;
opt.VariableNames = names; % Must change number of variable names before adjusting data range or will throw error
opt.DataRange = strcat(trc, ":", last_cell);

obj.cells = readcell("DemoSpreadsheet.xlsx", opt);