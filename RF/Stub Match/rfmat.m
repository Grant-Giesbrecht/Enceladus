classdef rfmat < handle
	properties
		abcd
		freqs
		Z0
		desc
	end
	methods
		function obj = rfmat(Z0, freqs)
			obj.abcd = zeros(2, 2, numel(freqs));
			obj.freqs = freqs;
			obj.Z0 = Z0;
			
			% Save properties
			obj.desc.type = "N/A";
			obj.desc.len_d = [];
			obj.desc.f0 = [];
			obj.desc.Z0 = [];
		end
	end
end