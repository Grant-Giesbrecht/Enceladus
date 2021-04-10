function g=refl(ZL, Z0)
%REFL Calculate the reflection coefficient of an interface.
%	g = REFL(ZL, Z0) Calculates reflection coefficient of a transmission
%	line of characteristic impedance Z0 terminated in a load of ZL.
%
%	See also XC, XL.

    g= (ZL-Z0)./(ZL+Z0);
end