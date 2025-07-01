classdef MTable < handle
% MTABLE ASCII table generator class
%
% MTABLE Properties
%	contents - Data contents
%	titlestr - title_string
%	tableStrs - List of strings containing each line of the table
%	alignment - List of column alignemnts
%	header_alignment - List of alignments of header columns
%	title_alignment - Alignment char for title
%	trim_rules - List of trim rules
%	default_alignment - Default alignment type
%	default_header_alignemnt - Default alginment for header
%	default_trim_state - Default trim rules
%	print_sidewalls - Print walls at end of table
%	print_headerinterwalls - Print walls inbetween header columns
%	print_interwalls - Print walls between data columns
%	print_titlebar - Print title bar
%	print_headerhbar - Print horiz. bar between title and column headers
%	print_interhbar - Print horiz. bar between data matrix and rows
%	col_padding - Number of extra spaces to include per column
%	wall_char - Character for table verticals
%	hbar_char - Character for table horizontals
%	joint_char - Character for table junctions
%	nextstr_line - The next line fo the table for nxtstr() to return
%	next_is_good - Used for parallel printing
%	table_up_to_date - Flag indicating when table must be regenerated
%	ncols - Number of table columns
%
% MTABLE Methods
%	MTable - Initailizer
%	row - Add data row to table
%	str - Get table string
%	nxtstr - Get next line string for parallel printing
%	num_rows - Get number of ASCII rows in table
%	generate_table - Regenerate table string from data
%	trimmed_size - Get size of data cell after trim rule applied
%	trimmed_contents - Get contents of data cell after trim rule applied
%	table_title - Set table title
%	alignc - Set column alignment rule
%	alignac - Set all columns' alignment rules
%	alignh - Set header column alignment rule
%	alignah - Set all header columns' alignment rules
%	alignt - Set title alignment rule
%	release_trim - Disable cell data trim
%	trimc - Set trim rules for column
%	trimac - Set trim rules for all columns
%	nxtgood - Check 'next_is_good' variable
%	alRight - Right align string
%	alCenter - Center align string
%	alLeft - Left align string
%	prd - Get number as string with specified number of decimal places

