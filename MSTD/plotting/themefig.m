function [f, ax, fig_props] = themefig(figno)

	figure(figno);
	hold off
	cla

	ax = gca;
	f = gcf;

	%% Change Aspect Ratio

	f.Position(3:4) = [750, 420];

	% Here also changing position
	f.Position(1:2) = [87, 570];


	%% Set background color
	background_color = [.1, .1, .17];
	set(ax, 'color', background_color);
	set(f, 'color', background_color);

	%% Set axis color
	axis_color = [.9, .9, .7];
	grid_color = [.9, .9, .7, .5];
	ax.XColor = axis_color;
	ax.XLabel.FontSize = 15;
	ax.YColor = axis_color;
	ax.GridColor = grid_color(1:3);
	ax.GridAlpha = grid_color(4);

	%% Change color order

	darkcolors = [200,   0, 255;...
				  255, 152,   8;...
				   68, 255,   0;...
				  177, 176, 223;...
				  255,  17,   0]./255;
	colororder(ax, darkcolors);


	%% Name-Value pairs

	title_color = [.9, .9, .7, .5];
	line_width = 1.5;


	%% Set Legend properties

	legend_font_color = axis_color;
	legend_bg_color = [.2, .2, .34];

	lgnd = legend(ax);
	set(lgnd, 'Color', legend_bg_color);
	set(lgnd, 'Visible', 'off');
	set(lgnd, 'TextColor', legend_font_color);
	
	fig_props.legend_font_color = legend_font_color;
	fig_props.legend_bg_color = legend_bg_color;
	fig_props.ax = ax;
	fig_props.f = f;
	
	fig_props.title_color = title_color;
	ax.Title.Color = title_color;
	

end