classdef LPPoint < handle
% LPPoint Contains data from one point in a load pull (ie. one 
% frequency, gamma, etc combination). 


	properties
		
		% These may or may not contain harmonics, depending on how the
		% point was constructed. They will either be scalars (just
		% fundamental) or vectors (with harmonics)
		a1
		a2
		b1
		b2
		
		props
		
	end
	
	methods
		
		function obj = LPPoint()
			obj.a1 = [];
			obj.a2 = [];
			obj.b1 = [];
			obj.b2 = [];
			
			obj.props = {};
		end
		
		function str(obj)
			
			indent = "";
			rel_indent = "  ";
			displ(indent, "a1: ", obj.a1);
			displ(indent, "a2: ", obj.a2);
			displ(indent, "b1: ", obj.b1);
			displ(indent, "b2: ", obj.b2);
			
			displ("Properties:");
			fn = fieldnames(obj.props);
			for k=1:numel(fn)
				displ(rel_indent, indent, fn{k}, ": ", obj.props.(fn{k}));
			end
			
		end
		
		function val = getProp(obj, p)
		% Returns a value for a property. Returns empty if deosnt exist.
			if ~isfield(obj.props, p)
				val = [];
				return;
			end
			
			val = obj.props.(p);
			
		end
		
		function formatData(obj)
		% Renames known variables and calculates some parameters required
		% for many filtering applications
			
			% Rename known fields
			fld = ccell2mat(fields(obj.props));
			if any(fld == "F1")
				obj.props = renameStructField(obj.props, 'F1', 'freq');
			elseif any(fld == "F0")
				obj.props = renameStructField(obj.props, 'F0', 'freq');
% 			elseif any(fld == "")
% 				obj.props = renameStructField(obj.props, '', '');
% 			elseif any(fld == "")
% 				obj.props = renameStructField(obj.props, '', '');
			end
			
			% Calculate P-in
			obj.props.Pin = obj.getPin();
			
		end
		
		function P = getPin(obj)
			
			% Note: This is a modified form of 4,62 in Pozar. I need to
			% change this to be correct!
			P = .5*abs(obj.a1(1))^2 - .5*abs(obj.b1(1))^2;
			
		end
	end
	
end