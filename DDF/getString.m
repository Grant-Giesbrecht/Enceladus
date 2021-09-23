function out=getString(str)

	str = char(str);

	escapes = find(str=='\');
	quotes = find(str=='"');
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

	%Return empty if no quote present
	if isempty(se_quotes) || length(se_quotes) < 2
		out=[];
		return;
	end
	
	startIdx = se_quotes(1);
	endIdx = se_quotes(2);
	si = StringIdx(str(startIdx:endIdx), endIdx);
	si.sidx = startIdx;
	out = si;
	
end