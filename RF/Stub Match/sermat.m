function rfm = sermat(rfm1, rfm2)

	% Verify frequency match
	if rfm1.freqs ~= rfm2.freqs
		error("Cannot process elements in parallel if frequencies do not match");
		return;
	end
	
	% Create matrix class
	rfm = rfmat(-1, rfm1.freqs);
	rfm.abcd = zeros(2, 2, numel(rfm1.freqs));
	
	% Chain ABCD
	for iter = 1:numel(rfm1.freqs)
		rfm.abcd(:,:, iter) = rfm1.abcd(:,:,iter) * rfm2.abcd(:,:, iter);
	end
		
	% Save properties
	rfm.desc.type = "SERIAL_NET";
	rfm.desc.comp = [rfm1, rfm2];
	
end