%% Use Format Page in Excel Spreadsheet
%
% If the spreadsheet was created with MATLAB in mind, a format sheet can be
% added which takes all the guess work out of importing data. However, if
% the sheet is constantly updated, the range in the format sheet must be
% updated as well, or some data will be missing.
%
% In this example, there is more data than represented in the format page.
% The autorange example below will detect this, whereas using the format
% page (as done in this example) is blind to this fact. Both approaches
% have their benefits.
%
% The format page allows complicated spreadsheets to be read, even if the
% entire block's format would confuse cells2ddf when detected by autorange.

% Read Excel spreadsheet, do save the variables to the workspace, and
% format them as variables (not cells or DDF).
doc = SSheetDoc("DummyData.xlsx", true, "var");

% Plot data
figure(1);
hold off;
plot(Time_s, V1, 'LineStyle', ':', 'Marker', '+', 'LineWidth', 1.3);
hold on;
plot(Time_s, V2, 'LineStyle', ':', 'Marker', '+', 'LineWidth', 1.3);
grid on;

%% Use Autorange to Read Spreadsheet
%
% Alternatively, the autorange function will read an entire block of data
% without requiring some predefined range. This flexibility comes at a
% cost, though. If other columns are added with text, labels, notes, etc 
% that cannot be correctly interpreted by the cells2ddf function (which is
% somewhat rudimentary), then this technique will not work properly and
% either a custom script or format page must be used.

% Read document, do not use the format sheet
autodoc = SSheetDoc("DummyData.xlsx");

% Get first sheet
s1 = autodoc.sheets(1);

% Get DDF and assign variables. Add prefix 'auto', so its distinguishable
% from first example.
ddf = cells2ddf(s1.autorange(), 'Assign', true, 'VarNamePrefix', 'auto');

% Plot data
figure(2)
hold off;
plot(auto_Time_s, auto_V1, 'LineStyle', ':', 'Marker', '+', 'LineWidth', 1.3);
hold on;
plot(auto_Time_s, auto_V2, 'LineStyle', ':', 'Marker', '+', 'LineWidth', 1.3);
grid on;