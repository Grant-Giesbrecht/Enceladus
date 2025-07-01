function nlines = filenumlines(filename)
% FILENUMLINES Get number of lines in a file.
%
% Adapted from MATLAB Answers Forum, User: "Boris". Thanks for the
% fantastic function Boris!
% Source: https://www.mathworks.com/matlabcentral/answers/81137-pre-determining-the-number-of-lines-in-a-text-file

	fid = fopen(filename, 'rt');
	chunksize = 1e6; % read chuncks of 1MB at a time
	numRows = 1;
	while ~feof(fid)
		ch = fread(fid, chunksize, '*uchar');
		if isempty(ch)
			break
		end
		numRows = numRows + sum(ch == sprintf('\n'));
	end
	fclose(fid);
  
	nlines = numRows;
end