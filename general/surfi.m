function h = surfi(X, Y, Z)
% Generates a surface plot from irregular data points
%
% Using the same syntax as scatter3, instead of the more particular
% arguments of surf, create a surface plot using grid interpolation.
%
%	h = SURFI(X, Y, Z) where X, Y, and Z are 1D lists of data values along
%	the three axes. Returns figure handle.


	% Generate required meshgrid
	xs = unique(round(X, 7));
	ys = unique(round(Y, 7));
	[XM, YM] = meshgrid(xs, ys);
	
	% Interpolate data
	ZM = griddata(X, Y, Z, XM, YM);
	
	% Make surface plot
	h = surf(XM, YM, ZM);
	
end