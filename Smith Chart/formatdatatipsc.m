function formatdatatipsc(ph, Z0)

	ph.DataTipTemplate.DataTipRows(1).Label = "R";
	ph.DataTipTemplate.DataTipRows(2).Label = "X";

	ph.DataTipTemplate.DataTipRows(1).Value = @(x,y) real(G2Z(complex(x, y), Z0));
	ph.DataTipTemplate.DataTipRows(2).Value = @(x,y) imag(G2Z(complex(x, y), Z0));
	
	row3 = dataTipTextRow('|\Gamma|', @(x, y) abs(complex(x, y)) );
	row4 = dataTipTextRow('\angle\Gamma', @(x, y) angle(complex(x, y)) );
	ph.DataTipTemplate.DataTipRows(end+1) = row3;
	ph.DataTipTemplate.DataTipRows(end+1) = row4;
end