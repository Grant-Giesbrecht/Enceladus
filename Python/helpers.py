from itertools import groupby
from ddf_types import *

# Looks for characters in 'delims' in string 'input'. Supposing the string is to
# be broken up at each character in 'delims', the function returns a generator
# with the start and end+1 indecies of each section.
#
def parseTwoIdx(input:str, delims:str):
	p = 0
	for k, g in groupby(input, lambda x:x in delims):
		q = p + sum(1 for i in g)
		if not k:
			yield (p, q) # or p, q-1 if you are really sure you want that
		p = q

def parseIdx(input:str, delims:str=" ", keep_delims:str=""):

	out = []

	sections = list(parseTwoIdx(input, delims))
	for s in sections:
		out.append(StringIdx(input[s[0]:s[1]], s[0], s[1]))
	return out

def parseIdxKeep(input:str, delims:str=" ", keep_delims:str=""):

	out = []

	sections = list(parseTwoIdx(input, delims))
	last = None
	for s in sections:
		if last is not None:
			out.append(StringIdx(input[last[1]:s[0]], last[1]))
		out.append(StringIdx(input[s[0]:s[1]], s[0]))
		last = s

	return out

# def parseIdx(input:str, delims:str=" ", keep_delims:str=""):
#
# 	for in
