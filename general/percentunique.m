function [pcnt, num_unique, unique_vals] = percentunique(x)

	tol = .001;

	R = real(x); % Get real values
	I = imag(x); % Get imaginary vaues
	X = [R',I'];
	
% 	[~, Ru] = uniquetol(R, tol); % Find indecies of unique reals
% 	[~, Iu] = uniquetol(I, tol); % Find indecies of unique imags
% 
% 	% Get overlap
% 	idx = intersect(Ru, Iu);

	C = uniquetol(X, tol, 'ByRows', true);

	unique_vals = C(:,1)+i.*C(:,2);
	
	[num_unique, ~] = size(C);
	
	pcnt = 100*num_unique/numel(x);	

end