function [lp, ts_read, ts_extract] = files2loadpull(filelist, varargin)

	% Convert chars to string
	filelist = string(filelist);

	% Initilize list of LoadPulls
	lp = LoadPull;
	ts_read = zeros(1, length(filelist));
	ts_extract = zeros(1, length(filelist));
	
	% Loop over and read all files
	iter = 1;
	for fn = filelist
		
		% Read file
		[nlp, ntr, nte] = file2loadpull(fn);
		
		%Merge with master
		lp.merge(nlp);
		
		% Record times
		ts_read(iter) = ntr;
		ts_extract(iter) = nte;
		
		iter = iter + 1;
	end

end