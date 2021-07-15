classdef AWRLPvar < handle
	
	properties
		name
		data
		size
		validLen
		declareLine
	end
	
	methods
	
		function obj = AWRLPvar(name)
			
			obj.name = string(name);
			
			obj.guessSize();
			
			obj.validLen = -1; % Unspecified
			
		end
		
		function guessSize(obj)
			
			nc = char(obj.name);
			if length(nc) < 1
				obj.size = 1;
				return;
			end
			
% 			% Names recognized as size = 1
% 			indeces = ["iGammaL1", "iGammaL2", "iGammaL3", "iGammaS1", "iGammaS2", "iGammaS3", "iPower"];
% 			other_sz1 = {"F1(1)", "harm(1)", "]
% 			rec_sz1 = [];
			
			% Check if first letter is 'i'. THis is an index variable and
			% size always = 1
			if nc(1) == 'i'
				obj.size = 1;
				return;
			end
			
			% Check if ends with (1) or (0), size = 1
			if strcmp(nc(end-2:end), '(0)') || strcmp(nc(end-2:end), '(1)')
				obj.size = 1;
				return;
			end
			
			% Check if ends with (3), size = 2
			if strcmp(nc(end-2:end), '(3)')
				obj.size = 2;
				return;
			end
			
			% Otherwise, name doesn't match pattern. Guess size = 1 and
			% send warning.
			warning("Failed to detect size of variable!")
			obj.size = 1;
			
		end
		
		function assign(obj, varargin)
		% Assign values from string to the variables 'data' parameter
			
			% Determine if data were provided as a list, or separate
			% arguments.
			[~, c] = size(varargin);
			if c > 1 % Separate arguments
			
				% Get values from varargin
				vals = [];
				for v=varargin
					vals = addTo(vals, string(v));
				end
				
			else % Array
				
				% Loop over values
				vals = [];
				for v = varargin{1}
					vals = addTo(vals, string(v)); 
				end
				
			end
			
			% Check size
			if length(vals) ~= obj.size
				warning("Wrong size!")
				return;
			end
			
			% COnvert to numbers
			vals = double(vals);
			
			% Add to data
			obj.data = [obj.data; vals];
			
			
		end
		
		function c = getDataCol(obj, nr)
			
			% If not set, set to minimum size
			if ~exist('nr', 'var')
				nr = -1;
			end
			
			% Get dimensions of data and output
			[r, c] = size(obj.data);
			if nr < r
				nr = r;
			end
			
			% Create output of correct size
			c = zeros(nr, 1);
			
			if obj.size == 2
				
				% Scan through rows
				for didx = 1:r
					c(didx, 1) = obj.data(didx, 1) + sqrt(-1)*obj.data(didx, 2);
				end
				
			elseif obj.size == 1
				
				% Scan through rows
				for didx = 1:r
					c(didx, 1) = obj.data(didx);
				end
				
			end
			
		end
		
	end
	
end