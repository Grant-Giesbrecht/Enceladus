mdf = AWRLPmdf;


mdf.debug = true;
if ~mdf.load("LP_Data_L1_Dev.mdf")
	displ("ERROR: ", mdf.msg)
else
	displ(mdf.str());
end

