function posttheme(fig_props, lgd)

	ax = fig_props.ax;

	if exist("lgd", "var")
		% Legend Text Color
		lgd.TextColor = fig_props.legend_font_color;

		% Legend Font Size
		dlfs = lgd.FontSize; % Save default legend font size
		lgd.FontSize = 12;

		% Axis text size
		dafs = ax.XLabel.FontSize; % Save default axis font size
		ax.XLabel.FontSize = 14;
		ax.YLabel.FontSize = 14;

		% Title text size
		dtfs = ax.Title.FontSize; % Save default title font size
		ax.Title.FontSize = 16;
		ax.Title.Color = fig_props.title_color;						%TODO: Not neccesary?
	end

end