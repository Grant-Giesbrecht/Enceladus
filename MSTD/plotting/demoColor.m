function demoColor(c, figNum)

	if exist('figNum', 'var')
		try
			close(figNum)
		catch
			%Do nothing
		end
		figure(figNum);
	end
	
	[row,col] = size(c);
	
	% Ensure proper size for color
	if col ~= 3 && col ~= 1
		return
	end
	
	if row == 1
		rectangle('Position',[1,2,5,10],'FaceColor',c)
	else
		for ridx = 1:row
			
			% Set subplot geometry and number
			if mod(row, 3) == 0
				subplot(3, row/3, ridx);
			elseif mod(row, 2) == 0
				subplot(2, row/2, ridx);
			else
				subplot(1, row, ridx);
			end
			
			% Draw color
			rectangle('Position',[1,2,5,10],'FaceColor', c(ridx, :))
			xlim([1, 6]);
			ylim([2, 12]);
			
			if col == 3
				title(strcat("Row ", num2str(ridx), ": [", num2str(c(ridx, 1)), ", ", num2str(c(ridx, 2)), ", ", num2str(c(ridx, 3)), "]" ));
			else
				title(strcat("Row ", num2str(ridx)));
			end
		end
	end
	
	

end