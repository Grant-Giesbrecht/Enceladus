classdef rfnet < handle
	properties
		mats
		freqs
		abcd
		name
		ZL
		ZS
		ID % Used to ID different nets when considering multiple
        
        % These parameters are used when ZL and ZS are lists, but the
        % network is designed for a single impedance. The design impedances
        % can be saved here and printed in tables
        ZL_design
        ZS_design
	end
	methods
		function obj = rfnet(rfm, ZS, ZL)
			obj.freqs = rfm.freqs;
			obj.mats = rfm;
			obj.abcd = rfm.abcd;
			obj.name = "RF Network";
			obj.ZS = ZS;
			obj.ZL = ZL;
			obj.ID = -1;
            
            obj.ZS_design = ZS;
            obj.ZL_design = ZL;
		end
		function add(obj, rfn)
			
			% Check freqs match
			if obj.freqs ~= rfn.freqs
				error("Cannot multiply rfmats with dissimilar frequency points.");
			end
			
			% Save object
			obj.mats(end+1) = rfn;

			% Chain ABCD 
			for iter = 1:numel(obj.freqs)
				obj.abcd(:,:, iter) = obj.abcd(:,:,iter) * rfn.abcd(:,:, iter);
			end
			
		end
		
		function G_v_F = G_in(obj)
			
			zmat = abcd2z(obj.abcd);
			Z11 = flatten(zmat(1,1,:));
			Z22 = flatten(zmat(2,2,:));
			Z21 = flatten(zmat(2,1,:));
			Z12 = flatten(zmat(1,2,:));
			
			ZP1 = Z11 - Z12.*Z21./(Z22 + obj.ZL);
			G_v_F = (ZP1-obj.ZS)./(ZP1+obj.ZS);
			
		end
		
		function s_v_f = S_um(obj, X, Y, Z0)
		% Calculate unmatched S-Parameters (ie. gamma)
			
			if ~exist('Z0', 'var')
				Z0 = 50;
			end
			
			smat = abcd2s(obj.abcd, Z0);
			s_v_f = flatten(smat(X, Y, :));
		end
		
		function s_v_f = S(obj, x, y, ZL, ZS, Z0, Zum)
		% Zum = unmatched Z, Z used as termination in S_um to find original
		% unmatched S-parameters.
		% ZL = Termination to use to correctly match output
		% ZS = Characteristic impedance of input port
		% Z0 = characteristic impedance for calculating S_um (likely
		% normalization of smith chart).
		%
		% Assumes reciprocal and lossless network!
			
			if ~exist('Z0', 'var')
				Z0 = 50;
			end
			
			if ~exist('Zum', 'var')
				Zum = 50;
			end

			if ~exist('ZL', 'var')
				ZL = 50;
			end
			
			if ~exist('ZS', 'var')
				ZS = 50;
			end
			
			if (x == 1 && y == 1) || (x == 2 && y == 2)
				G_load = (Zum-ZL)./(Zum+ZL); % Zum and Z0 are both 50 ohms. Z0 is the Z passed to MATLAB's "abcd2s()"
				G_src = (Zum-ZS)./(Zum+ZS); % Zum is what the reflection coefficient is calculated relative to
				
				S11 = obj.S_um(1,1,Z0); % These 'S_um' functions are getting S parameters from the ABCD matrix using MATLAB's 'abcd2s' function. 
				S22 = obj.S_um(2,2,Z0);
% 				S22 = S11;
				S11 = S22;
				S12 = obj.S_um(1,2,Z0);
				S21 = obj.S_um(2,1,Z0);
% 				S12 = S21;
				
				G_load = -1.*G_load; % Adding a negative to the reflection coefficient fixed my results for some cases
				
				sig_L1   = G_src.*S11 + G_load.*S22 + G_src.*G_load.*S21.*S12;
				sig_L2   = G_src.*G_load.*S11.*S22;
				sig_L1_1 = G_load.*S22 + G_src.*G_load.*S21.*S12;
				sig_L1_2 = G_src.*S11;
				
				% This is using "Mason's formula". It should be okay with complex source impedances
				s_v_f = ( S11.*(1-sig_L1_1) + S21.*S12.*G_load.*(1-sig_L1_2) )./( 1-sig_L1+sig_L2 );
				
				% The line below is from Taylor's note. I've commented it out because the above form should be more general
				% NOTE: A negative was present after the 1st S11. I've fixed it by changing it to a +.
% 				s_v_f = obj.S_um(1,1, Z0) + (obj.S_um(2, 1, Z0)).*G_load.*(obj.S_um(2, 1, Z0))./(1-obj.S_um(1,1, Z0).*G_load);
			elseif (x == 2 && y == 1) || (x == 1 && y == 2)
% 				s_v_f = sqrt(1 + obj.S(1,1,ZL).^2);

				S11 = obj.S(1, 1, ZL);

				a = real(S11);
				b = imag(S11);

				c = b./a.*(1 - abs(S11))./sqrt(b.^2./a.^2 + 1);
				d = sqrt( ( 1 - abs(S11) ).^2 - c.^2 );

				s_v_f = c + sqrt(-1).*d;

			end
		end
		
		function z_v_f = Z(obj, X, Y)
			zmat = abcd2z(obj.abcd);
			z_v_f = flatten(zmat(X, Y, :));
		end
		function h = sparam_plot(obj, figNum)
			
			if ~exist('figNum', 'var')
				figNum = 1;
			end
						
			figure(figNum);
