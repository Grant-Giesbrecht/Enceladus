function tf = equaltolp(a, b, tol)

	tol_a = abs(min(a,b).*tol);

	tf = abs(a-b)<=tol_a;

end