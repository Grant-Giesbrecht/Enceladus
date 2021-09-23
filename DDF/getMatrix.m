function [val, lastIdx]=getMatrix(str, mat_type)

	mat_type = string(mat_type);
	str = char(str);

	closes = find(str==']', 1, 'first');
	opens = find(str=='[', 1, 'first');
	
	% Return -1 as lastIdx if can't find matrix
	if isempty(closes) || isempty(opens)
		val="Failed to find open and close bracket pair.";
		lastIdx=-1;
		return;
	end
	
	% Set last index
	lastIdx = closes(1);
	
	%get stuff composing matrix
	matstr = str(opens(1)+1:closes(1)-1);
	
	%Get each row
	rows = parseIdx(matstr, ";", true);
	
	newmat = [];
	
	%For each row
	for r=rows
		
		newrow = [];
		
		%Get each elemnt
		elements = parseIdx(r.str, ",");
		
		%For each element
		for e=elements
			
			e_str = strtrim(e.str);
			
			%Get element value, convert from string
			if mat_type == "d"
				eval = str2double(e_str);
			elseif mat_type == "b"
				eval = str2logical(e_str);
			elseif mat_type == "s"
				cstr = char(e_str);
				eval = string(cstr(2:end-1));
			else
				lastIdx = -1;
				val = strcat("Unrecognized type '", mat_type, "'.");
				return;
			end
			
			%Save value to row
			if isempty(newrow)
				newrow = eval;
			else
				newrow(end+1) = eval;
			end
			
		end
		
		%Save row to matrix
		if isempty(newmat)
			newmat = newrow;
		else
			newmat = [newmat ; newrow];
		end
		
		
	end
	
	val=newmat;
	
end