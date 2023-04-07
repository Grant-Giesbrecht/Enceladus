function sim_fin(hours, sim_nos, total_sims)

	t2 = time2struct(hours(2));
	t1 = time2struct(hours(1));
	
	[dts, Td] = timedelta(t1, t2);
	
	dn = sim_nos(2) - sim_nos(1);
	
	sec_per_sim = dts/dn;
	displ("Seconds per sim: ", sec_per_sim);
	
	n_remaining = total_sims - sim_nos(2);
	sec_rem = n_remaining * sec_per_sim;
	Tr = sec2ts(sec_rem);
	
	[~, t_fin] = tsadd(Tr, t2);
	
	displ("Time remaining: ", Tr.hour, " hours, ", Tr.min, " min, ", Tr.sec, " sec");
	
	displ("Expected Finish: ", t_fin.hour, ":", t_fin.min);
	

end