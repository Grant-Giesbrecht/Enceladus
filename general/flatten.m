function v = flatten(mat)
% FLATTEN Change the shape of a matrix to 1xN
%
%	V = FLATTEN(MAT) Reshapes the matrix MAT to 1xN and returns it.
%
% See also RESHAPE.

	v = reshape(mat, [1, numel(mat)]);

end