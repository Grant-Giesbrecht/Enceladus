function [nsec, ts] = tsadd(t1, t2)

	t2s = t2.hour*60*60 + t2.min*60 + t2.sec;
	t1s = t1.hour*60*60 + t1.min*60 + t1.sec;
	
	nsec = t2s + t1s;
	
	ts = sec2ts(nsec);

end