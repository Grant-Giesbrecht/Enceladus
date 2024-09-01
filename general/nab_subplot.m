function nab_subplot(fig_no, subplot_spec, newfig_no)
% NAB_SUBPLOT Takes a subplot out of a multi-plot figure and breaks it 
% into a new standalone window.
%
%	Example: Move subplot(2, 2, 3) from figure 1 to figure 2.
%	nab_subplot(1, [2, 2, 3], 2);
%

	% Get figure handle
	f_old = figure(fig_no);
	
	% Access subplot axis
	h1 = subplot(subplot_spec(1), subplot_spec(2), subplot_spec(3));
	
	% Place in new figure
	f_new = figure(newfig_no);
	set(f_new, 'pos', [616 498 560 420]);
	set(h1, 'pos', [0.1300 0.1100 0.7750 0.8150])
	copyobj(h1, f_new);


end