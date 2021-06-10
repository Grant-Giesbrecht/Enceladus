function tf=mapContains(M, k)
% TODO: Replace this function with M.isKey(k). isKey is built-in and does
% the exact same thing!

	tf = ~isempty(find(contains(M.keys, k)));
	warning("MSTD DEPRECATION NOTICE: Replace the function mapContains() with <map>.isKey(<key>)!");

end