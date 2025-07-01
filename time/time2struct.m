function t=time2struct(hour)

	t = [];

	if ~ischar(hour) && ~isstring(hour)
		error("bad format");
		return;
	end

	hour = char(hour);
	if numel(hour) ~= 4
		hour = ['0', hour];
	end
		
	if numel(hour) ~= 4
		error("bad format");
		return;
	end
	
	
	
	t.hour = str2num(hour(1:2));
	t.min = str2num(hour(3:end));
	t.sec = 0;
end