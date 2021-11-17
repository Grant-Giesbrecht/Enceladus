function [lp, t_read, t_extract] = file2loadpull(filename, varargin)
% FILE2LOADPULL Returns a LoadPull object from an MDF file, only
% regenerating it if required.
%
%	[LP, T_READ, T_EXTRACT] = FILE2LOADPULL(FILENAME) Reads the file
%	specified as filename and returns the load pull object as LP. t_read
%	and t_extract describe the time taken to read the MDF file and extract
%	the LoadPull object from the AWRLPmdf object, respectively. Values of
%	-1 for the times indicate that their operation was unneccesary and
%	skipped.
%
%	[LP, T_READ, T_EXTRACT] = FILE2LOADPULL(FILENAME, ID) Specifying an ID
%	allows the user to indicate the name of objects to look for in the
%	workspace. Allows ID to replace the default value, the filename with
%	the extension removed.

	p = inputParser;
	p.addParameter("ID", [], @(x) isstring(x) || ischar(x));
	p.addParameter("RemoveHarmonics", true, @islogical);
	p.addParameter("LoadMAT", true, @islogical);
	p.addParameter("MATFilename", "", @(x) isstring(x) || ischar(x));
	p.parse(varargin{:});

	silent = false;

	t_read = -1;
	t_extract = -1;
	
	% Check for optional parameters
	if isempty(p.Results.ID)
		cf = char(filename);
		sidx = find(cf == '/' | cf == '\', 1, 'Last');
		if isempty(sidx)
			sidx = 0;
		end
		pidx = find(cf == '.', 1, 'Last');
		ID = cf(sidx+1:pidx-1);
	else
		ID = p.Results.ID;
	end
	if strcmp(p.Results.MATFilename, "")
		[pt, nm, ext] = fileparts(filename);
		MATfn = fullfile(pt, nm+".mat");
	else
		MATfn = p.Results.MATFilename;
	end
	
	% Check if LoadPull object already exists
	load_lp = false;
	try
		lp = evalin('base', strcat('lp_', ID));
	catch
		load_lp = true;
	end
	
	% Return LoadPull object from workspace if present
	if ~load_lp	
		if ~silent
			displ("LoadPull object found. Returning existing object.");
		end
		
		% Save MAT file if specified
		if p.Results.LoadMAT && ~isfile(MATfn)
			file2loadpull_sourcefile_check = filename;
			t0 = tic;
			save(MATfn, 'lp', 'file2loadpull_sourcefile_check');
			t_save = toc(t0);
			if ~silent
				displ("MAT file saved in ", t_save, " sec");
			end
		end
		
		% Exit
		return;
	end
	
	% Determine if a MDF file object exists that matches this file
	load_mdf = false;
	try
		mdf_file = evalin('base', strcat('mdf_', ID));
		if mdf_file.filename ~= filename
			load_mdf = true;
		end
	catch
		load_mdf = true;
	end
	
	% Determine if a MAT file exists that matches this file
	loaded_mat = false;
	overwriteMAT = false;
	if load_mdf && isfile(MATfn) && p.Results.LoadMAT
		
		t0 = tic;
		displ("Reading MAT file '", MATfn, "'.");
		S = load(MATfn);
		t_read = toc(t0);
		
		% Ensure file read successfully
		if exist("S", 'var') && isfield(S, "lp")
		
			if ~silent
				displ("  MAT File Read in ", t_read, " sec");
			end

			% Check source file name if possible
			loaded_mat = true;
			if isfield(S, 'file2loadpull_sourcefile_check')
				if ~strcmpi(strrep(S.file2loadpull_sourcefile_check, "\", "/"), strrep(filename, "\", "/"))
					displ("  Source file verification: FAILED");
					loaded_mat = false;
					overwriteMAT = true;
				else
					displ("  Source file verification: PASSED");
				end
			end

			% Exit now if loaded variable successfully
			if loaded_mat
				displ("Returning LoadPull");
				assignin('base', strcat('lp_', ID), S.lp); % Save LoadPull object
				lp = S.lp;
				return;
			end
		end
	end
	
	% Load MDF file if required
	if load_mdf 

		mdf_file = AWRLPmdf;
		mdf_file.debug = false;

		if ~silent
			displ("Reading MDF File: '", ID, ".mdf'.");
		end
		
		% Read MDF file
		t0 = tic;
		if ~mdf_file.load(filename)
			displ("  ERROR: ", mdf_file.msg)
			return;
		end
		t_read = toc(t0);
		
		% Save MDF file object
		assignin('base', strcat('mdf_', ID), mdf_file);
		
		if ~silent
			displ("  MDF File Read in ", t_read, " sec");
		end
	else
		if ~silent
			displ("MDF object found. Skipping read file.");
		end
	end

	% Get LoadPull from AWRLPmdf object
	displ("Creating LoadPull object.");
	t0 = tic;
	lp = mdf_file.getLoadPull(p.Results.RemoveHarmonics);
	t_extract = toc(t0);
	if ~silent
		displ("  LoadPull created from MDF object in ", t_extract, " sec");
		displ("Returning new LoadPull object.");
	end
	
	% Save MAT file if specified
	if p.Results.LoadMAT && (~isfile(MATfn) || overwriteMAT)
		file2loadpull_sourcefile_check = filename;
		t0 = tic;
		save(MATfn, 'lp', 'file2loadpull_sourcefile_check');
		t_save = toc(t0);
		if ~silent
			displ("MAT file saved in ", t_save, " sec");
		end
	end
	
	% Save LoadPull object
	assignin('base', strcat('lp_', ID), lp);

end