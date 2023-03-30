function rfm = pallmat(rfm1, rfm2)

	% Verify frequency match
	if rfm1.freqs ~= rfm2.freqs
		error("Cannot process elements in parallel if frequencies do not match");
		return;
	end
	
	% Calculate parallel Elements
	Apall = (rfm1.abcd(1,1,:).*rfm2.abcd(1,2,:) + rfm2.abcd(1,1,:).*rfm1.abcd(1,2,:))./(rfm1.abcd(1,2,:) + rfm2.abcd(1,2,:));
	Bpall = rfm1.abcd(1, 2, :) .* rfm2.abcd(1, 2, :) ./ ( rfm1.abcd(1, 2, :) + rfm2.abcd(1, 2, :) );
	Cpall = rfm1.abcd(2, 1, :) + rfm2.abcd(2, 1, :) + (rfm2.abcd(2, 2, :) - rfm1.abcd(2, 2, :) ).*( rfm1.abcd(1, 1, :) -  rfm2.abcd(1, 1, :) )./(rfm1.abcd(1, 2, :) + rfm2.abcd(1, 2, :));
	Dpall = (rfm1.abcd(2,2,:).*rfm2.abcd(1,2,:) + rfm2.abcd(2,2,:).*rfm1.abcd(1,2,:))./(rfm1.abcd(1,2,:) + rfm2.abcd(1,2,:));
	
	% Create matrix class
	rfm = rfmat(-1, rfm1.freqs);
	
	% Update RFMat ABCD matrix
	rfm.abcd = zeros(2, 2, numel(rfm1.freqs));
	rfm.abcd(1, 1, :) = Apall;
	rfm.abcd(1, 2, :) = Bpall;
	rfm.abcd(2, 1, :) = Cpall;
	rfm.abcd(2, 2, :) = Dpall;
	
	% Save properties
	rfm.desc.type = "PARALLEL_NET";
	rfm.desc.comp = [rfm1, rfm2];
	
end