function rfm = abcdf(abcd, freqs)
	
	% Create matrix class
	rfm = rfmat(50, freqs);
	
	% Save properties
	rfm.desc.type = "ABCD_Block";
	rfm.desc.len_d = [];
	rfm.desc.f0 = [];
	rfm.desc.Z0 = [];
	
	count = 0;
	for f = freqs
		count = count + 1;
		rfm.abcd(:,:,count) = abcd;
	end

end