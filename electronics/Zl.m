function x=Xl(mL, mf)
%ZL	Calculates the impedance of an inductor.
%
%	Z = ZL(ML, MF) Calculates the impedance of an inductor with inductance
%	ML at the frequency MF, using units of Henry and Hertz.
%
%	See also ZC, PALL.

    x=sqrt(-1).*2.*pi.*mf.*mL;
end