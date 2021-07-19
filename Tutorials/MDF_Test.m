mdf = AWRLPmdf;


% mdf.debug = true;
if ~mdf.load("LP_Data_L1_Dev.mdf")
	displ("ERROR: ", mdf.msg)
	return;
end

displ(mdf.str());

mdf.showBlock(1);

b1 = mdf.bdata{1};



