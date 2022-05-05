function [solns, BW_list, f] = stubmatch_internal(ZS, ZL, N, varargin)
% STUBMATCH Shows stub matching network options
%
% Shows all possible stub matching networks to match from impedance ZS to
% ZL with N stubs. Supports command syntax.
%
% See also: mergesolutions

	% Parse input arguments
	p = inputParser;
	p.addParameter("includeLower", true, @islogical);
	p.addParameter("skipPlotting", false, @islogical);
	p.addParameter("f0", 2e9, @isnumeric);
	p.addParameter("freqs", linspace(1e9, 3e9, 101), @isnumeric);
	p.addParameter("BWCutoff", -20, @isnumeric);
	p.addParameter("Zline", 50, @isnumeric);
	p.addParameter("Zstub", 50, @isnumeric);
	p.addParameter("e_r", NaN, @isnumeric); % epsilon rel. for substrate
	p.addParameter("d", NaN, @isnumeric); % Height of substrate in meters
    p.addParameter("ZLsim", NaN, @isnumeric); % If ZL for simulated response is not constant at ZL, ZLsim can be provided as an array of ZL values corresponding to each freq
    p.addParameter("ZSsim", NaN, @isnumeric); % If ZS for simulated response is not constant at ZL, ZLsim can be provided as an array of ZS values corresponding to each freq
	p.parse(varargin{:});

	% Verify, if given as string, convert to number
	if ~isnumeric(ZS)
		ZS = str2num(ZS);
	end
	if ~isnumeric(ZL)
		ZL = str2num(ZL);
	end
	if ~isnumeric(N)
		N = str2num(N);
	end

	Zline = p.Results.Zline;
	Zstub = p.Results.Zstub;
	freqs = p.Results.freqs;
	f0 = p.Results.f0;
	BW_cutoff = p.Results.BWCutoff;

	% Differentiate by Filter Order and compute filter solutions
	if N == 1
		% Find solutions
		solns = Lmatch(ZS, ZL, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);

	elseif N == 2
		ZI1 = sqrt(ZS.*ZL);

		% Find solutions
		solns_1 = Lmatch(ZS, ZI1, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);
		solns_2 = Lmatch(ZI1, ZL, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);

		% Merge sub-solution sets
		solns = mergesolutions(solns_1, solns_2);
	elseif N == 3
		ZI1 = (ZS.^2.*ZL).^(1/3);
		ZI2 = (ZS.*ZL.^2).^(1/3);

		% Find solutions
		solns_1 = Lmatch(ZS, ZI1, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);
		solns_2 = Lmatch(ZI1, ZI2, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);
		solns_3 = Lmatch(ZI2, ZL, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);

		% Merge sub-solution sets
		solns = mergesolutions(solns_1, solns_2);
		solns = mergesolutions(solns, solns_3);

	elseif N == 4
		ZI1 = (ZS.^3.*ZL).^(.25);
		ZI2 = sqrt(ZS.*ZL);
		ZI3 = (ZS.*ZL.^3).^(.25);

		% Find solutions
		solns_1 = Lmatch(ZS, ZI1, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);
		solns_2 = Lmatch(ZI1, ZI2, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);
		solns_3 = Lmatch(ZI2, ZI3, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);
		solns_4 = Lmatch(ZI3, ZL, Zline, Zstub, freqs, f0, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);

		% Merge sub-solution sets
		solns = mergesolutions(solns_1, solns_2);
		solns = mergesolutions(solns, solns_3);
		solns = mergesolutions(solns, solns_4);
	end
	
	% Check if lower-order filters should be included
	if p.Results.includeLower && N > 1
		[lower_solns, ~, ~] = stubmatch_internal(ZS, ZL, N-1, 'includeLower', p.Results.includeLower, 'skipPlotting', true, 'f0', p.Results.f0, 'freqs', p.Results.freqs, 'BWCutoff', p.Results.BWCutoff, 'Zline', p.Results.Zline, 'Zstub', p.Results.Zstub, 'e_r', p.Results.e_r, 'd', p.Results.d, "ZLsim", p.Results.ZLsim, "ZSsim", p.Results.ZSsim);
		solns = [solns, lower_solns];
	end
	
	% Calculate BW and add to list
	BW_list = zeros(1, numel(solns));
	f_los = zeros(1, numel(solns));
	f_his = zeros(1, numel(solns));
	idx = 1;
	for s = solns
		[BW_list(idx), f_los(idx), f_his(idx)] = s.bandwidth("Absolute", BW_cutoff);
		idx = idx + 1;
	end

	% Sort solutions by BW
	[BW_list, I] = sort(BW_list, 'descend');
	solns = solns(I);
	
	% Display options
	if ~p.Results.skipPlotting
		if isnan(p.Results.e_r) || isnan(p.Results.d)
			f = uibandwidth(solns, freqs, 3,3, BW_cutoff);
		else
			f = uibandwidth(solns, freqs, 3,3, BW_cutoff, p.Results.e_r, p.Results.d);
		end
	else
		f = [];
	end
	
end