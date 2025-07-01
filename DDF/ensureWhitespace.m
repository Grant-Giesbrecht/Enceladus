function out=ensureWhitespace(in, targets)

	%Ensure input is a string
	in=char(in);
	targets = char(targets);

	%Repeat process for each target
	for t=targets
		
		%Find next hit
		positions = find(in==t);
		
		for pos_idx=1:length(positions)
			
			pos = positions(pos_idx);
			
			%If no targets, break loop, move to next target
			if isempty(pos)
				break;
			end
			
			%If there is a preceeding character and it is not a space, add
			%one
			if (pos > 1) && (~isspace(in(pos-1)))
				in = char(strcat(in(1:pos-1), " ", in(pos:end)));
				pos = pos+1;
				positions = positions+1;
			end
			
			%If there is a following character and it is not a space, add
			%one.
			if (pos < length(in)) && (~isspace(in(pos+1)))
				in = char(strcat(in(1:pos), " ", in(pos+1:end)));
				positions = positions+1;
			end
			
		end
		
	end
	
	out = in;
	
end