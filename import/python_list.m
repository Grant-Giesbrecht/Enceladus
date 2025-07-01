function s = python_list(x)
	% Returns a string that works for creating a python list.
	
	first = true;
	s = "[";
	for val = x
		if ~first
			s = s + ", ";
		end
		s = s + num2str(val);
		first = false;
	end
	
	s = s + "]";
end