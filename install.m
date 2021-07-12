% List of relative directories (relative to install.m's location)
folders = ["general", "electronics", "plotting", "system", "classes", "import_data", "string_manipulation"];

% Find out where 'install.m' is saved
file_path = mfilename('fullpath'); % Get full path to this file
if ismac || isunix
	trim_idx = find(file_path=='/', 1, 'last'); % Find index for trimming to directory
elseif ispc % Handle Windows' weird directory system
	trim_idx = find(file_path=='\', 1, 'last'); % Find index for trimming to directory
else % Else treat same as mac. Different statement in case new logic to be added
	trim_idx = find(file_path=='/', 1, 'last'); % Find index for trimming to directory
end
local_dir = file_path(1:trim_idx-1);

% cd to directory with 'install.m'
cd(local_dir);

% Add each listed subdirectory
first = true;
for fldr = folders
	
	% If not first addition, move back to base directory
	if ~first
		cd ..
	end
	first = false;
	
	% Change to folder
	cd(char(fldr));
	newpath = pwd;
	disp(['Adding to path: >>', newpath, '<<']);
	addpath(newpath);
	

end

% Save path and check for failure
if (savepath == 0)
    disp(' ')
    disp('***************************************************************');
    disp('*              Path was updated successfully                  *'); 
    disp('***************************************************************');
    disp(' ');
    disp('Now upon starting MATLAB the files in this repository will be');
    disp('accessible as functions. If you would like to view your current');
    disp('MATLAB path, typing "path" into the command prompt will display');
    disp('it.');
else
    disp(' ')
    disp('***************************************************************');
    disp('*              ERROR: Failed to update path.                  *'); 
    disp('***************************************************************');
end
cd ..