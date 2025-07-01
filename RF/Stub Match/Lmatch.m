function solns = Lmatch(Zin, Zload, Zline, Zstub, freqs, f0, varargin)
	
    % Parse input arguments
	p = inputParser;
    p.addParameter("ZLsim", NaN, @isnumeric); % If ZL for simulated response is not constant at ZL, ZLsim can be provided as an array of ZL values corresponding to each freq
    p.addParameter("ZSsim", NaN, @isnumeric); % If ZS for simulated response is not constant at ZL, ZLsim can be provided as an array of ZS values corresponding to each freq
	p.parse(varargin{:});
    
	% Find target to match
	RL = real(Zload);
	XL = imag(Zload);

	% Calculate t and B
	t = t_TL1_general(RL, XL, Zline, Zin);
	B =  Bstub(RL, XL, Zline, t);

	num_soln = numel(t);
	
	Bsrc = imag(1/Zin);
	
	% Get line lengths
	elec_len_series = TL1el(t)*360;
	elec_len_sstub = TL2el_sstub_general(B, Zstub, Bsrc)*360;
	elec_len_ostub = TL2el_ostub_general(B, Zstub, Bsrc)*360;

	%------------------------ Generate solutions -------------------------
	
	dZ = Zload-Zline;
	port_match = seriesf(dZ, freqs);
	
	% Shorted Stub 1
	line1 = tlinf(Zline, elec_len_series(1), freqs, f0);
	stub1 = sstubf(Zstub, elec_len_sstub(1), freqs, f0);
	net1 = rfnet(stub1, Zin, Zload);
	net1.add(line1);
% 	net1.add(port_match);
	net1.name = "SSTUB No.1";
	net1.ID = 1;
	solns = net1;
	
	if num_soln > 1
		% Shorted Stub 2
		line2 = tlinf(Zline, elec_len_series(2), freqs, f0);
		stub2 = sstubf(Zstub, elec_len_sstub(2), freqs, f0);
		net2 = rfnet(stub2, Zin, Zload);
		net2.add(line2);
	% 	net2.add(port_match);
		net2.name = "SSTUB No.2";
		net2.ID = 2;
		solns(end+1) = net2;
	end
		
	% Open Stub 1
	line3 = tlinf(Zline, elec_len_series(1), freqs, f0);
	stub3 = ostubf(Zstub, elec_len_ostub(1), freqs, f0);
	net3 = rfnet(stub3, Zin, Zload);
	net3.add(line3);
% 	net3.add(port_match);
	net3.name = "OSTUB No.1";
	net3.ID = 3;
	solns(end+1) = net3;
	
	if num_soln > 1
		% Open Stub 2
		line4 = tlinf(Zline, elec_len_series(2), freqs, f0);
		stub4 = ostubf(Zstub, elec_len_ostub(2), freqs, f0);
		net4 = rfnet(stub4, Zin, Zload);
		net4.add(line4);
	% 	net4.add(port_match);
		net4.name = "OSTUB No.2";
		net4.ID = 4;
		solns(end+1) = net4;
    end	
	
    % Distinguish between design and simulation frequency if provided
    if ~isnan(p.Results.ZLsim) % Check ZL
        for s = solns
           s.ZL = p.Results.ZLsim; 
        end
    end
    if ~isnan(p.Results.ZSsim) % Check ZS
        for s = solns
           s.ZS = p.Results.ZSsim; 
        end
    end
	
end