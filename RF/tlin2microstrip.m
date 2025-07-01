function [W, len] = tlin2microstrip(Z0, e_r, d, el, f)
% TLIN2MICROSTRIP Computes microstrip dimensions
%
% Calculates the width of a microstrip for a given characteristic impedance
% and substrate. If electrical length is provided, also calculates physical
% length.
%
%
%	W = TLIN2MICROSTRIP(Z0, e_r, d) Computes width 'W' of microstrip with
%	characteristic impedance Z0 on a substrate with relative permittivity of
%	'e_r' and thickness 'd'. All dimensions are expected in meters.
%
%	[W, len] = TLIN2MICROSTRIP(..., el, f) In addition to computing microstrip
%	width, calcultes the physical length in meters of a transmission line
%	with electrical length 'el' (in degrees) at frequency 'f' (Hz). Returns
%	with and physical length, both in meters.
%
% See also: microstrip2tlin
	
	% Handle default arguments
	if ~exist('el', 'var')
		el = NaN;
	end
	
	% Calculate constants 'A' and 'B' from Pozar 4e, Eq. 3.197
	A = Z0./60.*sqrt((e_r + 1)./2) + (e_r - 1)./(e_r + 1).*(.23 + .11/e_r);
	B = 377.*pi./2./Z0./sqrt(e_r);
	
	% Calculate W/d. Note that the formula changes depending on whether or not
	% W/d is < 2. The first pass assumes W/d < 2, then checks assumption and
	% runs alternative formula if required.
	%
	% From Pozar 4e, Eq. 3.197
	
	% Calculate W_d (formula 1)
	W_d = (8.*exp(A))./(exp(2.*A) - 2);
	
	% Check assumption
	if W_d >= 2
		
		% Assumption invalid, use W/d > 2 formula (aslos Pozar 4e, eq. 3.197)
		W_d = 2./pi.*( B - 1 - log(2.*B - 1) + (e_r - 1)./e_r./2.*( log(B-1) + .39 - .61/e_r ) );
		
		% Check second assumption
		if W_d < 2
			error("Convergence error. Equation from Pozar cannot be used.");
		end
	end
	
	% Calculate Width
	W = W_d.*d;
	
	% If electrical length provided, calcualte length
	if ~isnan(el)
		
		% Calculate effective dielectric constant
		% (From Pozar 4e, Eq. 3.195)
		e_e = (e_r + 1)./2 + (e_r - 1)./2 .* 1./sqrt( 1 + 12.*d./W );
		
		% Calculate wavenumber in free-space
		k0 = 2.*pi.*f./299792458;
		
		% Calculate physical length
		len = el.*pi./180./sqrt(e_e)./k0;
	else
		len = NaN;
	end
	
end