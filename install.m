cd functions
newpath = pwd;
disp(['Adding to path: >>', newpath, '<<']);
addpath(newpath);
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