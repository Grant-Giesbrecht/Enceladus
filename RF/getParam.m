function s_xy = getParam(x, y, f, SParam)
% GETPARAM Returns a specific S-Parameter float from an sparameter object.
%
%	S_XY = GETPARAM(X, Y, F, SPARAM) Returns the S parameter from port Y to
%	port X at frequency F from the sparameters object SPARAM.


	f_idx = find(SParam.Frequencies == f);
	if isempty(f_idx)
		s_xy = [];
		return;
	end

	s_xy = SParam.Parameters(x, y, f_idx);
	
end