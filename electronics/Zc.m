function Z=Zc(mC, mf)
%ZC	Calculates the impedance of a capacitor.
%
%	Z = ZC(MC, MF) Calculates the impedance of a capacitor with capacitance
%	MC at the frequency MF, using units of Farad and Hertz.
%
%	See also ZL, PALL.

    Z=1./(sqrt(-1).*2.*pi.*mf.*mC);
end