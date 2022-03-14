function rfm = ostubf(Z0, thetad, freqs, f0)
	
	% Create matrix class
	rfm = rfmat(Z0, freqs);
	
	% Save properties
	rfm.desc.type = "OPEN_STUB";
	rfm.desc.len_d = thetad;
	rfm.desc.f0 = f0;
	rfm.desc.Z0 = Z0;

	theta = thetad*pi/180;
	
	count = 0;
	for f = freqs
		count = count + 1;
		rfm.abcd(:,:,count) = ostub(Z0, theta*f/f0);
	end
end