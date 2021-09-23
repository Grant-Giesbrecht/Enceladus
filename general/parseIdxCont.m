function words=parseIdxCont(input, delims, addToList, startIdx)

	if isempty(input)
		words=addToList;
		return;
	end

	original = input;

	quit = 0;
	
	%Convert inputs to character arrays for processing
	input=char(input);
	delims=char(delims);
	
	%Find first hit for each delim
	hits = [];
	for c=delims
		%Find one match, first match
		idx=find(input==c, 1, 'first');
		
		%If no matches, will be 1x0 array - change to value NaN to say 'no
		%position'.
		if isempty(idx)
			idx = NaN;
		end
		
		%Add to list of hits
		if isempty(hits)
			hits = idx;
		else
			hits(end+1) = idx;
		end		
	end
		
	
	%Take earliest hit, split word
	min_val = min(hits);
	delim_idx_min = find(hits==min_val, 1, 'first');
	break_char = delims(delim_idx_min);
	
	if isempty(break_char)
		idx_min = NaN;
	else
		idx_min = find(input==break_char, 1, 'first');
	end
	
	
	if (idx_min ~= 1)
		
		if isnan(idx_min)
			quit = 1;
			newWord = StringIdx( input(1:end), startIdx);
		else
			newWord = StringIdx( input(1:idx_min-1), startIdx);
		end
		
		if isempty(addToList)
			addToList = newWord;
		else
			addToList(end+1) = newWord;
		end
	end
	
	if isnan(idx_min)
		words = addToList;
		return;
	end
	
	input = input(idx_min+1:end);
	
	startIdx = startIdx + idx_min;
	
	%Add it to list, trim string, call again
	if quit
		words = addToList;
	else
		words = parseIdxCont(input, delims, addToList, startIdx);
	end
	
end