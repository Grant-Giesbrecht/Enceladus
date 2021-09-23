function c = getColor(index, varargin)

	expectedPalettes = {'Default','Bold'};

	p = inputParser();
	p.addParameter('Palette', 'Default', @(x) any(validatestring(x, expectedPalettes)));
	p.parse(varargin{:});
	
	c = [];
	
	for idx = index
	
		switch p.Results.Palette
			case 'Default'
				switch mod(idx-1, 7)+1 % Use modulus to ensure within bounds
					case 1
						newcol = [0, 0.4470, 0.7410];
					case 2
						newcol = [.85, .325, .098];
					case 3
						newcol = [.929, .694, .125];
					case 4
						newcol = [.494, .184, .556];
					case 5
						newcol = [.466, .674, .188];
					case 6
						newcol = [.301, .745, .933];
					case 7
						newcol = [.635, .078, .184];
				end
			case 'Bold'
				switch mod(idx-1, 9)+1 % Use modulus to ensure within bounds
					case 1
						newcol = [.1, .1, .8];
					case 2
						newcol = [.9, .1, .1];
					case 3
						newcol = [0, .7, 0];
					case 4
						newcol = [.5, .0, .8];
					case 5
						newcol = [1, .5, .1];
					case 6
						newcol = [.0392, .8667, .9608];
					case 7
						newcol = [.9608, .902, .2588];
					case 8
						newcol = [.0392, .9608, .1608];
					case 9
						newcol = [.9294, .0392, .9608];
				end
		end % End palette switch
		
		c = [c; newcol];
	end
end