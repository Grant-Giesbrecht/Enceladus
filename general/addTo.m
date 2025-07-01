function nl=addTo(list, item)
% ADDTO Adds an item to a list and returns the new list
%
%	NL = ADDTO(LIST, ITEM) Adds item to the end of the list.

	if isempty(list)
		list = item;
	else
		list(end+1) = item;
	end
	
	nl = list;

end