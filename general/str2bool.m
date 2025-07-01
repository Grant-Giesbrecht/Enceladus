function tf = str2bool(s)

	s = char(s);

	tf = strcmpi(s, "true");
	
end