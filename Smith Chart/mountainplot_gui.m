function mountainplot_gui(lp_data, param, figno, varargin)

	% SIMPLE_GUI2 Select a data set from the pop-up menu, then
	% click one of the plot-type push buttons. Clicking the button
	% plots the selected data in the axes.
	
	expectedSchemes = {'Light', 'Dark'};

	p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('ContourLabel', "Z", @(x) isstring(x) || ischar(x) );
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
	p.parse(varargin{:});
	
	%  Create and then hide the UI as it is being constructed.
	if exist('figno', 'var')
		f = figure(figno);
		f.Visible = false;
		f.Position = [360,500,450,285];
	else
		f = figure('Visible','off','Position',[360,500,450,285]);
	end
	% Construct the components.
% 	hsurf    = uicontrol('Style','pushbutton',...
% 				 'String','Surf','Position',[315,220,70,25],...
% 				 'Callback',@surfbutton_Callback);
% 	hmesh    = uicontrol('Style','pushbutton',...
% 				 'String','Mesh','Position',[315,180,70,25],...
% 				 'Callback',@meshbutton_Callback);
% 	hcontour = uicontrol('Style','pushbutton',...
% 				 'String','Contour','Position',[315,135,70,25],...
% 				 'Callback',@contourbutton_Callback);
	hFreqText  = uicontrol('Style','text','String','Frequency (GHz)',...
			   'Position',[325,220,60,15]);
	hFreqMenu = uicontrol('Style','popupmenu',...
			   'String',cellstr(string(unique(lp_data.freq)./1e9)),...
			   'Position',[300,180,100,25],...
			   'Callback',@freq_menu_callback);
	hPwrText  = uicontrol('Style','text','String','Input Power (Index)',...
			   'Position',[325,135,60,15]);
	hPwrMenu = uicontrol('Style','popupmenu',...
			   'String',cellstr(string(unique(lp_data.props.iPower))),...
			   'Position',[300,90,100,25],...
			   'Callback',@pwr_menu_callback);
		   
	ha = axes('Units','pixels','Position',[50,60,200,185]);
	align([hFreqText, hFreqMenu, hPwrText, hPwrMenu],'Center','None');

% 	drawnow;
% 	InSet = get(ha, 'TightInset');
% 	set(ha, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)])
% 	leg = legend(ha,'Location','Southoutside','Orientation','horizontal','NumColumns',10);
% 	LegPos = leg.Position;
% 	% Resize axis
% 	InSet = get(gca, 'TightInset');
% 	set(gca, 'Position', [InSet(1), InSet(2)+LegPos(2), 1-InSet(1)-InSet(3),...
%     1-InSet(2)-InSet(4)-LegPos(2)]);

	% Initialize the UI.
	% Change units to normalized so components resize automatically.
	f.Units = 'normalized';
	ha.Units = 'normalized';
	hFreqText.Units = 'normalized';
	hFreqMenu.Units = 'normalized';
	hPwrText.Units = 'normalized';
	hPwrMenu.Units = 'normalized';

	% Generate the data to plot.
	freq = 10e9;
	iPwr = 6;
	lp_filt = lp_data.get(lp_data.filter("Freq", freq, "props.iPower", iPwr));
% 	title("PAE at 10 GHz, iPower = idx 7");

	% Create a plot in the axes.
	hold off;
	contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param), 'ContourLabel', p.Results.ContourLabel, 'Scheme', p.Results.Scheme);
	surfsc(lp_filt.gamma(), lp_filt.getArrayFromName(param), 'ZLabel', p.Results.ContourLabel);
	title(param + " at " + freq./1e9 + " GHz and iPower = " + iPwr);
	
	% Assign the a name to appear in the window title.
	f.Name = 'Mountain Plot GUI';

	% Move the window to the center of the screen.
	movegui(f,'center')

	% Make the window visible.
	f.Visible = 'on';

	%  Pop-up menu callback. Read the pop-up menu Value property to
	%  determine which item is currently displayed and make it the
	%  current data. This callback automatically has access to 
	%  current_data because this function is nested at a lower level.
	function freq_menu_callback(source,eventdata) 
		  
		% Determine the selected data set.
		strs = get(source, 'String');
		idx = get(source,'Value');

		freq = str2num(strs{idx}).*1e9;
		
		lp_filt = lp_data.get(lp_data.filter("Freq", freq, "props.iPower", iPwr));
		hold off;
		contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param), 'ContourLabel', p.Results.ContourLabel, 'Scheme', p.Results.Scheme);
		surfsc(lp_filt.gamma(), lp_filt.getArrayFromName(param), 'ZLabel', p.Results.ContourLabel);
		displ("Plotting at:", newline, "  Freq: ", freq, " Hz", newline, "  Pwr Idx: ", iPwr);
		title(param + " at " + freq./1e9 + " GHz and iPower = " + iPwr);
	end
   
	function pwr_menu_callback(source,eventdata) 
		
		% Determine the selected data set.
		strs = get(source, 'String');
		idx = get(source,'Value');

		iPwr = str2num(strs{idx});
		
		lp_filt = lp_data.get(lp_data.filter("Freq", freq, "props.iPower", iPwr));
		hold off;
		contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param), 'ContourLabel', p.Results.ContourLabel, 'Scheme', p.Results.Scheme);
		surfsc(lp_filt.gamma(), lp_filt.getArrayFromName(param), 'ZLabel', p.Results.ContourLabel);
		displ("Plotting at:", newline, "  Freq: ", freq, " Hz", newline, "  Pwr Idx: ", iPwr);
		title(param + " at " + freq./1e9 + " GHz and iPower = " + iPwr);
	end

	  % Push button callbacks. Each callback plots current_data in the
	  % specified plot type.

% 	  function surfbutton_Callback(source,eventdata) 
% 	  % Display surf plot of the currently selected data.
% 		   surf(current_data);
% 	  end
% 
% 	  function meshbutton_Callback(source,eventdata) 
% 	  % Display mesh plot of the currently selected data.
% 		   mesh(current_data);
% 	  end
% 
% 	  function contourbutton_Callback(source,eventdata) 
% 	  % Display contour plot of the currently selected data.
% 		   contour(current_data);
% 	  end
end