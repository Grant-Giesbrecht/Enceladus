function breakWith(varargin)

	kvf = NaN;
	hasKv = false;
	break_idxs = [];

	untitled_counter = 0;
	
	for id = 1:nargin
		
		x = varargin{id};
		name = inputname(id);
	
		%Unnamed data was passed to function, make a name
		if isempty(name)
			name = strcat("untitled", string(untitled_counter));
			untitled_counter = untitled_counter + 1;
		end
		
		%Check if input is KvFile object
		if class(x) == 'KvFile'
			kvf = x;
			hasKv = true;
			continue;
		end
		
		%Is the break variable, record the break points
		if isempty(break_idxs)
			
			%Get indecies where value changes
			break_idxs = find(diff(x)~=0);
			
			%Record length
			l_bv = length(x);
			
			%Create variables for each value
			count = 1;
			for i=break_idxs
				
				%Create new name
				newname = strcat(name, "_", string(count));
				assignin('base', newname, x(i));
				disp(strcat("Adding ", newname));
				
				%If KvFile provided, add variable to object
				if hasKv
					kvf.add(x(i), newname, "");
				end
				
				count = count + 1;
			end
			%Create new name
			newname = strcat(name, "_", string(count));
			assignin('base', newname, x(end));
			disp(strcat("Adding ", newname));
			%If KvFile provided, add variable to object
			if hasKv
				kvf.add(x(end), newname, "");
			end
			
		else %Is not the break variable, break at each point
			
			%Verify length matches
			if length(x) ~= l_bv
				disp(strcat("Cannot add variable '", name, "'. Length does not match."));
			end
			
			%For each break index
			last_idx = 0;
			for i=1:length(break_idxs)
				
				
				if i == 1 %Handle start case
					nv = x(1:break_idxs(i));							
				else %Handle middle cases
					nv = x(break_idxs(i-1)+1:break_idxs(i));
				end
				
				%Create new name for broken-up variable
				newname = strcat(name, "_", string(i));
				
				%Create variable
				assignin('base', newname, nv);
				disp(strcat("Adding ", newname));
				
				%If KvFile provided, add variable to object
				if hasKv
					kvf.add(nv, newname, "");
				end
				
				last_idx = break_idxs(i);
			end
			
			nv = x(last_idx+1:end);
			newname = strcat(name, "_", string(length(break_idxs)+1));
			assignin('base', newname, nv);
			disp(strcat("Adding ", newname));
			
			%If KvFile provided, add variable to object
			if hasKv
				kvf.add(nv, newname, "");
			end
				
			
		end
		
		
	end

end