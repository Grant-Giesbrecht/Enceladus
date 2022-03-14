function rfm = termf(Zterm, freqs)
	
	% Create matrix class
	rfm = rfmat(Zterm, freqs);
	
	% Save properties
	rfm.desc.type = "SHUNT_ELMNT";
	rfm.desc.len_d = [];
	rfm.desc.f0 = [];
	rfm.desc.Z0 = Zterm;
	
	if numel(Zterm) == 1
		count = 0;
		for f = freqs
			count = count + 1;
			rfm.abcd(:,:,count) = [1, 0; 1/Zterm, 1];
		end
	elseif numel(Zterm) == numel(freqs)
		count = 0;
		for f = freqs
			count = count + 1;
			rfm.abcd(:,:,count) = [1, 0; 1/Zterm(count), 1];
		end
	end
end