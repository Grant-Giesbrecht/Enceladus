function f = uibandwidth(solns, freqs, spr, spc, optBW_param)
% UIBANDWIDTH
%
% Interactive window for viewing different bandwidth responses for matching
% networks. 
%
% See also: stubmatch, lpanalyze, contourplot2_gui

	y_bounds = [-50, 0];

	% Initialize default arguments
	if ~exist("spr", "var")
		spr = 4;
	end
	if ~exist("spc", "var")
		spc = 4;
	end
	if ~exist("optBW_param", "var")
		optBW_param = -20;
	end

	nplots = spr*spc;
	num_pages = ceil(numel(solns)/nplots);
	ncirc = numel(solns);

	%============================= Create GUI =============================

	%  Create and then hide the UI as it is being constructed.
	if exist('figno', 'var')
		f = uifigure(figno);
		f.Visible = false;
		f.Position = [360,500,450,285];
	else
		f = uifigure('Visible','off','Position',[360,500,450,285]);
% 		f = uifigure('Visible','off','Position',[1.7806    0.0787    0.6497    0.5822]);
	end

	% Master grid layout
	glm = uigridlayout(f);
	
	% Create panel for controls
	ctrl_p = uipanel(glm, "Title", "UI Options");
	ctrl_p.Layout.Row = [1, spr]; % Span all rows
	ctrl_p.Layout.Column = spc+1;
	
	% Control grid layout
	cgm = uigridlayout(ctrl_p);
	cgm.RowHeight = {'fit', 'fit', '1x'};
	
	% Create Page Selector Text
	hPageText = uilabel(cgm);
	hPageText.Layout.Row = 1;
	hPageText.Layout.Column = 1;
	hPageText.Text = "View Page:";
	hPageText.FontSize = 12;
	hPageText.HorizontalAlignment = 'right';
	
	% Create page selector dropdown
	hPageMenu  = uidropdown(cgm);
	hPageMenu.Items = cellstr(string(1:1:num_pages));
	hPageMenu.Layout.Row = 1;
	hPageMenu.Layout.Column = 2;
	hPageMenu.ValueChangedFcn = @(dd, event) page_menu_callback(dd, event);
	
	% Create Circuit Selector Text
	hCircText = uilabel(cgm);
	hCircText.Layout.Row = 2;
	hCircText.Layout.Column = 1;
	hCircText.Text = "Print Circuit:";
	hCircText.FontSize = 12;
	hCircText.HorizontalAlignment = 'right';
	
	% Create circuit selector dropdown
	hCircMenu  = uidropdown(cgm);
	hCircMenu.Items = cellstr(string(1:1:ncirc));
	hCircMenu.Layout.Row = 2;
	hCircMenu.Layout.Column = 2;
	
	% Create circuit print button
	hCircButton = uibutton(cgm);
	hCircButton.Text = "Print";
	hCircButton.Layout.Row = 2;
	hCircButton.Layout.Column = 3;
	hCircButton.FontSize = 12;
	hCircButton.ButtonPushedFcn = @(btn, event) printButtonCallback(btn, event);
	
	% Initailize all axes (Subplots not used)
	ha_list = uiaxes(glm);
	ha_list.Layout.Row = 1;
	ha_list.Layout.Column = 1;
	for idx = 2:nplots
		ha_list(end+1) = uiaxes(glm);
		ha_list(end).Layout.Row    = ceil(idx./spc);
		ha_list(end).Layout.Column = mod(idx-1, spc)+1;
	end

	% Initialize the UI.
	% Change units to normalized so components resize automatically.
	f.Units = 'normalized';
	ha.Units = 'normalized';
	hFreqText.Units = 'normalized';
	hFreqMenu.Units = 'normalized';
	hPwrText.Units = 'normalized';
	hPwrMenu.Units = 'normalized';

	% Plot initial data
	plot_page(solns, 1);

	% Assign the a name to appear in the window title.
	f.Name = 'Match Bandwidth UI';

	% Move the window to the center of the screen.
	movegui(f,'center')

	% Make the window visible.
	f.Visible = 'on';

	%  Pop-up menu callback. Read the pop-up menu Value property to
	%  determine which item is currently displayed and make it the
	%  current data. This callback automatically has access to 
	%  current_data because this function is nested at a lower level.
	function page_menu_callback(source,eventdata) 
		
		val = source.Value;
		
% 		% Determine the selected data set.
% 		strs = get(source, 'String');
% 		idx = get(source,'Value');

		page_no = str2num(val);
		
		plot_page(solns, page_no);
	end
	
	function printButtonCallback(btn, event)
		
		% Get ID to search for
		find_id = str2num(hCircMenu.Value);
		
		found = false;
		
		% Search for ID
		for ss = solns
			if ss.ID == find_id
				disp(ss.str());
				found = true;
			end
		end
		
		if ~found
			displ("Failed to find: ", find_id);
		end
		
	end

	function plot_page(ss, page_no)
		
		for idx2 = 1:nplots
			
			% Check for out of bounds
			if (idx2+(page_no-1)*nplots > numel(ss))
				title(ha_list(idx2), " ");
				cla(ha_list(idx2));
				continue;
			end
			
			% Plot S-Parameter Response
			hold(ha_list(idx2), "off");
			plot(ha_list(idx2), freqs./1e9, lin2dB(abs(ss(idx2+(page_no-1)*nplots).G_in())));
			hold(ha_list(idx2), "on");
			
			% Calculate bandwidth
			[bw, f0, f1]=ss(idx2+(page_no-1)*nplots).bandwidth( "Absolute", optBW_param);
			
			% Add labels
			xlabel(ha_list(idx2), "Frequency (GHz)");
			ylabel(ha_list(idx2), "S-Parameter (dB)");
			plot_title = "No. " + num2str(ss(idx2+(page_no-1)*nplots).ID) + ", N = " + num2str(numel(ss(idx2+(page_no-1)*nplots).mats)/2) + ", [";
			for elmnt = ss(idx2+(page_no-1)*nplots).mats
				if elmnt.desc.type == "SHORT_STUB"
					plot_title = plot_title + "S";
				elseif elmnt.desc.type == "OPEN_STUB"
					plot_title = plot_title + "O";
				end
			end
			plot_title = plot_title + "], BW = " + num2fstr(bw/1e9) + " GHz";
			
			title(ha_list(idx2), plot_title);
			
			% Plot Bandwidth Region
			if ~isempty(bw)
				%fillregion([f0./1e9, f1./1e9], [NaN, NaN], [0, .8, 0], .2);
				line(ha_list(idx2), [f0./1e9, f0./1e9], y_bounds, 'Color', [.3, .3, .3], 'LineStyle', '--');
				line(ha_list(idx2), [f1./1e9, f1./1e9], y_bounds, 'Color', [.3, .3, .3], 'LineStyle', '--');
			else
				
			end
			
			% Add finishing touches to graph
			grid(ha_list(idx2), "on");
			ylim(ha_list(idx2), [-50, 0]);
			
		end

	end
end


























