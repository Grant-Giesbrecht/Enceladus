% Create MDF object
mdf = AWRLPmdf;
mdf.debug = false;

% Read MDF file
if ~mdf.load("LP_3053_4x100_DS3.mdf")
	displ("ERROR: ", mdf.msg)
	return;
end

lps = mdf.getLPSweep();