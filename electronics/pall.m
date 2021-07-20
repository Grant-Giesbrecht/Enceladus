function z=pall(A, B)
%PALL Calculates the equivilent impedance of two elements in parallel.
%
%	Z = PALL(A, B) Calculates the equivalent impedance of two impedances, A
%	and B, in parallel.
%
%	See also ZL, ZC.

    z=1./(1./(A)+1./(B));
end