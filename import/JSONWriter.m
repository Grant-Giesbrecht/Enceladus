classdef JSONWriter < handle
    properties (Access = private)
        StoredLists % Struct to hold named lists
    end
    
    methods
        function obj = JSONWriter()
            % Constructor: initialize empty storage as struct
            obj.StoredLists = struct();
		end
        
		function obj = clear(obj)
			obj.StoredLists = struct();
		end
		
        function addList(obj, name, newList)
            % Validate name
            if ~ischar(name) && ~isstring(name)
                error('Name must be a string or character vector.');
            end
            
            % Ensure input is a vector
            if ~isvector(newList)
                error('Input must be a 1D list (vector).');
            end
            
            % Convert to row vector for consistency
            newList = newList(:)'; 
            
            % Store in struct under given name
            obj.StoredLists.(char(name)) = newList;
		end
        
		function jsonText = stringJSON(obj)
			% Convert stored lists into JSON format
            jsonText = jsonencode(obj.StoredLists);
			
			% Add newlines after each comma and brace for readability
			% 1. Comma followed by quote → newline after comma
			jsonText = regexprep(jsonText, ',(?=")', ",\n");
			% 2. Opening brace → brace + newline
			jsonText = regexprep(jsonText, '{', '{\n');
			% 3. Closing brace → newline + brace
			jsonText = regexprep(jsonText, '}', '\n}');
		end
		
        function writeJSON(obj, filename)
            % Convert stored lists into JSON format
            jsonText = obj.stringJSON();
            
            % Write JSON string to file
            fid = fopen(filename, 'w');
            if fid == -1
                error('Could not open file %s for writing.', filename);
            end
            fwrite(fid, jsonText, 'char');
            fclose(fid);
        end
    end
end
