function filenumlines(filename)

if (~ispc) 
	[status, cmdout]= system('wc -l filenameOfInterest.txt');
	if(status~=1)
		scanCell = textscan(cmdout,'%u %s');
		lineCount = scanCell{1}; 
	else
		fprintf(1,'Failed to find line count of %s\n',filenameOfInterest.txt);
		lineCount = -1;
	end
 else
    % For Windows-based systems
    [status, cmdout] = system(string('find /c /v "') + filename + string('" '));
    if(status~=1)
        scanCell = textscan(cmdout,'%s %s %u');
        lineCount = scanCell{3};
        disp(['Found ', num2str(lineCount), ' lines in the file']);
    else
        disp('Unable to determine number of lines in the file');
    end
end


end
