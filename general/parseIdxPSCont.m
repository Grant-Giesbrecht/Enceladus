function words=parseIdxPSCont(input, delims, addToList, startIdx)
	
	if isempty(input)
		words=addToList;
		return;
	end

	%Convert inputs to character arrays for processing
	original = input;
	input=char(input);
	delims=char(delims);
	
	%Trim deliminators from beginnning
	while contains(delims, input(1))
		input = input(2:end);
		startIdx = startIdx + 1;
		
		%Check for empty strings again, in case input was only deliminators
		if isempty(input)
			words=addToList;
			return;
		end
	end
	
	escapes = find(input=='\');
	quotes = find(input=='"');
	se_quotes = []; % list of start or end (string) quotes
	for i=1:length(quotes)
		
		%If index before index of quote *is not* found in escapes, this
		%quote is *not* escaped and thus is added to the list of
		%legitamate quotes
		if isempty(find(escapes == (quotes(i)-1))) 
			if isempty(se_quotes)
				se_quotes = quotes(i);
			else
				se_quotes(end+1) = quotes(i);
			end
		end
	end
	
	%Find indeces covered by quote pairs
	pairs = [];
	for i=1:2:length(se_quotes)
		if i+1 <= length(se_quotes)
			tempc = twople(se_quotes(i),se_quotes(i+1));
			if isempty(pairs)
				pairs = tempc;
			else
				pairs(end+1) = tempc;
			end
		end
	end

	

	quit = 0;
	
	hits = [];
	all_true_delim_idxs = [];
	for c=delims
		
		%Find all hits for that delim
		all_idxs = find(input == c);
		
		%Add to 'all_true_delim_idxs' if not in detected string
		for ai=all_idxs
			
			in_string = false;
			
			%Check if in any string pair
			for p=pairs
				%True if is in string
				if ai > p.a && ai < p.b
					in_string = true;
					break
				end
			end
			
			%Add if not in any string
			if ~in_string
				if isempty(all_true_delim_idxs)
					all_true_delim_idxs = ai;
				else
					all_true_delim_idxs(end+1) = ai;
				end
			end
		end
		
		val = NaN;
		if ~isempty(all_true_delim_idxs)
			val = min(all_true_delim_idxs);
		end
		
		if isempty(hits)
			hits = val;
		else
			hits(end+1) = val;
		end
		
	end

	
	if isempty(hits)
		idx_min = NaN;
	else
% 		idx_min = find(input==break_char, 1, 'first');
		idx_min = min(hits);
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
		words = parseIdxPSCont(input, delims, addToList, startIdx);
	end
	
end