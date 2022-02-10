function [R,L,C] = comp2pall(z, f)
	
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