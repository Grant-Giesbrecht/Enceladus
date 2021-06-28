ss = SSheet('File', "DemoSpreadsheet.xlsx", 'LastCell', 'D14');
ss2 = SSheet('File', "DemoSpreadsheet.xlsx", 'LastCell', 'D14', 'Sheet', 'Day 2');

s1data = ss.range("A2:D5");
s2data = ss.range("A11:D14");

s3data = ss2.range("A4:C8");

ddf = cells2ddf(s3data);
ddf = cells2ddf(s1data, 'AppendDDF', ddf);
ddf.show();