function fig_to_MIDAS(fig_no, force_explicit_X)
	
	if ~exist('force_explicit_X', 'var')
		force_explicit_X = false;
	end
	
	VOID_CHAR = "--";
	
	
	function name_out = make_name(name)
		name_out = replace(name, ",", "");
		name_out = replace(name_out, "[", "{");
		name_out = replace(name_out, "]", "}");
		name_out = "["+name_out+"]";
	end
	
	% Converts figure data to a nice pretty TXT file for MIDAS
	
	f = figure(fig_no);
	
	% Scan over all children
	child_idx = -1;
	for i = 1:numel(f.Children)
		if isa(f.Children(i), 'matlab.graphics.axis.Axes')
			child_idx = i;
			break;
		end
	end
	
	% Check if all data sets use same X data
	univ_X_data = f.Children(child_idx).Children(1).XData;
	all_match = true;
	for line_idx = 2:numel(f.Children(child_idx).Children )
		
		if numel(univ_X_data) ~= numel(f.Children(child_idx).Children(line_idx).XData)
			all_match = false;
			break;
		end
		
		if univ_X_data ~= f.Children(child_idx).Children(line_idx).XData
			all_match = false;
			break;
		end
		
		
		
	end
	
	
	if all_match && (~force_explicit_X) %------------- UNIFORM X-VLAUES --------------------
				
		% Save X Data
		data_rows = cell(1, numel(univ_X_data)+1);
		data_rows{1} = make_name(f.Children(child_idx).XLabel.String);
		for xi = 1:numel(univ_X_data)
			data_rows{xi+1} = [string(num2str(univ_X_data(xi)))];
		end
		
		% Save each trace
		for trace_idx = 1:numel(f.Children(child_idx).Children )
			
			% Save title
			data_rows{1}(end+1) = make_name( f.Children(child_idx).YLabel.String + "(" + f.Children(child_idx).Children(trace_idx).DisplayName +")");
			
			% Save each row
			for xi = 1:numel(univ_X_data)
				data_rows{xi+1}(end+1) = string(num2str(f.Children(child_idx).Children(trace_idx).YData(xi)));
			end
		end
		
		% Create master string
		master_string = "";
		for line = 1:numel(data_rows)
			
			% Add each element to line
			for idx = 1:numel(data_rows{line})
				
				% Add comma
				if idx ~= 1
					master_string = master_string + ", ";
				end
				
				% Add content
				master_string = master_string + data_rows{line}(idx);
			end
			
			% ADd newline
			master_string = master_string + "\n";
		end
		
	else %------------- NON-UNIFORM X-VLAUES --------------------
		
		% Get longest X
		x_max = numel(f.Children(child_idx).Children(1).XData);
		for trace_idx = 2:numel(f.Children(child_idx).Children )
			x_max = max([x_max, numel(f.Children(child_idx).Children(trace_idx).XData)]);
		end
		
		% Save X Data
		data_rows = cell(1, x_max+1);
			
		% Save each trace-X
		for trace_idx = 1:numel(f.Children(child_idx).Children )
			
			% Save title
			data_rows{1}(end+1) = make_name( f.Children(child_idx).XLabel.String + "(" + f.Children(child_idx).Children(trace_idx).DisplayName +")");
			
			% Save each row
			for xi = 1:x_max
				if xi <= numel(f.Children(child_idx).Children(trace_idx).XData)
					data_rows{xi+1}(end+1) = string(num2str(f.Children(child_idx).Children(trace_idx).XData(xi)));
				else
					data_rows{xi+1}(end+1) = VOID_CHAR;
				end
			end
		end
		
		% Save each trace-Y
		for trace_idx = 1:numel(f.Children(child_idx).Children )
			
			% Save title
			data_rows{1}(end+1) = make_name( f.Children(child_idx).YLabel.String + "(" + f.Children(child_idx).Children(trace_idx).DisplayName +")");
			
			% Save each row
			for xi = 1:x_max
				if xi <= numel(f.Children(child_idx).Children(trace_idx).YData)
					data_rows{xi+1}(end+1) = string(num2str(f.Children(child_idx).Children(trace_idx).YData(xi)));
				else
					data_rows{xi+1}(end+1) = VOID_CHAR;
				end
			end
		end
		
		% Create master string
		master_string = "";
		for line = 1:numel(data_rows)
			
			% Add each element to line
			for idx = 1:numel(data_rows{line})
				
				% Add comma
				if idx ~= 1
					master_string = master_string + ", ";
				end
				
				% Add content
				master_string = master_string + data_rows{line}(idx);
			end
			
			% ADd newline
			master_string = master_string + "\n";
		end
	end
	
	displ(master_string);
end