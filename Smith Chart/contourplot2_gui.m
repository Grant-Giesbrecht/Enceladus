function contourplot2_gui(lp_data, param1, param2, figno, varargin)

	% SIMPLE_GUI2 Select a data set from the pop-up menu, then
	% click one of the plot-type push buttons. Clicking the button
	% plots the selected data in the axes.
	
	expectedSchemes = {'Light', 'Dark'};

	alpha1 = .4;
	alpha2 = .4;
	
	p = inputParser;
    p.KeepUnmatched = true;
	p.addParameter('ContourLabel1', "Z", @(x) isstring(x) || ischar(x) );
	p.addParameter('ContourLabel2', "Z", @(x) isstring(x) || ischar(x) );
	p.addParameter('Scheme', 'Light', @(x) any(validatestring(char(x), expectedSchemes)) );
	p.addParameter('Color1', [0, 0, .8], @isnumeric );
	p.addParameter('Color2', [.8, 0, 0], @isnumeric );
	p.addParameter('LegendLocation', "SouthEast", @(x) true );
	p.addParameter("ShowLegend", true, @islogical);
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
	contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param1), 'ContourLabel', p.Results.ContourLabel1, 'Scheme', p.Results.Scheme, 'Color', p.Results.Color1);
	contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param2), 'ContourLabel', p.Results.ContourLabel2, 'Scheme', p.Results.Scheme, 'Color', p.Results.Color2);
	title(param1 + " & " + param2 + " at " + freq./1e9 + " GHz and iPower = " + iPwr);
	if p.Results.ShowLegend
		legend(p.Results.ContourLabel1, p.Results.ContourLabel2, "Location", p.Results.LegendLocation);
	end
	
	% Assign the a name to appear in the window title.
	f.Name = 'Contour Plot GUI';

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
		contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param1), 'ContourLabel', p.Results.ContourLabel1, 'Scheme', p.Results.Scheme, 'Color', p.Results.Color1);
		contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param2), 'ContourLabel', p.Results.ContourLabel2, 'Scheme', p.Results.Scheme, 'Color', p.Results.Color2);
		title(param1 + " & " + param2 + " at " + freq./1e9 + " GHz and iPower = " + iPwr);
		if p.Results.ShowLegend
			legend(p.Results.ContourLabel1, p.Results.ContourLabel2, "Location", p.Results.LegendLocation);
		end
	end
   
	function pwr_menu_callback(source,eventdata) 
		
		% Determine the selected data set.
		strs = get(source, 'String');
		idx = get(source,'Value');

		iPwr = str2num(strs{idx});
		
		lp_filt = lp_data.get(lp_data.filter("Freq", freq, "props.iPower", iPwr));
		hold off;
		contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param1), 'ContourLabel', p.Results.ContourLabel1, 'Scheme', p.Results.Scheme, 'Color', p.Results.Color1);
		contoursc(lp_filt.gamma(), lp_filt.getArrayFromName(param2), 'ContourLabel', p.Results.ContourLabel2, 'Scheme', p.Results.Scheme, 'Color', p.Results.Color2);
		title(param1 + " & " + param2 + " at " + freq./1e9 + " GHz and iPower = " + iPwr);
		if p.Results.ShowLegend
			legend(p.Results.ContourLabel1, p.Results.ContourLabel2, "Location", p.Results.LegendLocation);
		end
	end

end