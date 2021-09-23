from Python.pyddf import *

ddf = DDFIO();
ddf.add(3.14159, "pi")
ddf.add(12.05, "Vin", "Input Voltage (V)")
ddf.add([12.05, 12.03, 11.97], "Vin_t", "Vin logged (V)")
if not ddf.add(None, "This_fails"):
	print(ddf.err())
if not ddf.add([[[1]]], "This_also_fails"):
	print(ddf.err())
if not ddf.add([1], "pi"):
	print(ddf.err())
print(ddf("pi"))
print(ddf("Vin"))
print(ddf("Vin_t"))
ddf.clear()
if not ddf.loadDDF_V1("./examples/read_test.ddf"):
	print(ddf.err())
print("\n")
print(f"Version: {ddf.getVersion()}")
print(f"\"{ddf.getHeader()}\"")
ddf.show()
