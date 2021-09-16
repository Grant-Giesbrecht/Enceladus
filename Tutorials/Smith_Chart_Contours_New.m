% Create MDF object
mdf = AWRLPmdf;
mdf.debug = false;

% Read MDF file
if ~mdf.load("LP_3053_4x100_DS3.mdf")
	displ("ERROR: ", mdf.msg)
	return;
end

lp = mdf.getLoadPull();

figure(1);
contoursc(lp.gamma(), lp.p_load());