%TODO: Add latex table generation

	properties

		%*********** TABLE CONTENTS *******************
		contents % Data elements
		titlestr % Title
		tableStrs % List of strings containing each line of the table

		%*********** COLUMN FORMATTING OPTIONS *************
		% Alignment options: l, c, r
		alignment % List of column alignemnts
		header_alignment % List of alignments of header columns
		title_alignment % Alignment char for titlestr
		trim_rules % List of trum rules for each column (type = TrimState)
		default_alignment % (Char) default alignment to assign to new columns
		default_header_alignment % (char) Default alignment for new header columns
		default_trim_state % Default trim rules for new data columns (type = TrimState)

		%********** TABLE OPTIONS ***************************
		print_sidewalls % Walls at end of table
		print_headerinterwalls % WAlls between columns in header bar
		print_interwalls % Walls between columns
		print_titlebar % Bar at very top of table w/ a table titlestr
		print_topbottomhbar % Horiz. bar at top and bottom of table
		print_titlehbar % Horiz. bar between title and column headers
		print_headerhbar % Horiz. bar between col. headers and data matrix
		print_interhbars % Horiz. bar between data matrix and rows
		col_padding % Number of extra spaces to include per column (default = 2)

		%********** TABLE COMPOSITION CHARACTERS ************
		wall_char % Character to use on verticals
		hbar_char % Character to use on horizontals
		joint_char % Characters to use at vertical/horizontal intersections

		nxtstr_line % THe next line of the table for nxtstr() to return
		next_is_good % True unless nxtstr_line was set to zero after running through the entire table and nxtstr() hasnt been called since
		table_up_to_date % Tells if 'tableStrs'
		ncols

	end

	methods

		function obj = MTable()

			obj.titlestr = "Title";
			obj.title_alignment = 'c';

			obj.ncols = 0;

			obj.print_sidewalls = true;
			obj.print_headerinterwalls = true;
			obj.print_interwalls = true;
			obj.print_titlebar = false;
			obj.print_topbottomhbar = true;
			obj.print_titlehbar = true;
			obj.print_headerhbar = true;
			obj.print_interhbars = false;
			obj.col_padding = 2;

			obj.wall_char = '|';
			obj.hbar_char = '-';
			obj.joint_char = '+';

			obj.nxtstr_line = 0;
			obj.next_is_good = true;
			obj.table_up_to_date = false;

			obj.default_alignment = 'r';
			obj.default_header_alignment = 'c';

			obj.default_trim_state = TrimState(false, 'c', 15);

		end

		function tf = row(obj, nrow)

			tf = true;

			% Verify input is a string
			if ~isa(nrow, 'string')
				tf = false;
				return;
			end

			% Make sure all rows are the same size
			if length(nrow) > obj.ncols

				for ri=1:length(obj.contents)
					while obj.contents(ri).len() < length(nrow)

						obj.contents(ri).add("");
					end
				end
				obj.ncols = length(nrow);

				% Update alignments
				while length(obj.alignment) < obj.ncols
					obj.alignment = addTo(obj.alignment, obj.default_alignment);
					obj.header_alignment = addTo(obj.header_alignment, obj.default_header_alignment);
				end

				% Update trim rules
				while length(obj.trim_rules) < obj.ncols
					obj.trim_rules = addTo(obj.trim_rules, obj.default_trim_state);
				end

				nrd = RowData();
				nrd.data = nrow;

			elseif length(nrow) <= obj.ncols

				nrd = RowData();
				nrd.data = nrow;

				while nrd.len() < obj.ncols
					nrd.add("");
				end

			end

			% Add new row
			obj.contents = addTo(obj.contents, nrd);

			% Specify that table needs to be regenerated
			obj.table_up_to_date = false;

		end %====================== END row() =============================

		function ts = str(obj, lnum)
		% Note first line is accessed as line 1, not 0 as in C++ version

			if ~exist('lnum', 'var')
				lnum = -1;
			end

			if lnum == -1
				ts = "";

				for r = 1:obj.num_rows()
					ts = strcat(ts, obj.str(r), string(newline));
				end
			else

				% Generate table if req'd
				if ~obj.table_up_to_date
					obj.generate_table()
				end

				if lnum <= length(obj.tableStrs)
					ts = obj.tableStrs(lnum);
				else
					warning("Line out of bounds.");
					ts = " -- ERROR -- ";
				end

			end

		end %=============================== END str() ====================

		function tls = nxtstr(obj)

			obj.next_is_good = true;
			tls = obj.str(obj.nxtstr_line);
			obj.nxtstr_line = obj.nxtstr_line + 1;

			if obj.nxtstr_line > obj.num_rows()-1
				obj.nxtstr_line = 0;
				obj.next_is_good = false;
			end

		end %===================== END nxtstr() ===========================

		function nr = num_rows(obj)

			nr = length(obj.contents);
			if obj.print_titlebar
				nr = nr + 1;
			end
			if obj.print_topbottomhbar
				nr = nr + 2;
			end
			if obj.print_titlehbar && obj.print_titlebar
				nr = nr + 1;
			end
			if obj.print_headerhbar
				nr = nr + 1;
			end
			if obj.print_interhbars && length(obj.contents) > 1
				nr = nr + length(obj.contents)-2;
			end

		end %==================== END num_rows() =========================

		function generate_table(obj)

			% Erase out-dated data
			obj.tableStrs = [];

			%************ CALCULATE COLUMN WIDTHS *********************
			title_space = 0;
			column_widths = [];

			% For each column
			for c = 1:obj.ncols

				column_widths = addTo(column_widths, 0);

				% Check each row
				for r=1:length(obj.contents)
					if obj.trimmed_size(r, c) > column_widths(c)
						column_widths(c) = obj.trimmed_size(r, c);
					end
				end

				column_widths(c) = column_widths(c) + obj.col_padding;

				title_space = title_space + column_widths(c);
			end

			% Calculate Width of table and modify if title doesnt fit

			% Add to avail. space if vert. walls expand table
			if obj.print_interwalls || obj.print_headerinterwalls
				title_space = title_space + obj.ncols - 1;
			end

			% If not enough room for title
			if length(char(obj.titlestr)) > title_space
				extra = length(char(obj.titlestr)) - title_space;

				cc = 0;
				while extra > 0

					extra = extra - 1;

					cc = cc + 1;
					if cc > length(column_widths)
						cc = 1;
					end

					column_widths(cc) = column_widths(cc) + 1;
				end
			end

			%***************** GENERATE TABLE *****************************

			table_line = "";

			% ********* TOP BAR *********
			if obj.print_sidewalls % Add joint char for sidewall
				table_line = strcat(table_line, obj.joint_char);
			end

			for c = 1:obj.ncols
				table_line = strcat(table_line, repmat(obj.hbar_char, 1, column_widths(c)));

				if c < obj.ncols
					if obj.print_titlebar || ~obj.print_headerinterwalls
						table_line = strcat(table_line, obj.hbar_char);
					else
						table_line = strcat(table_line, obj.joint_char);
					end
				end
			end

			% Add joint char for sidewalls
			if obj.print_sidewalls
				table_line = table_line + obj.joint_char;
			end

			table_width = strlength(table_line);
			if obj.print_topbottomhbar
				obj.tableStrs = addTo(obj.tableStrs, table_line);
				table_line = "";
			end

			% ************ TITLE BAR *********************
			if obj.print_titlebar
				title_length = table_width;

				if obj.print_sidewalls
					title_length = title_length - 2;
				end

				switch obj.title_alignment
					case 'c'
						table_line = obj.alCenter(obj.titlestr, title_length);
					case 'r'
						table_line = obj.alRight(obj.titlestr, title_length);
					case 'l'
						table_line = obj.alLeft(obj.titlestr, title_length);
				end

				if obj.print_sidewalls
					table_line = obj.wall_char + table_line + obj.wall_char;
				end

				obj.tableStrs = addTo(obj.tableStrs, table_line);
				table_line = "";

			end

			%********** TITLE HORIZ. BAR ********
			if obj.print_titlehbar && obj.print_titlebar

				% Add joint for sidewall
				if obj.print_sidewalls
					table_line = table_line + obj.joint_char;
				end

				% For each column
				for c = 1:obj.ncols

					% Create hbar over ea. column
					table_line = table_line + repmat(obj.hbar_char, 1, column_widths(c));

					% Add hbar to vert. inbetween columns
					if c < obj.ncols
						if obj.print_titlebar || ~obj.print_headerinterwalls
							table_line = strcat(table_line, obj.hbar_char);
						else
							table_line = strcat(table_line, obj.joint_char);
						end
					end

				end

				% Add joint for sidewall
				if obj.print_sidewalls
					table_line = table_line + obj.joint_char;
				end

				obj.tableStrs = addTo(obj.tableStrs, table_line);
				table_line = "";

			end

			%*************** HEADER BAR ********

			% Add joint for sidewall
			if obj.print_sidewalls
				table_line = table_line + obj.wall_char;
			end

			for c = 1:obj.ncols

				switch obj.header_alignment(c)
					case 'l'
						if length(obj.col_padding) >= 2
							table_line = table_line + ' ' + obj.alLeft(obj.contents(1).data(c), column_widths(c)-2) + ' ';
						elseif length(obj.col_padding) == 1
							table_line = table_line + ' ' + obj.alLeft(obj.contents(1).data(c), column_widths(c)-1);
						else
							table_line = table_line + obj.alLeft(obj.contents(1).data(c), column_widths(c));
						end
					case 'r'
						if length(obj.col_padding) >= 2
							table_line = table_line + ' ' + obj.alRight(obj.contents(1).data(c), column_widths(c)-2) + ' ';
						elseif length(obj.col_padding) == 1
							table_line = table_line + ' ' + obj.alRight(obj.contents(1).data(c), column_widths(c)-1);
						else
							table_line = table_line + obj.alRight(obj.contents(1).data(c), column_widths(c));
						end
					case 'c'
						if length(obj.col_padding) >= 2
							table_line = table_line + ' ' + obj.alCenter(obj.contents(1).data(c), column_widths(c)-2) + ' ';
						elseif length(obj.col_padding) == 1
							table_line = table_line + ' ' + obj.alCenter(obj.contents(1).data(c), column_widths(c)-1);
						else
							table_line = table_line + obj.alCenter(obj.contents(1).data(c), column_widths(c));
						end
				end

				% Add wall or space between columns
				if c < obj.ncols
					if ~obj.print_headerinterwalls
						table_line = table_line + ' ';
					else
						table_line = table_line + obj.wall_char;
					end
				end

			end

			% Add joint for sidewall
			if obj.print_sidewalls
				table_line = table_line + obj.wall_char;
			end

			obj.tableStrs = addTo(obj.tableStrs, table_line);
			table_line = "";


			%***** HEADER HORIZ. BAR **********
			if obj.print_headerhbar

				% Add joint for sidewall
				if obj.print_sidewalls
					table_line = table_line + obj.joint_char;
				end

				% For each column
				for c = 1:obj.ncols

					% Create hbar over ea. column
					table_line = table_line + repmat(obj.hbar_char, 1, column_widths(c));

					% Add hbar to vert. inbetween columns
					if c < obj.ncols
						if obj.print_titlebar || ~obj.print_headerinterwalls
							table_line = strcat(table_line, obj.hbar_char);
						else
							table_line = strcat(table_line, obj.joint_char);
						end
					end

				end

				% Add joint for sidewall
				if obj.print_sidewalls
					table_line = table_line + obj.joint_char;
				end

				obj.tableStrs = addTo(obj.tableStrs, table_line);
				table_line = "";

			end

			%******** TABLE DATA **********
			for r = 2:length(obj.contents)

				% Add joint for sidewall
				if obj.print_sidewalls
					table_line = table_line + obj.wall_char;
				end

				% For each column
				for c = 1:obj.ncols
					switch obj.alignment(c)
						case 'l'
							if length(obj.col_padding) >= 2
								table_line = table_line + ' ' + obj.alLeft(obj.trimmed_contents(r, c), column_widths(c)-2) + ' ';
							elseif length(obj.col_padding) == 1
								table_line = table_line + ' ' + obj.alLeft(obj.trimmed_contents(r, c), column_widths(c)-1);
							else
								table_line = table_line + obj.alLeft(obj.trimmed_contents(r, c), column_widths(c));
							end
						case 'r'
							if length(obj.col_padding) >= 2
								table_line = table_line + ' ' + obj.alRight(obj.trimmed_contents(r, c), column_widths(c)-2) + ' ';
							elseif length(obj.col_padding) == 1
								table_line = table_line + ' ' + obj.alRight(obj.trimmed_contents(r, c), column_widths(c)-1);
							else
								table_line = table_line + obj.alRight(obj.trimmed_contents(r, c), column_widths(c));
							end
						case 'c'
							if length(obj.col_padding) >= 2
								table_line = table_line + ' ' + obj.alCenter(obj.trimmed_contents(r, c), column_widths(c)-2) + ' ';
							elseif length(obj.col_padding) == 1
								table_line = table_line + ' ' + obj.alCenter(obj.trimmed_contents(r, c), column_widths(c)-1);
							else
								table_line = table_line + obj.alCenter(obj.trimmed_contents(r, c), column_widths(c));
							end
					end

					% Add wall or space between columns
					if c < obj.ncols
						if ~obj.print_interwalls
							table_line = table_line + ' ';
						else
							table_line = table_line + obj.wall_char;
						end
					end
				end

				% Add joint for sidewall
				if obj.print_sidewalls
					table_line = table_line + obj.wall_char;
				end

				obj.tableStrs = addTo(obj.tableStrs, table_line);
				table_line = "";

				%** Inter Horiz. Bar **
				if obj.print_interhbars && r < length(obj.contents)

					% Add joint for sidewall
					if obj.print_sidewalls
						table_line = table_line + obj.joint_char;
					end

					% For each column
					for c = 1:obj.ncols

						% Create hbar over ea. column
						table_line = table_line + repmat(obj.hbar_char, 1, column_widths(c));

						% Add hbar to vert. inbetween columns
						if c < obj.ncols
							if obj.print_titlebar || ~obj.print_headerinterwalls
								table_line = strcat(table_line, obj.hbar_char);
							else
								table_line = strcat(table_line, obj.joint_char);
							end
						end

					end

					% Add joint for sidewall
					if obj.print_sidewalls
						table_line = table_line + obj.joint_char;
					end

					obj.tableStrs = addTo(obj.tableStrs, table_line);
					table_line = "";

				end

			end % End print table data

			%********* PRINT BOTTOM BAR ***********
			if obj.print_headerhbar

				% Add joint for sidewall
				if obj.print_sidewalls
					table_line = table_line + obj.joint_char;
				end

				% For each column
				for c = 1:obj.ncols

					% Create hbar over ea. column
					table_line = table_line + repmat(obj.hbar_char, 1, column_widths(c));

					% Add hbar to vert. inbetween columns
					if c < obj.ncols
						if obj.print_titlebar || ~obj.print_headerinterwalls
							table_line = strcat(table_line, obj.hbar_char);
						else
							table_line = strcat(table_line, obj.joint_char);
						end
					end

				end

				% Add joint for sidewall
				if obj.print_sidewalls
					table_line = table_line + obj.joint_char;
				end

				obj.tableStrs = addTo(obj.tableStrs, table_line);
				table_line = "";

			end

		end %=================== END generate_table() ====================

		function ts = trimmed_size(obj, r, c)

			if obj.trim_rules(c).trim_enabled
				if obj.contents(r).strLen(c) <= obj.trim_rules(c).len
					ts = obj.contents(r).strLen(c);
					return;
				else
					ts = obj.trim_rules(c).len;
					return;
				end
			else
				ts = obj.contents(r).strLen(c);
				return;
			end

		end %============== END trimmed_size() ============================

		function ts = trimmed_contents(obj, r, c)

			if obj.trim_rules(c).trim_enabled

				if obj.contents(r).strLen(c) <= obj.trim_rules(c).len
					ts = obj.contents(r).data(c);
					return;
				else

					ts = "";
					seq = '...';
					short_str = char(obj.contents(r).data(c));

					switch obj.trim_rules(c).alignment
						case 'l'

							trim_len = obj.contents(r).strLen(c) - obj.trim_rules(c).len + length(seq);
							short_str = short_str(trim_len:end); %TODO: This doesnt seem right

							ts = seq + string(short_str);
						case 'c'
							from_left = floor(obj.trim_rules(c).len/2 - length(seq)/2);
							from_right = ceil(obj.trim_rules(c).len/2 - length(seq)/2);

							ts = string(short_str(1:from_left)) + seq + string(short_str(end-from_right:end));
						case 'r'

							trim_len = obj.contents(r).strLen(c) - obj.trim_rules(c).len + length(seq);
							short_str = short_str(trim_len:end); %TODO: This doesnt seem right

							ts = string(short_str) + seq;
					end


				end

			else
				ts = obj.contents(r).data(c);
				return;
			end

		end %================= END trimmed_contents() =====================

		function title(obj, nt)

			% Update title
			obj.titlestr = nt;

			% Enable titlestr print
			obj.print_titlebar = true;

			% Force refresh
			obj.table_up_to_date = false;

		end

		function alignc(obj, col_num, val)

			% Check acceptable val
			if ~strcmp(val, 'l') && ~strcmp(val, 'r') && ~strcmp(val, 'c')
				warning(strcat("Alignment symbol ", string(val), " not valid"));
				val = obj.default_argument;
			end

			% Check in bounds
			if col_num > length(obj.alignment)
				warning(strcat("Column ", string(col_num), " out of bounds. Cannot set alignment"));
				return;
			end

			% Update data
			obj.alignment(col_num) = val;
			obj.table_up_to_date = false;

		end

		function alignac(obj, val)
			for c = 1:obj.ncols
				obj.alignc(c, val);
			end
		end

		function alignh(obj, col_num, val)

			% Check acceptable val
			if ~strcmp(val, 'l') && ~strcmp(val, 'r') && ~strcmp(val, 'c')
				val = obj.default_argument;
			end

			% Check in bounds
			if col_num > length(obj.header_alignment)
				return;
			end

			% Update data
			obj.header_alignment(col_num) = val;
			obj.table_up_to_date = false;

		end

		function alignah(obj, val)
			for c = 1:obj.ncols
				obj.alignh(c, val);
			end
		end

		function alignt(obj, val)
			% Check acceptable val
			if ~strcmp(val, 'l') && ~strcmp(val, 'r') && ~strcmp(val, 'c')
				val = obj.default_argument;
			end

			% Update data
			obj.title_alignment = val;
			obj.table_up_to_date = false;

		end

		function release_trim(obj, col_num)

			% Check in bounds
			if col_num > obj.ncols
				return;
			end

			% Update trim rules
			obj.trim_rules(col_num).trim_enabled = false;

			% Force refresh
			obj.table_up_to_date = false;

		end

		function trimc(obj, col_num, alignment, max_len)

			% Ensure max len not too short
			if max_len < 3
				max_len = 3;
			end

			% Update rules
			obj.trim_rules(col_num).trim_enabled = true;
			obj.trim_rules(col_num).alignment = alignment;
			obj.trim_rules(col_num).len = max_len;

			% Force refresh
			obj.table_up_to_date = false;

		end

		function trimac(obj, alignment, max_len)

			for c = 1:obj.ncols
				obj.trimc(c, alignment, max_len);
			end

		end

		function g = nxtgood(obj)
			g = obj.next_is_good;
		end




	end %====================== END methods =============================

	methods (Static)

		function s = alRight(str, w)

			s = pad(str, w);
			s = strjust(s, 'right');

		end

		function s = alCenter(str, w)

			s = pad(str, w);
			s = strjust(s, 'center');

		end

		function s = alLeft(str, w)

			s = pad(str, w);
			s = strjust(s, 'left');

		end

		function s = prd(x, decDigits)

			s = num2str(x, strcat("%.",string(decDigits),"f"));

		end

	end

end
