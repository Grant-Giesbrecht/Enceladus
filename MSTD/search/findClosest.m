function idx = findClosest(list, val)
	mv = min(abs(val-list));
	idx = find(abs(val-list) == mv);
end