lp = file2loadpull("3053_Sweep_EF_Local_h2.mdf", 'RemoveHarmonics', false);

% Get the 2nd harmonic for 8 GHz run
lp_h2_idx = lp.filter("Freq", 8e9, "props.iPower", 10); 
lp_h2 = lp.get(lp_h2_idx);

figure(1);
hold off;
% surfsc(lp_h2.gamma(), abs(lp_h2.pae()), 'ContourLabel', "PAE (%)");
contoursc(lp_h2.gamma(), abs(lp_h2.pae()), 'ContourLabel', "PAE (%)");
