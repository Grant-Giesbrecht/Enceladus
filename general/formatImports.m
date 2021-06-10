function formatImports(varargin)

	kvf = NaN;
	kvf_name = "";
	hasKv = false;
	deletes = [];
	svv = []
	
	isSplitVecVar = false
	
	%For each input arugment
	for id = 1:nargin
		x = varargin{id};
		name = inputname(id);
	
		%If found keyword
		if x == "splitVec"
			
			%MArk to delete keyword
			if isempty(deletes)
				deletes = id;
			else
				deletes(end+1) = id;
			end
			continue;
		end
		
		%If found variable for splitting stuff
		if splitVecVar
			svv = x;
			splitVecVar = false;
			
			%Mark to delete keyword
			if isempty(deletes)
				deletes = id;
			else
				deletes(end+1) = id;
			end
		end
		
	end
	
	%Delete cells
	for i=length(deletes):-1:1
		varargin{i} = [];
	end
	
	%Run breakWith if requried
	if ~isempty(svv)
		breakWith(svv, varargin)
	end
	
	
	
end