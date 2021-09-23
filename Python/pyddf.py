from ddf_types import *
from helpers import *
class DDFIO:

	#***************** INITIALIZERS *******************************************#

	def __init__(self, fileIn:str=""):
		""" Initializer that opens a file if provided"""

		self.varsFlat = []
		self.vars1D = []
		self.vars2D = []

		self.header = ""
		self.fileVersion = -1;
		self.error_messages = [];

		self.current_version_str = "1.0"

		#TODO: Open file if specified

	#*********************** ADD VARIABLES ***********************************#

	def add(self, newVar, varName:str, desc:str=""):
		""" Add a variable to the object  """

		newItem = DDFItem(newVar, varName, desc)

		#Check for errors
		if newItem.type == ERR:
			msg = newItem.val
			self.logErr(f"Failed to add variable '{varName}' ({msg})")
			return False

		if self.checkContains(varName):
			self.logErr(f"Failed to add variable '{varName}' (Variable with given name already exists)")
			return False

		if newItem.dimension == FLAT:
			self.varsFlat.append(newItem)
		elif newItem.dimension == M1D:
			self.vars1D.append(newItem)
		elif newItem.dimension == M2D:
			self.vars2D.append(newItem)
		else:
			msg = f"Variable dimension exceeded 2"
			self.logErr(f"Failed to add variable '{varName}' ({msg})")
			return False

		return True

	#TODO: Add way to edit variables

	#************************ ACCESS VARIABLES ********************************#

	def __call__(self, varName:str):
		""" Access a variable in the class """

		if not self.checkContains(varName):
			self.logErr(f"Variable '{varName}' not present.")
			return None

		for x in self.varsFlat:
			if x.name == varName:
				return x
		for x in self.vars1D:
			if x.name == varName:
				return x
		for x in self.vars2D:
			if x.name == varName:
				return x

		self.logErr(f"Variable 'varName' missed! There's a bug in pyddf!")



	#********************** VARIABLE MANAGEMENT ******************************#

	def checkContains(self, varName:str):
		""" Accepts a list of variable names and checks if they're present
		in the list of variables """

		if any(x.name == varName for x in self.varsFlat):
			return True
		if any(x.name == varName for x in self.vars1D):
			return True
		if any(x.name == varName for x in self.vars2D):
			return True

		return False

	def clear(self):
		""" Purges all variables from the object """
		self.varsFlat = []
		self.vars1D = []
		self.vars2D = []

	def numVar(self):
		""" Gets the number of variables currently saved in the object """
		return len(self.varsFlat)+len(self.vars1D)+len(self.vars2D)

	def show(self):

		for v in self.vars1D:
			print(v)

	#*********************** WRITE FILE ***************************************#

	def write(self, filename:str, options:str=""):
		self.save(filename, options)

	def save(self, filename:str, options:str=""):

		dstr = self.swrite(options);

		try:
			with open(filename, "w") as fid:
				fid.write(dstr);
		except IOError as e:
			print(f"Failed to open file '{filename}. ({str(e)})'")

	def swrite(self, options:str=""):

		# Initialize options
		vertical_mode = False
		optimize = False
		decapitate = False
		skip_version = False
		sort_mats = False
		show_descriptions = True

		# Read options
		if "v" in options:
			vertical_mode = True
		if "o" in options:
			optimize = True
		if "d" in options:
			decapitate = True
		if "-" in options:
			skip_version = True
		if "s" in options:
			sort_mats = True
		if "u" in options:
			show_descriptions = False

		# Write version statement
		out = ""
		if not skip_version:
			out = "#VERSION " + self.current_version_str + "\n";

			if not optimize:
				out = out + "\n";

		# Write header statement
		if not decapitate and len(self.header) > 0:
			out = out + "#HEADER\n" + self.header + "\n#HEADER\n"

			if not optimize:
				out = out + "\n"

		# Write flat variables

		for v in self.varsFlat:

			# Get string for value
			valstr = v.getValueString()
			if valstr == "UNREC_TYPE":
				self.logErr("Invalid type in flat variable!")
				return

			# Create variable definition
			out = out + getTypeSymbol(v.dimension, v.type) + " " + v.name + " " + valstr

			# Add description
			if len(v.desc) > 0 and show_descriptions:
				out = out + " ?" + v.desc

			# Carriage return
			out = out + "\n"

		# Sort matrices if required
		if sort_mats or vertical_mode:
			self.sortmatrices()

		################ Horizontal Mode matrices ###

		if not vertical_mode:

			for v in self.vars1D + self.vars2D:

				# Get string for value
				valstr = v.getValueString()
				if valstr == "UNREC_TYPE":
					self.logErr("Invalid type in flat variable!")
					return

				# Create variable definition
				out = out + getTypeSymbol(v.dimension, v.type) + " " + v.name + " " + valstr

				# Add description
				if len(v.desc) > 0 and show_descriptions:
					out = out + " ?" + v.desc

				# Carriage return
				out = out + "\n"
		else:
			self.logErr("Vertical save not implemented!") #TODO: Implement vertical save!

		return out



	def sortMatrices(self):

		self.vars1D.sort(key=len)

		self.vars2D.sort(key=len)

	#*************************** ERROR RECORD ********************************#

	def logErr(self, msg:str):
		""" Add error message """
		self.error_messages.append(msg)

	def err(self):
		""" Get last error message"""
		if len(self.error_messages) > 0:
			return self.error_messages[-1]
		else:
			return "No errors"

	#*************************** HEADER ***************************************#

	def setHeader(self, h:str):
		self.header = h

	def getHeader(self):
		return self.header

	def getVersion(self):
		return self.fileVersion

	#************************ OTHER ******************************************#

	def isValidName(self, name:str):

		# Name is at least 1 character
		if len(name) < 1:
			return False

		# First char is letter
		if not name[0].isalpha():
			return False;

		# All characters are alphanumeric
		if not name.isalnum():
			return False

		return True

	#************************** FILE I/O **************************************#

	def loadDDF_V1(self, fileIn:str, options:str=""):

		with open(fileIn) as file:

			lnum = 0

			while True:
				lnum += 1

				line = file.readline()
				if not line:
					break

				#Remove newline characters
				if line[-1] == '\n':
					line = line[0:-1]

				#Parse words
				words = parseIdx(line, " \t")

				#Skip blank lines
				if len(words) < 1:
					continue

				if words[0].str == "#VERSION": #Version Statement

					#Ensure 2 words present
					if len(words) != 2:
						self.logErr(f"Failed on line {lnum}. Version state requires exactly 2 words")
						return False

					#Read version statement
					try:
						self.fileVersion = float(words[1].str)
					except:
						x = words[1].str
						self.logErr(f"Failed on line {lnum}. Failed to convert version '{x}' to float.")
						return False

				elif words[0].str == "#HEADER":

					self.header = ""; #Clear header
					openedOnLine = lnum

					foundHeader = False

					#Keep reading lines until closing header found
					while True:
						lnum += 1

						line = file.readline()
						if not line:
							break

						#Remove newline characters
						if line[-1] == '\n':
							line = line[0:-1]

						#Parse words
						words = parseIdx(line, " \t")

						if len(words) < 1:
							self.header = self.header + "\n"
							continue

						if words[0].str == "#HEADER":
							foundHeader = True
							break
						else:
							if len(self.header) == 0:
								self.header = line
							else:
								self.header = self.header + "\n" + line

					if not foundHeader:
						self.logErr(f"Failed on line {openedOnLine}, failed to find closing #HEADER statement.")
						return False
				elif words[0].str == '//':
					continue
				elif words[0].str == 'd' or words[0].str == 's' or words[0].str == 'b' or words[0].str == 'm<d>' or words[0].str == 'm<s>' or words[0].str == 'm<b>':

					# Verify at least 3 words are present
					if len(words) < 3:
						self.logErr(f"Failed on line {lnum}. Insufficient number of tokens for inline variable statement.")
						return False;

					# Check that the name is valid
					if (not self.isValidName(words[1].str)):
						badname = words[1].str
						self.logErr(f"Failed on line {lnum}. Invalid variable name '{badname}'.")
						return False;

					# Read value
					optional_features_start = 3
					if words[0].str == 'd' or words[0] == 'b':

						if words[0].str == 'd':
							try:
								val = float(words[2].str)
							except:
								badval = words[2].str
								self.logErr(f"Failed on line {lnum}. Failed to convert value '{badval}' to float.")
								return False
						else:
							if words[2].str.upper() == "TRUE":
								val = True;
							elif words[2].str.upper() == "FALSE":
								val = False;
							else:
								w2 = words[2].str;
								self.logErr(f"Failed on line {lnum}. Unrecognized boolian value '{w2}'.");
								return False

						temp = DDFItem(val, words[1].str)

						optional_features_start = 3;



						#Read optional arguments/features
						allow_semi = True
						in_desc = False
						desc_start = -1;
						desc_end = -1;
						for wd in words[optional_features_start:]:

							if (wd.str == '?' or (len(wd.str) > 0 and wd.str[0] == '?')):
								in_desc = True
								desc_start = wd.idx_end+1;

								temp.desc = line[wd.idx-len(wd.str)-2]
							elif wd.str == '//':
								desc_end = wd.idx-1;
								break #Rest is a comment
							elif not in_desc:
								self.logErr(f"Failed on line {lnum}. Superfluous character after variable declaration ({wd.str}).");
								return False

						# Get description
						if desc_start >= 0:
							if desc_end == -1:
								temp.desc = line[desc_start:]
							else:
								temp.desc = line[desc_start:desc_end]

					self.vars1D.append(temp)





def makeValidName(s):

	s = list(s)

	if len(s) < 1:
		s = "x"

	# For each character
	for idx in range(len(s)):

		# Replace invalid characters with '_'
		if not (s[idx].isalnum() or s[idx] == "_"):
			s[idx] = "_"

	# Check if first character is a number, if so add an 'x' before it
	if s[0].isnumeric():
		s = "x" + s;

	return "".join(s)
