function [rows, cols, data] = trace_contiguous(data, seed)
% Called by find_contiguous_block. Should not be called by end user.


	% Get size of data
	[nr, nc] =  size(data);

	R = seed.row;
	C = seed.col;
	data(R, C).checked = true;
	
	% Return empty if cell not 'true'
	if ~data(R, C).val 
		rows = [];
		cols = [];
		return;
	end

	checkcells = [];
	
	%% Find all check cells
	
	% Row one lower
	if R > 1
		ns.row = R-1;
		ns.col = C;
		checkcells = addTo(checkcells, ns);
		if C < nc
			ns.col = C+1;
			checkcells = addTo(checkcells, ns);
		end
		if C > 1
			ns.col = C-1;
			checkcells = addTo(checkcells, ns);
		end
	end

	% Same row
	ns.row = R;
	if C < nc
		ns.col = C+1;
		checkcells = addTo(checkcells, ns);
	end
	if C > 1
		ns.col = C-1;
		checkcells = addTo(checkcells, ns);
	end

	% Row one higher
	if R < nr
		ns.row = R+1;
		ns.col = C;
		checkcells = addTo(checkcells, ns);
		if C < nc
			ns.col = C+1;
			checkcells = addTo(checkcells, ns);
		end
		if C > 1
			ns.col = C-1;
			checkcells = addTo(checkcells, ns);
		end
	end
	
	rows = [];
	cols = [];
	
	% Remove checked cells
	for cidx = numel(checkcells):-1:1
		if data(checkcells(cidx).row, checkcells(cidx).col).checked
			checkcells(cidx) = [];
		end
	end
	
	ccs = "";
	for cc = checkcells
		ccs = ccs + num2str(cc.row) + "," + num2str(cc.col) + " ";
	end
	
	

	%% Check each cell, add to list
	
	rows = R;
	cols = C;
	
	for cc = checkcells
		
		[tcr, tcc, newdata] = trace_contiguous(data, cc);
		rows = [rows, tcr];
		cols = [cols, tcc];
		data = newdata;
		
	end
	
% 	displ('Seed: ', R, ",", C);
% 	displ('   X: ', ccs);
% 	displ(' -->: ', rows);
% 	displ(' -->: ', cols);
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
end














