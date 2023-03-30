function L = f2l(f, VF)
% F2L Converts a frequency to wavelength
%
%	L = F2L(f) Converts the frequency 'f' in Hz to wavelength in meters.
%
%	L = F2L(..., VF) Apply a velocity factor VF to the conversion.
%
%

	% Check if 
	if ~exist('VF', 'var')
		VF = 1;
	end
	
	c = 299792458; %m/s
	cvf = c.*VF;
	L = c./f;
	
end