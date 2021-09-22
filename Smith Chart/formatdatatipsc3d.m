function formatdatatipsc3d(ph, Z0, Z_axis_label, Z_func)

	if ~exist("Z_axis_label", 'var')
		Z_axis_label = "Z";
	end
	
	if ~exist('Z_func', 'var')
		Z_func = @(x, y, z) z;
	end

	ph.DataTipTemplate.DataTipRows(1).Label = "R";
	ph.DataTipTemplate.DataTipRows(2).Label = "X";
	ph.DataTipTemplate.DataTipRows(3).Label = '|\Gamma|';
	
	ph.DataTipTemplate.DataTipRows(1).Value = @(x,y,z) real(G2Z(complex(x, y), Z0));
	ph.DataTipTemplate.DataTipRows(2).Value = @(x,y,z) imag(G2Z(complex(x, y), Z0));
	ph.DataTipTemplate.DataTipRows(3).Value = @(x, y, z) abs(complex(x, y));
	
	row4 = dataTipTextRow('\angle\Gamma', @(x, y, z) angle(complex(x, y)) );
	row5 = dataTipTextRow(Z_axis_label, Z_func );
	
	ph.DataTipTemplate.DataTipRows(end+1) = row4;
	ph.DataTipTemplate.DataTipRows(end+1) = row5;
end