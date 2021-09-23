function eq = compareDDFI(A, B, varargin)

	loose_desc = false;

	if nargin > 2
		if string(varargin{1}) == "LooseDesc"
			loose_desc = true;
		end
		if string(varargin{1}) == "StrictDesc"
			loose_desc = false;
		end
	end
	
	if A.type ~= B.type
		eq = false;
		return;
	elseif A.dimension ~= B.dimension
		eq = false;
		return;
	elseif A.val ~= B.val
		eq = false;
		return;
	elseif A.name ~= B.name
		eq = false;
		return;
	elseif ~loose_desc && A.desc ~= B.desc
		eq = false;
		return;
	elseif loose_desc && strtrim(A.desc) ~= strtrim(B.desc)
		eq = false;
		return;
	elseif A.count ~= B.count
		eq = false;
		return;
	elseif A.isnotfound ~= B.isnotfound
		eq = false;
		return;
	end
	
	eq = true;

end