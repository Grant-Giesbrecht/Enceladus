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
	p.parse(varargin{:});

	silent = false;

	t_read = -1;
	t_extract = -1;
	
	% Check for optional parameters
	if isempty(p.Results.ID)
		cf = char(filename);
		sidx = find(cf == '/' | cf == '\', 1, 'Last');
		pidx = find(cf == '.', 1, 'Last');
		ID = cf(sidx+1:pidx-1);
	else
		ID = p.Results.ID;
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
	
% 	if exist(strcat('mdf_', ID), 'var')
% 		
% 		% Load MDF if name does not match
% 		mdf_file = eval(strcat('mdf_', ID));
% 		if mdf_file.filename ~= filename
% 			load_mdf = true;
% 		end
% 		
% 	else % Load MDF if does not exist
% 		load_mdf = true;
% 	end
	
	% Load MDF file if required
	if load_mdf 

		mdf_file = AWRLPmdf;
		mdf_file.debug = false;

		if ~silent
			displ("  Reading MDF File: '", ID, ".mdf'.");
		end
		
		% Read MDF file
		t0 = tic;
		if ~mdf_file.load(filename)
			displ("ERROR: ", mdf_file.msg)
			return;
		end
		t_read = toc(t0);
		
		% Save MDF file object
		assignin('base', strcat('mdf_', ID), mdf_file);
		
		if ~silent
			displ("    MDF File Read in ", t_read, " sec");
		end
	else
		if ~silent
			displ("  MDF object found. Skipping read file.");
		end
	end

	% Get LoadPull from AWRLPmdf object
	displ("  Creating LoadPull object.");
	t0 = tic;
	lp = mdf_file.getLoadPull(p.Results.RemoveHarmonics);
	t_extract = toc(t0);
	if ~silent
		displ("    LoadPull created from MDF object in ", t_extract, " sec");
		displ("Returning new LoadPull object.");
	end
	
	% Save LoadPull object
	assignin('base', strcat('lp_', ID), lp);

end