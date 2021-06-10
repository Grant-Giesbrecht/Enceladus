function userDir = gethomedir
%GETUSERDIR   return the user home directory.
%   USERDIR = GETUSERDIR returns the user home directory using the registry
%   on windows systems and using Java on non windows systems as a string.
%
%	Note: Originally from MATLAB File exchange and modified for this
%	library. Original MATLAB File Exchange citation:
%	Sven Probst (2021). Get user home directory (https://www.mathworks.c...
%	om/matlabcentral/fileexchange/15885-get-user-home-directory), MATLAB...
%	Central File Exchange. Retrieved June 10, 2021.
%
%   Example:
%      getuserdir() returns on windows
%           C:\Documents and Settings\MyName\Eigene Dateien
%

% TODO: Try:
%	if ispc; userdir= getenv('USERPROFILE');
%	else; userdir= getenv('HOME');
%	end



	
	if ispc
		userDir = winqueryreg('HKEY_CURRENT_USER',...
			['Software\Microsoft\Windows\CurrentVersion\' ...
			 'Explorer\Shell Folders'],'Personal');
	else
		userDir = char(java.lang.System.getProperty('user.home'));
	end
	
	% Get comparison index (to trim last 10 characters, but handle shorter
	% string case)
	idx = length(userDir)-9;
	if idx < 1
		idx = 1
	end
	
	% Trim off the word 'Documents' if it 
	if strcmp(userDir(idx:end), '\Documents')
		userDir = userDir(1:idx-1);
	end

end