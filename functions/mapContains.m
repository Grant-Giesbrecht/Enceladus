function tf=mapContains(M, k)

	tf = ~isempty(find(contains(M.keys, k)));

end