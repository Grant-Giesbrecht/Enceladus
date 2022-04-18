function uibandwidth(solns, freqs, spr, spc, optBW_param)
% UIBANDWIDTH
%
% Interactive window for viewing different bandwidth responses for matching
% networks. 
%
% See also: stubmatch, lpanalyze, contourplot2_gui

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

	%============================= Create GUI =============================

	%  Create and then hide the UI as it is being constructed.
	if exist('figno', 'var')
		f = uifigure(figno);
		f.Visible = false;
		f.Position = [360,500,450,285];
	else
		f = uifigure('Visible','off','Position',[360,500,450,285]);
	end

	glm = uigridlayout(f);

% 	hFreqText  = uicontrol('Style','text','String','Page',...
% 			   'Position',[325,220,60,15]);
	
	
	hPageText = uilabel(glm);
	hPageText.Layout.Row = 1;
	hPageText.Layout.Column = 2;
	hPageText.Text = "Page:";
	hPageText.FontSize = 12;
	
% 	hFreqMenu = uicontrol('Style','popupmenu',...
% 			   'String',cellstr(string(1:1:num_pages)),...
% 			   'Position',[300,180,100,25],...
% 			   'Callback',@page_menu_callback);
	hPageMenu  = uidropdown(glm);
	hPageMenu.Items = cellstr(string(1:1:num_pages));
	hPageMenu.Layout.Row = 2;
	hPageMenu.Layout.Column = 2;

% 	hPwrText  = uicontrol('Style','text','String','Input Power (Index)',...
% 			   'Position',[325,135,60,15]);
% 	hPwrMenu = uicontrol('Style','popupmenu',...
% 			   'String',cellstr(string(unique(lp_data.props.iPower))),...
% 			   'Position',[300,90,100,25],...
% 			   'Callback',@pwr_menu_callback);
		   
% 	ha = axes('Units','pixels','Position',[50,60,200,185]);
	
	% Initailize all axes
	ha_list = uiaxes(glm);
	ha_list.Layout.Row = 1;
	ha_list.Layout.Column = 1;
	for idx = 2:nplots
		ha_list(end+1) = uiaxes(glm);
		ha_list(end).Layout.Row    = ceil(idx./spc);
		ha_list(end).Layout.Column = mod(idx-1, spc)+1;
	end
% 	align([hFreqText, hPageMenu],'Center','None');

	% Initialize the UI.
	% Change units to normalized so components resize automatically.
	f.Units = 'normalized';
	ha.Units = 'normalized';
	hFreqText.Units = 'normalized';
	hFreqMenu.Units = 'normalized';
	hPwrText.Units = 'normalized';
	hPwrMenu.Units = 'normalized';

	% Plot data
	plot_page(solns, 1);
% 	subplot(spr, spc, 1);
% 	plot(sin(freqs./1e9));
% 	subplot(spr, spc, 2);
% 	plot(cos(freqs./1e9));

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
		  
		% Determine the selected data set.
		strs = get(source, 'String');
		idx = get(source,'Value');

		page_no = str2num(strs{idx});
		
		plot_page(solns, page_no);
	end

	function plot_page(ss, page_no)
		
		for idx = 1:nplots
			
			% Plot S-Parameter Response
			hold(ha_list(idx), "off");
			plot(ha_list(idx), freqs./1e9, lin2dB(abs(ss(idx+page_no*nplots).G_in())));
			hold(ha_list(idx), "on");
			
			% Add labels
			xlabel(ha_list(idx), "Frequency (GHz)");
			ylabel(ha_list(idx), "S-Parameter (dB)");
			title(ha_list(idx), ss(idx).name);
			
			% Calculate BW
			
			% Calculate bandwidth
			[bw, f0, f1]=ss(idx).bandwidth( "Absolute", optBW_param);
			
			% Plot Bandwidth Region
			if ~isempty(bw)
				%fillregion([f0./1e9, f1./1e9], [NaN, NaN], [0, .8, 0], .2);
				vlin(f0./1e9, 'Color', [.3, .3, .3], 'LineStyle', '--');
				vlin(f1./1e9, 'Color', [.3, .3, .3], 'LineStyle', '--');
			end
			
			% Add finishing touches to graph
			grid(ha_list(idx), "on");
			ylim(ha_list(idx), [-50, 0]);
			
		end

	end
end


























