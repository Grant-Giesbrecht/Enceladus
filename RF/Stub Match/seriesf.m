function rfm = seriesf(Zser, freqs)
% SERIESF Creates the ABCD matrix for an impedance in series

	% Create matrix class
	rfm = rfmat(Zser, freqs);
	
	% Save properties
	rfm.desc.type = "SERIES_ELMNT";
	rfm.desc.len_d = [];
	rfm.desc.f0 = [];
	rfm.desc.Z0 = Zser;
	
	if numel(Zser) == 1
		count = 0;
		for f = freqs
			count = count + 1;
			rfm.abcd(:,:,count) = [1, Zser; 0, 1];
		end
	elseif numel(Zser) == numel(freqs)
		count = 0;
		for f = freqs
			count = count + 1;
			rfm.abcd(:,:,count) = [1, Zser(count); 0, 1];
		end
	end
end