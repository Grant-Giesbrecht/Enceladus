filename = "LP_3053_4x100_DS3.mdf";

% Create MDF object
if ~exist('mdf', 'var') || ~isa(mdf.filename, class(filename)) || mdf.filename ~= filename

	mdf = AWRLPmdf;
	mdf.debug = false;

	% Read MDF file
	if ~mdf.load(filename)
		displ("ERROR: ", mdf.msg)
		return;
	end
end

lps = mdf.getLPSweep();