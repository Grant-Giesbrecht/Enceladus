function ts = sec2ts(nsec)

	ts.hour = floor(nsec/(60*60));
	rem = mod(nsec, 60*60);
	ts.min = floor(rem/60);
	rem = mod(rem, 60);
	ts.sec = rem;

end