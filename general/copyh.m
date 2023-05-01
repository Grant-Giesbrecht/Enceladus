function objcopy = copyh(handle_object)
% COPYH Deep copy of handle object
%
%	COPYH(H) Creates a deep copy of a handle object. Uses workaround
%	discussed here: 
%	  https://www.mathworks.com/matlabcentral/answers/41674-deep-copy-of-handle-object
%	  https://undocumentedmatlab.com/articles/serializing-deserializing-matlab-data
%
%	See also: COPY

	copyStream = getByteStreamFromArray(handle_object);
	objcopy = getArrayFromByteStream(copyStream);

end