% 			subplot(1, 2, 1);
			hold off;
			h=plot(obj.freqs./1e9, lin2dB(abs(obj.S(1, 1))));
			hold on;
			plot(obj.freqs./1e9, lin2dB(abs(obj.S(2, 1))));
			plot(obj.freqs./1e9, lin2dB(abs(obj.S(1, 2))));
			plot(obj.freqs./1e9, lin2dB(abs(obj.S(2, 2))));
			legend('|S_{1,1}|', '|S_{2,1}|', '|S_{1,2}|', '|S_{2,2}|');
			title("S Parameter Magnitudes");
			ylabel("|S| (dB)");
			xlabel("Frequency (GHz)");
			grid on
			xlim([min(obj.freqs)./1e9, max(obj.freqs)./1e9]);
			
			
		end
		function [bw, f_lo, f_hi] = bandwidth(obj, condition, val)
			
			if ~exist('val', 'var')
				val = -20;
			end
			
			if condition == "Absolute"
				% Get S21, S11, and find pass region
				G = lin2dB(abs(obj.G_in()));
% 				PF = (s11 < -20) & (s21 > -.1);
% 				PF = (G < -20) & (s21 > -2);
				PF = (G < val);% & (s21 > -2);
			end
			
			% Get where pass/fail status changes
			deltas = [0, diff(PF)];
			deltas = (deltas ~= 0); % Send all changes to '1'
			
			% Handle 'fencepost' cases
			num_changes = numel(find(deltas));
			if mod(num_changes, 2) == 1 % If odd number of changes, add one change to end
				if (PF(1) && ~PF(end)) % Keep 1st half is end fails
					deltas = [1, deltas];
				elseif (~PF(1) && PF(end)) % Keep 2nd half if end passes
					deltas = [deltas, 1];
				else % Else makes no sense
					warning("The BW function got confused and is probably giving bad values!");
					deltas = [deltas, 1];
				end
			elseif num_changes == 0 && PF(1) % If no changes and first passes, all pass
				f_lo = min(obj.freqs);
				f_hi = max(obj.freqs);
				bw = max(obj.freqs)-min(obj.freqs);
				return;
			elseif num_changes == 0 && ~PF(1) % If no changes and first fails, all fail
				f_lo = NaN;
				f_hi = NaN;
				bw = 0;
				return;
			elseif PF(1) && PF(end) % Else if even number of changes, and 1st and last pass, add delta to first and last
				if deltas(1) == 1
					warning("Oops! BW doesnt handle this case correctly");
				end
				deltas(1) = 1; % Mark 1st index as pass
				deltas = [deltas, 1]; % Mark last as pass
			end
			
			% Get pairs and bandwidths
			idxs = find(deltas);
			pairs = zeros(ceil(num_changes/2), 2);
			BWs = zeros(1, ceil(num_changes/2));
			for c = 1:ceil(num_changes/2)
				pairs(c, 1) = idxs(2*(c-1)+1);
				pairs(c, 2) = idxs(2*(c-1)+2)-1;
				BWs(c) = obj.freqs(pairs(c, 2)) - obj.freqs(pairs(c, 1));
			end
			
			bw = max(BWs);
			idx = find(BWs == bw, 1, 'last');
			f_lo = obj.freqs( pairs(idx, 1) );
			f_hi = obj.freqs( pairs(idx, 2) );
			
			if isempty(bw)
				bw = 0;
				f_lo = NaN;
				f_hi = NaN;
			end
			
		end
		function [A,B,C,D]=breakmat(obj)
			A = obj.abcd(1,1);
			B = obj.abcd(1, 2);
			C = obj.abcd(2, 1);
			D = obj.abcd(2, 2);
		end
		function [out, mt] = str(obj, title, e_r, d)
			
			show_micro = true;
			
			if ~exist('e_r', 'var')
				show_micro = false;
			end
			if ~exist('d', 'var')
				show_micro = false;
			end
			
			if ~exist('title', 'var')
				if obj.ID ~= -1
					title = "Circuit No. " + num2str(obj.ID);
				else
					title = obj.name;
				end
			end
			
			mt = MTable;
			if show_micro
				mt.row(["Index", "Type", "Z0 (ohms)", "f0 (MHz)", "Length (deg)", "L (mm)", "W (mm)"]);
			else
				mt.row(["Index", "Type", "Z0 (ohms)", "f0 (MHz)", "Length (deg)"]);
			end
			
			count = 0;
			if show_micro
				mt.row([num2str(count), "PORT (SRC)", num2str(obj.desc.ZS_design), "N/A", "N/A", "N/A", "N/A"]);
			else
				mt.row([num2str(count), "PORT (SRC)", num2str(obj.desc.ZS_design), "N/A", "N/A"]);
			end
			count = count + 1;
			for m = obj.mats
				count = count + 1;
				if show_micro
					[W, len] = tlin2microstrip(m.desc.Z0, e_r, d, m.desc.len_d, m.desc.f0);
					m.desc.len_mm = len*1e3;
					m.desc.width_mm = W*1e3;
					mt.row([num2str(count), m.desc.type, num2str(m.desc.Z0), num2str(m.desc.f0./1e6), num2str(m.desc.len_d), num2str(m.desc.len_mm), num2str(m.desc.width_mm)]);
				else
					mt.row([num2str(count), m.desc.type, num2str(m.desc.Z0), num2str(m.desc.f0./1e6), num2str(m.desc.len_d)]);
				end
			end
			count = count + 1;
			if show_micro
				mt.row([num2str(count), "PORT (LOAD)", num2str(obj.desc.ZL_design), "N/A", "N/A", "N/A", "N/A"]);
			else
				mt.row([num2str(count), "PORT (LOAD)", num2str(obj.desc.ZL_design), "N/A", "N/A"]);
			end
			
			
			mt.title(title);
			mt.alignc(2, 'l');
			out = mt.str();
			
		end
	end
end























