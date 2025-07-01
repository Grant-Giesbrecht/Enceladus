function [R,L,C] = comp2pall(z, f)
% Computes a parallel circuit that provides the given complex impedance
%
% Computes a combination of parallel resistor, capacitor, and inductors
% that results in the specified complex impedance at the frequency f.
%
%	[R, L, C] = COMP2PALL(z, f) Populates R, L, and C with the element
%	values that result in the impedance z at frequency f. Prints the result
%	to the command line as well.
%
% See also Zc, Zl.


	j = sqrt(-1);

	if real(z) ~= 0
		R=1./real(1./z);
	else
		R = NaN;
	end
	
	X=1./imag(1./z);
	w = 2.*3.14159.*f;
	
	L = NaN;
	C = NaN;
	
	if imag(z) > 0
		L = X/j/w;
	elseif imag(z) < 0
		C = 1/(w*X);
	end
	
% 	s = "Parallel: ";
	disp("Parallel: ");
	if ~isnan(R)
% 		s = s + "R = " + num2str(R) + " Ohms ";
		disp("    R = " + num2str(R) + " Ohms ");
	end
	if ~isnan(L)
% 		s = s + "L = " + num2str(L*1e9) + " nH ";
		disp("    L = " + num2str(L*1e9) + " nH ");
	end
	if ~isnan(C)
% 		s = s + "C = " + num2str(C*1e12) + " pF";
		disp("    C = " + num2str(C*1e12) + " pF");
	end
% 	disp(s);
end