function el = TL1el(t)

%TODO: NOte There shouldn't be -t(i)'s here, but thats the only thing that
%gives correct results...

	el = zeros(1,numel(t));

	for i = 1:numel(t)
		if t(i) >= 0
			el(i) = 1./2./pi .* atan(t(i));
		else
			el(i) = 1./2./pi .* (pi + atan(t(i)));
		end	
	end

end