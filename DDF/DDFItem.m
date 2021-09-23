classdef DDFItem < handle
	properties
		type
		dimension
		val
		name
		desc
		count
		unit
		isnotfound %When is a returned value that does not exist, is set true, else false
		
		valstr % String representing value (calc'd by getValueStr)
		valstr_components % Array of strings representing elements in valstr
		valstr_value % Value (obj.val) used to compute valstr/valstr_components. Used to check if need to update valstr
	end		 % ************* END PROPERTIES *****************
	
	methods  % ************* METHODS ************************
		
		function obj=DDFItem(value, name, desc)
			
			%Get value, name, and description
			obj.val = value;
			obj.name = string(name);
			obj.desc = string(desc);
			obj.count = numel(obj.val);
			obj.isnotfound = false;
			obj.unit = "";
			if isa(value,'double')
				obj.type = "d";
			elseif isa(value,'string')
				obj.type = "s";
			elseif isa(value,'logical')
				obj.type = "b";
			else
				disp('ERROR: Unrecognized type!');
			end
			
			obj.valstr = "[]";
			obj.valstr_components = "";
			obj.valstr_components(1) = [];
			obj.valstr_value = [];
			
			%Get number of dimensions
			
			%ndims gives 2 dimensions even for numeric types (because
			%everything is a matrix)
			if ndims(value) > 2
				obj.dimension = ndims(value);
			elseif ndims(value) == 2
				
				% To see if it's not a matrix, we have to check if it's a 
				% 1x1 matrix.
				if size(value, 1) == 1 && size(value, 2) == 1
					obj.dimension = 1;
				else
					s = size(value);
					if s(1) == 1
						obj.dimension = 2;
					else
						obj.dimension = 3;
					end
				end
			end
			
		end % ************* END CONSTRUCTOR ********************
		
		function nf=isnf(obj)
			nf=obj.isnotfound;
		end
		
		function valstr=getValueStr(obj)
			
			% Recalculate value string if needed
			try
				if obj.valstr_value ~= obj.val
					obj.calcValueStr();
				end
			catch
				obj.calcValueStr();
			end
			
			
			% Return value
			valstr = obj.valstr;
			
		end
		
		function valstr=getValueStrIdx(obj, idx)
			
			% Recalculate value string if needed
			try
				if obj.valstr_value ~= obj.val
					obj.calcValueStr();
				end
			catch
				obj.calcValueStr();
			end
			
			
			% Return value
			if idx <= length(obj.valstr_components) 
				valstr = obj.valstr_components(idx);
			else
				valstr = "";
			end
			
		end
		
		function calcValueStr(obj)
			
			obj.valstr_components = "";
			obj.valstr_components(1) = [];
			
			if obj.dimension == 2 %If a 1D matrix

				%Start with blank string
				valstr = "";
				
				%Add each element
				for e=obj.val
					%Add comma if required
					if valstr ~= ""
						valstr = strcat(valstr, ", ");
					end
					
					estr = obj.getElementStr(e);
					
					obj.valstr_components = addTo(obj.valstr_components, estr);
					
					valstr = strcat(valstr, estr);
				end
				
				valstr = strcat("[", valstr, "]");
				
			elseif obj.dimension == 3 %If a 2D matrix
				
				%Get size
				dim = size(obj.val);
				
				matstr = "";
				
				%For each row
				for r_idx=1:dim(1)
					
					%Get row
					row = obj.val(r_idx,:);
					
					if matstr ~= ""
						matstr = strcat(matstr, "; ");
						
						obj.valstr_components(end) = strcat(obj.valstr_components(end), ";");
						
					end
					
					%Create row string same way create 1D array string
					
					%Start with blank string
					valstr = "";
					
					%Add each element of the row
					for e=row
						%Add comma if required
						if valstr ~= ""
							valstr = strcat(valstr, ", ");
						end
						
						estr = obj.getElementStr(e);
						
						obj.valstr_components = addTo(obj.valstr_components, estr);

						valstr = strcat(valstr, estr);
					end
					
					matstr = strcat(matstr, valstr);
				end
				
				valstr = strcat("[", matstr, "]");
				
			else %Else return element string
				valstr = obj.getElementStr(obj.val);
			end
			
			obj.valstr = string(valstr);
			obj.valstr_value = obj.val;
			
		end
		
		function valstr=getElementStr(obj, e)
			%Get string for value
			if obj.type == "d"
				valstr = num2str(e); %TODO: MOdify format specification
			elseif obj.type == "s"
				valstr = strcat('"', e, '"');
			elseif obj.type == "b"
				valstr = logical2str(e);
			else
				valstr = "ERROR";
			end
			
			valstr = string(valstr);
		end
		
		function updateCount(obj)
			obj.count = numel(obj.val);
			
			%Get number of dimensions
			
			%ndims gives 2 dimensions even for numeric types (because
			%everything is a matrix)
			if ndims(obj.val) > 2
				obj.dimension = ndims(obj.val);
			elseif ndims(obj.val) == 2
				
				% To see if it's not a matrix, we have to check if it's a 
				% 1x1 matrix.
				if size(obj.val, 1) == 1 && size(obj.val, 2) == 1
					obj.dimension = 1;
				else
					s = size(obj.val);
					if s(1) == 1
						obj.dimension = 2;
					else
						obj.dimension = 3;
					end
				end
			end
		end
		
		function strout=getTypeStr(obj)
			if obj.dimension > 1
				strout = strcat("m<", string(obj.type), ">");
			else
				strout = strcat(obj.type);
			end
		end
		
		function strout=str(obj)
			descstr = strcat(" (", '"', obj.desc, '"', ")")
			strout = strcat("<DDFItem(", obj.getTypeStr() , ") ", obj.name , "=", string(obj.val) , descstr, ">");
		end
		
	end		% ************* END METHODS ************************
end