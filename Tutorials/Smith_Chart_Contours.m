%******************* Initialize, Read MDF File ****************************

% Create MDF object
mdf = AWRLPmdf;
mdf.debug = false;

% Read MDF file
if ~mdf.load("LP_3053_4x100_DS3.mdf")
	displ("ERROR: ", mdf.msg)
	return;
end

% Print some data from the MDF file
displ(mdf.str());
mdf.showBlock(1);

% Break data out of the blocks into more easily usable form
data = mdf.getLPData();

% Plot all gamma points to make sure data were loaded correctly
figure(1);
hold off;
sc = smithplot(data.gamma(), 'LineStyle', 'none', 'Marker', '+');

%*********************** Generate New Grid ********************************

% Convert gamma points to impedances
ZL = data.z_l();
Pload = data.p_load();

% Compute real and imag. parts
rz = real(ZL);
iz = imag(ZL);

% Set size of grid
nr = 50;
ni = 50;

% Create a meshgrid to cover the scattered data
[rg, ig] = meshgrid(linspace(min(rz), max(rz), nr ), linspace( min(iz), max(iz), ni ));

% Interpolate the measured data to the meshgrid
pg = griddata(rz, iz, Pload, rg, ig);

% Plot interpolated values against measured points
figure(2);
hold off;
mesh(rg, ig, abs(pg));
hold on;
plot3(rz, iz, abs(Pload), '+');
xlabel("Re\{Z\}");
ylabel("Im\{Z\}");
title("Interpolated Grid Data (Impedance Domain)");
zlabel("P_{Load} (dBm?)");

% Create a contour plot
figure(3);
[CM, c] = contour(rg, ig, abs(pg));
grid on;
% set(gca,'Color',[.4, .4, .4])
% set(gca, 'XColor', [.9, .9, .9]);
% set(gca, 'YColor', [.9, .9, .9]);

figure(1);
smithcontour(rg, ig, abs(pg));


























