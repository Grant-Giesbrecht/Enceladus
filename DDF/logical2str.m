function str=logical2str(x, varargin)

	if nargin > 1
		if upper(varargin{1}) == 'L'
			if x
				str="true";
				return;
			else
				str="false";
				return;
			end
		elseif upper(varargin{1}) == 'U'
			if x
				str="TRUE";
				return;
			else
				str="FALSE";
				return;
			end
		end
	end
	
	if x
		str="True";
		return;
	else
		str="False";
		return;
	end

end
