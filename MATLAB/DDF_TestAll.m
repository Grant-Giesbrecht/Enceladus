files = ["../examples/read_test.kv", "../examples/read_test2.kv", "../examples/read_test3.kv"];

kvf = KvFile;
kvf.clear();

for f=files
	
	disp("*******************************************************************************")
	disp(strcat("Testing file '", f ,"'"));
	kvf.readKV1_V2(f)
	disp("Error messages:")
	while true
		if strcmp("No errors",kvf.err()) %Print error messages, break when no more errors
			break;
		end
	end
	disp("Data:");
	kvf.show();
	kvf.clear();
	
end