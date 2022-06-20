% Read entire spreadsheet
ssdoc = SSheetDoc("DemoSpreadsheet.xlsx");

% Get first sheet
s1 = ssdoc.sheets(1);
% s3 = ssdoc.sheets(3);

s3 = SSheet('file', "DemoSpreadsheet.xlsx", 'Sheet', 'S3', 'LastCell', 'J13');

s3table = s3.autorange('E5');
