function cells2wkspc(cells, VarNamePrefix)

	if ~exist('VarNamePrefix', 'var')
		VarNamePrefix = "";
	end

	cells2ddf(cells, 'Assign', true, 'VarNamePrefix', VarNamePrefix);

end