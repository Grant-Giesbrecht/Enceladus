function [h, ix, iy, iz] = surfi1d(X, Y, Z)

	pare_Xs = true;

	% Find unique X values
	xs = unique(round(X, 7));
	
	% Remove X values with missing data (if pare_Xs is enabled)
	if pare_Xs
	
		% Find count for each
		counts = zeros(1, numel(xs));
		for i=1:numel(xs)
			counts(i) = sum(X==xs(i));
		end
		
		% FInd max, eliminate all without max
		mc = max(counts); % Get max
		KI = (counts == mc); % Get indecies of maxes
		xs = xs(KI); % Keep only the values with 'max' count
	
	end
	
	% Get Y values
	ys = unique(round(Y, 7));
	[XM, YM] = meshgrid(ys, xs);
	
	% Interpolate data, without correlating different X values (ie. interp
	% parallel to Y axis)
	ZM = zeros(numel(xs), numel(ys));
	count = 1;
	for x = xs
		I = (X == x); % Find indecies of x-value
		y = Y(I); % Get Y-values for the corresponding x
		z = Z(I); % Get Z-values for the corresponding x
		ZM(count, :) = interp1(y, z, ys);
		
		count = count + 1;
	end
	
	% Make surface plot
	h = surf(YM, XM, ZM);
	
	% Initialize output variables
	ix = xs;
	iy = [];
	iz = [];
	
	% Get largest square without NaN values
	map = ~isnan(ZM);
	[~, numrows] = size(map);
	sr = -1; % Start row
	er = -1; % End row
	last = false; % True if last row was plotable
	for r = 1:numrows
		col = map(:, r); % Get column
		a = all(col); % Check if row is plotable
		if a && ~last % This row matches, prev row did not
			
			% Check if previous region was found
			if er ~= -1
				iy = [iy, ys(sr:er)]; % Add rows to Y values
				niz = ZM(:, sr:er); % Get chunk of Z matrix
				iz = cat(2, iz, niz); % Add to Z output
			end
			
			sr = r;
			er = -1;
% 		elseif a && last % This row matches, and so did prev
% 			er = r;
% 		elseif ~last % This row does not match, and neither did prev
% 			last
		elseif ~a && last % This row does not match, but last row did
			er = r-1;
		end
		
		last = a;
	end
	
	% Check if region was found
	if er ~= -1
		iy = [iy, ys(sr:er)]; % Add rows to Y values
		niz = ZM(:, sr:er); % Get chunk of Z matrix
		iz = cat(2, iz, niz); % Add to Z output
	end
	
end