% Read entire spreadsheet
ssdoc = SSheetDoc("DemoSpreadsheet.xlsx");

% Get first sheet
s1 = ssdoc.sheets(1);

% Get third sheet
s3 = ssdoc.sheets(3);

% The 3rd sheet could also be read directly, without reading all document
% sheets, by sing SSheet instead of SSheetDoc. This is identical, SSheetDoc
% just provides an automatic way of detecting all sheets, but it calls
% SSheet to perform the dirty work.
s3alt = SSheet('file', "DemoSpreadsheet.xlsx", 'Sheet', 'S3', 'LastCell', 'J13');

% Automatically grab all s3table contents
s3table = s3.autorange('E5');

% This will behave just as the autorange call above. If no seed cell is
% provided, the top-left most populated cell will be used as the seed.
s3table2 = s3.autorange();

% Convert the auto-selected table to a DDF. Note that the missing cells and
% title will disrupt the conversion process and the result will not be
% usable.
s3ddf = cells2ddf(s3.autorange());

% Grab a range of data, with manual ranging. This data only has labels and
% numbers.
s3mr = s3.range('E3:G7')

% The correctly formatted manual ranged data can be converted to DDF.
s3mrddf = cells2ddf(s3mr);
s3mrddf.show();

% The spreadsheet document can include a MATLAB format sheet, specifying
% how to automatically import the data with the intended format. A struct
% is read from this sheet using this function:
fmt_spec = ssdoc.getFormat();

% You can get a cell range with a format
fsr = ssdoc.struct2range(fmt_spec(1));

% You can also automatically save all to the workspace
ssdoc.assignAllStruct(fmt_spec);








