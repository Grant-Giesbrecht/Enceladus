%% Read File
%

mdf = AWRLPmdf;

% mdf.debug = true;
if ~mdf.load("LP_Data_L1_Dev.mdf")
	displ("ERROR: ", mdf.msg)
	return;
end

%% Show some data
%

displ(mdf.str());

mdf.showBlock(1);

b1 = mdf.bdata{1};

%% Plot Harmonics
%

a2s = [];
b2s = [];
for idx = 1:length(mdf.bdata)

	aidx = mdf.bdataIndex("a2(3)");
	bidx = mdf.bdataIndex("b2(3)");
	
	avar = mdf.bdata{idx}(aidx);
	bvar = mdf.bdata{idx}(bidx);
	
	a2s = addTo(a2s, avar.data(1, 1) + avar.data(1, 2)*sqrt(-1));
	b2s = addTo(b2s, bvar.data(1, 1) + bvar.data(1, 2)*sqrt(-1));
	
end

smithplot(ab2gamma(a2s, b2s), 'LineStyle', 'none', 'Marker', '+');

