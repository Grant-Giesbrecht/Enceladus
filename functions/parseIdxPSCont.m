function words=parseIdxPSCont(input, delims, addToList, startIdx)
	
	if isempty(input)
		words=addToList;
		return;
	end

	%Convert inputs to character arrays for processing
	original = input;
	input=char(input);
	delims=char(delims);

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
	
	%Find first hit for each delim
	hits = [];
	for c=delims
		
		
		%Find delim hits until one is not in a string (as identified in
		%'pairs').
		idx_offset = 0;
		input_scan = input;
		while true
			
			remain = false;
			
			%Find one match, first match
			idx=find(input_scan==c, 1, 'first');
			
			%Break if no match found
			if isempty(idx)
				break;
			end
			
			idx = idx + idx_offset;
			
			%Scan through strings, check delim isn't in string
			for p=pairs
				
				%True if is in string
				if idx > p.a && idx < p.b
					idx_offset = idx; %Update offset variable
					input_scan = input_scan(idx+1:end); %Trim this first delim
					remain = true; %Indicate that you must remain in loop
				end
			end
			
			%Exit when delim found outside of string
			if ~remain
				break;
			end
			
		end
		
		
		
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
% 	min_val = min(hits);
% 	delim_idx_min = find(hits==min_val, 1, 'first');
% 	break_char = delims(delim_idx_min);
	
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