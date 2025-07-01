* add saveobj() loadobj() functions to LPSweep class. That way they can be
saved in .mat files, thus killing off the need to read AWRLPmdf files
frequently.

* Use the scatterbound() function, but get the locations of the fit points.
Filter them out of a LPsweep and use that to get a sub-sweep with the best
points (which I can then plot on the smith chart)

* Optimize AWRLPmdf getLPSweep() function, it's even slower than reading
from file!

Features to add later:

* LaTeX table generation
* bibliography management?
