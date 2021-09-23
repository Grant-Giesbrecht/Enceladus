dff_base = DDFIO;

% ************************* COMMENTS AND DESCRIPTION TEST *****************

%Add neccesary variables to baseline
dff_base.clear();
dff_base = DDFIO("ex_base.ddf");
dff_base.add("This is // des//igned to be? trickier", "A", "Tricky!");
dff_base.add(false, "B", "Desc ");
dff_base.get("moons").desc = "Not all moons ";
dff_base.get("baz").desc = "Nons[ense] word ";

%Read in 'ex_comments_desc.ddf'
ddf_descom = DDFIO("ex_comments_desc.ddf");

if compareDDF(ddf_descom, dff_base, 'LooseDesc')
	disp("Passed comments and description test");
else
	disp("Failed comments and descrition test");
end
% compareDDF(ddf_descom, dff)

%********************************* MATRICES TEST **************************

dff_base.clear();
dff_base = DDFIO("ex_base.ddf");
dff_base.add(["This is a ; test string//", "This string is ont the same row"; "This string is on a new row", "This string is also on the 2nd row //;"], "string_test", "string desc");
dff_base.add([true, false;false, true], "bool_test", "bool desc");

ddf_mat = DDFIO("ex_matrix.ddf");

if compareDDF(ddf_mat, dff_base, 'LooseDesc')
	disp("Passed matrix test");
else
	disp("Failed matrix test");
end







function eq = compareDDF(A, B, varargin)

	desc_mode = 'StrictDesc'; %Require exact match

	if nargin > 2
		if string(varargin{1}) == "LooseDesc" %Allow whitepsace on edges to mismatch
			desc_mode = 'LooseDesc';
		end
		if string(varargin{1}) == "StrictDesc"
			desc_mode = 'StrictDesc';
		end
	end

	for v = A.varsFlat
		if ~compareDDFI(v, B.get(v.name), desc_mode)
			disp("Failed to match:")
			disp(v);
			disp("and")
			disp(B.get(v.name))
			eq = false;
			return;
		end
	end
	
	for v = A.vars1D
		if ~compareDDFI(v, B.get(v.name), desc_mode)
			eq = false;
			return;
		end
	end
	
	for v = A.vars2D
		if ~compareDDFI(v, B.get(v.name), desc_mode)
			eq = false;
			return;
		end
	end
	
	eq = true;
end

