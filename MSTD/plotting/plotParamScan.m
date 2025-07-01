function lgnd = plotParamScan(x, Y, sweepval, ts, te, varargin)

    % Get size of Y
    [rows,~] = size(Y);


    lineStyleOptions = {'-', '--', ':', '-.'};
    scaleOptions = {'linear', 'logx', 'logy', 'logxy'};
    
    % Parse inputs
    p = inputParser;
    p.addParameter('LineStyle', '-', @(x) any(validatestring(char(x),lineStyleOptions)));
    p.addParameter('Colors', {}, @(x) isa(x, 'cell'));
    p.addParameter('Scale', 'linear', @(x) any(validatestring(char(x),scaleOptions)));
    p.addParameter('Clear', true, @islogical);
	p.addParameter('Grid', true', @islogical);
    p.parse(varargin{:});
    
    show_legend = true;
	
	colors = p.Results.Colors;
    
    % Handle optional argument 'sweepval'
    if ~exist('sweepval', 'var')
        sweepval = zeros(1, rows);
		show_legend = false;
    end
    
    % Handle optional argument 'ts'
    if ~exist('ts', 'var')
        ts = "";
    end
    
    % Handle optional argument 'te'
    if ~exist('te', 'var')
        ts = "";
    end
    
    % Verify 'Colors' cell is right size
    if numel(colors) ~= rows
       colors = {}; 
    end
    
    % Get dimensions of data, check match
    if numel(sweepval) ~= rows
        warning("Number of rows in 'Y' must match number of elements in 'sweepvar'.");
       return; 
	end
    
	legend_entries = [];
	
    % Plot each
    for idx = 1:rows
        
        % Turn off hold to clear prior results if requested
        if idx == 1 && p.Results.Clear
           hold off
        end
        
        % Plot data
        if strcmp(p.Results.Scale, 'linear')
            
            if isempty(colors)
                plot(x, Y(idx, :), 'LineStyle', p.Results.LineStyle);
            else
                plot(x, Y(idx, :), 'LineStyle', p.Results.LineStyle, 'Color', colors{idx});
            end
            
        elseif strcmp(p.Scale, 'logx')
            
			if isempty(colors)
                semilogx(x, Y(idx, :), 'LineStyle', p.Results.LineStyle);
			else
                semilogx(x, Y(idx, :), 'LineStyle', p.Results.LineStyle, 'Color', colors{idx});
			end
			
        elseif strcmp(p.Scale, 'logy')
            
			if isempty(colors)
                semilogy(x, Y(idx, :), 'LineStyle', p.Results.LineStyle);
			else
                semilogy(x, Y(idx, :), 'LineStyle', p.Results.LineStyle, 'Color', colors{idx});
			end
			
        elseif strcmp(p.Scale, 'logxy')
            
			if isempty(colors)
                loglog(x, Y(idx, :), 'LineStyle', p.Results.LineStyle);
			else
                loglog(x, Y(idx, :), 'LineStyle', p.Results.LineStyle, 'Color', colors{idx});
			end
			
		end
        
		% Activate hold
		hold on;
		
		% Create legend title
		if show_legend
			legend_entries = addTo(legend_entries, strcat( ts, string(sweepval(idx)), te));
		end
        
	end
	
	% Show legend
	if show_legend
		legend(legend_entries);
	end
    
	% Show Grid
	if p.Results.Grid
		grid on;
	end
	
	% Return legend entries in case user wants to change position
	lgnd = legend_entries;
    
end