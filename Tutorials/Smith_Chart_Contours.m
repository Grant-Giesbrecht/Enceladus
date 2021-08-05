% Read File
%

mdf = AWRLPmdf;

% mdf.debug = true;
if ~mdf.load("LP_3053_4x100_DS3.mdf")
	displ("ERROR: ", mdf.msg)
	return;
end

displ(mdf.str());

mdf.showBlock(1);

% Break data out of the blocks into more easily usable form
%

data = mdf.getLPData();

smithplot(data.gamma(), 'LineStyle', 'none', 'Marker', '+');

