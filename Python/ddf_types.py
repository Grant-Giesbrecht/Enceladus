DOUBLE = 'd'
STRING = 's'
BOOL = 'b'
ERR = 'e'


FLAT = 0
M1D = 1
M2D = 2

class StringIdx():
	def __init__(self, val:str, idx:int, idx_end:int=-1):
		self.str = val
		self.idx = idx
		self.idx_end = idx_end;

	def __str__(self):
		return f"[{self.idx}]\"{self.str}\""

	def __repr__(self):
		return self.__str__()

class DDFItem():

	def __init__(self, value, name:str, desc:str=""):

		#Get depth, type
		td = getType(value)

		self.type = td[1]
		self.dimension = td[0]
		self.val = value
		self.name = name
		self.desc = desc

		#If error occured in interpreting type, add message to value
		if td[1] == ERR:
			self.val = td[0]
			self.dimension = -1

	def __len__(self):

		if self.dimension == FLAT:
			return 1
		elif self.dimension == M1D:
			return len(self.val)
		else:
			sum = 0
			for r in self.val:
				sum += len(r)
			return sum

	def __str__(self):

		max_desc_len = 20

		typesym = getTypeSymbol(self.dimension, self.type)

		descstr = ""
		if len(self.desc) > 0:
			if len(self.desc) > max_desc_len:
				descstr = self.desc[0:max_desc_len-3] + "..."
			else:
				descstr = self.desc
			descstr = f", (\"{descstr}\")"

		return f"<DFFItem({typesym}) {self.name}={self.val}{descstr}>"

	def get1DValueString(self, X):

		if self.type == DOUBLE:
			return str(X) #TODO: Make the formatting of doubles more intelligent
		elif self.type == STRING:
			return "\"" + X + "\""
		elif self.type == BOOL:
			if X:
				return "True"
			else:
				return "False"
		elif self.type == ERR:
			return "UNREC_TYPE"

	def getValueString(self):


		if self.dimension == FLAT:
			return self.get1DValueString(self.val)
		elif self.dimension == M1D:

			outstr = "["

			for v in self.val:

				if len(outstr) > 1:
					outstr = outstr + ", ";

				outstr = outstr + self.get1DValueString(v)

			return outstr + "]"

		elif self.dimension == M2D:

			r = len(self.val)
			c = len(self.val[0])

			outstr = "["

			for row in range(r): # For each row...

				if len(outstr) > 1:
					outstr = outstr + "; "

				rowstr = ""

				for col in range(c): # For each column

					if len(rowstr) > 0:
						rowstr = rowstr + ", ";

					rowstr = rowstr + self.get1DValueString(self.val[row][col])

				outstr = outstr + rowstr

			return outstr + "]"


def getType(value):

	it_val = value

	T = type(value)
	depth = 0
	while (T == list or T == tuple):

		depth += 1
		try:
			it_val = it_val[0]
			T = type(it_val)
		except:
			return ("Empty list provided. Cannot get type." ,ERR)

		if depth > 10:
			return ("Matrix depth exceeded 10. Aborting.", ERR)

	if (T == int or T == float):
		return (depth, DOUBLE)
	elif (T == str):
		return (depth, STRING)
	elif (T == bool):
		return (depth, BOOL)
	else:
		return (f"Unrecognized type {T}.", ERR)

def getTypeSymbol(depth, type):

	if type == DOUBLE:
		base_sym = 'd'
	elif type == BOOL:
		base_sym = 'b'
	elif type == STRING:
		base_sym = 's'
	else:
		return "?"

	if depth == 0:
		return base_sym
	elif depth == 1 or depth == 2:
		return f"m<{base_sym}>"
	else:
		return "?<?>"
