function G_v_F = abcd2G(abcd, ZS, ZL)
	
	zmat = abcd2z(abcd);
	Z11 = flatten(zmat(1,1,:));
	Z22 = flatten(zmat(2,2,:));
	Z21 = flatten(zmat(2,1,:));
	Z12 = flatten(zmat(1,2,:));

	ZP1 = Z11 - Z12.*Z21./(Z22 + ZL);
	G_v_F = (ZP1-ZS)./(ZP1+ZS);
end