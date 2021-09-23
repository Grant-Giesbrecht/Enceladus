# DDF File Syntax

_NOTE: This project is still under development and the syntax rules are subject to change_

This file describes the nitty gritty syntax details for version 1.0 DDF files.

Note: When describing syntax, parenthesis will indicate optional components, and dollar signs will indicate parameter names that must be replaced with their actual values. In this document, literal dollar signs will be escaped with a backslash.

## File Elements
Every DDF file consists of these elements:
  * __Version statements:__ Describes file version
  * __Header statements:__ Provides a description of the file contents (ie. the header)
  * __Inline comments:__ Indicated by double forward slashes, everything after the comment identifier is
  removed. This includes in variable descriptions. The only place double forward slashes comment identifiers
  are not recognized as comment identifiers are within string literals, ie. text surrounded by double quotes.
  * __Inline variable statements:__ Declares any type of variable in one line
  * __Vertical blocks:__ Sections of the file where vertical variable statements are allowed
  * __Vertical variable__ statements: Declares a 1D or 2D matrix variable over multiple lines

## Data Types
DDF files support a limited number of data types intended to cover a large number of use cases without using
data structures that are native to one language but may be too specific to have true analogs in most other
languages. For that reason, version 2.0 supports only strings, booleans, doubles, and 1D and 2D matrices of
these types.

__But why tho??__ It might seem unnecessarily austere to limit the data types to 3 fundamental types, and I don't entirely
disagree. However, it is core to the DDF file design philosophy to be highly portable between languages so data
read from DDF files can be manipulated in any language in an intuitive way. Highly structured and nested
storage formats obfuscate the available data and defeat this goal, even if they can store more
data types.


## Version statement:
The first line of every DDF file must be a version statement in the format: `#VERSION $major$.$minor$`.

Ex: `#VERSION 2.0`.

## Header statement:
This element is optional, but must come before any variable statements. It allows the author to add a text description of the file's data. A header statement is started and ended with `#HEADER`. Any content between the lines containing `#HEADER` will be included in the header. Header text can not be on the same line as the `#HEADER` start/end statement.

Ex:
```
#HEADER
This text will be the file's header.
You can use multiple lines if you want.
#HEADER
```

### Inline comments:

This element behaves exactly the same way a C comment does. Start the inline comment with two forward
slashes. Everything else on the line will be ignored. Multi-line comments are not implemented. The only
place double forward slashes comment identifiers are not recognized as comment identifiers are within
string literals, ie. text surrounded by double quotes.

### Inline variable statements:

_TODO: Remove semicolon support?_

__TODO: Fix C++, Python, to remove comments as first step?__

Variable statements are the primary means of storing data in DDF files. Inline variable statements define a single variable on a single line. They follow the basic format of `$type$ $name$ $data$ (;)(?$variable-description$)`. The ending semicolon is optional, as is a variable description. Note that matrices of matrices (eg. `m<m<d>>`) are *not* supported or required. A 2D matrix uses the same declaration as a 1D matrix, however 3D matrices are not supported in version 2.0.

  * ### Data types:
  The available data types in DDF files are double precision floats, strings, booleans, and matrices of any one data type. Type is indicated with a single letter. Matrices accept the data type in angle brackets.

  Ex `m<d>` indicates a matrix (1D or 2D) of doubles.

  * ### Data values:
    * __Booleans:__ The full words `true` and `false`, case in-sensitive.
	* __Floats:__ Accepts any decimal number within double precision range and understands scientific notation indicated with 'e' or 'E'.
	* __Strings:__ Standard C++ strings. Must be enclosed within double quotes. Escape double quotes with a backslash.
	* __Matrices:__ Enclose data elements within square brackets and separate values with comments. Separate rows of a 2D matrix with semicolons. Whitespace between elements is suggested for readability but not required.

Inline variable statement examples:

```
d pi 31.41592535e-1;
s planet "Jupiter" ?Has the best moon
b wantCoffee true
m<d> abcd [14, 7;3, 2]
```

### Vertical blocks:
Vertical blocks indicate a region in which variable statements are vertical rather than inline. Inline variable statements cannot occur inside vertical blocks and vertical variable statements cannot occur outside of vertical blocks. Vertical blocks, similarly to header statements, are enclosed by lines containing a single string, `#VERTICAL`.

__But why tho??__ Vertical blocks are intended to make it easy to incrementally add to a file, for example, if data is being collected slowly over time and will not be written to file all at once. Being able to append to a file, line-by-line, is quicker and easier than going back and inserting new values into inline variables on multiple rows. This can be helpful in microcontrollers where memory is at a
premium or where data is being logged over days or longer.

### Vertical variable statements:
Vertical variable statements let you define matrices vertically instead of horizontally. Before diving into their
syntax rules, here's a simple example to help you visualize the rules:

```
#VERTICAL
m<d> 	m<s>
foo 	bar
?foo's description ?bar's description
10		"what is this"
20  	"is"
30  	"life"
40
#VERTICAL
```

Vertical variable statements follow roughly the same general format as inline variable statements, with a few notable exceptions:
  * As the name implies, the components are arranged vertically
  * Multiple variables' elements can be and typically are present on one line, separated by spaces and/or tabs
  * only matrices are supported
  * Semicolons are not allowed at the end of lines, they can only be used to indicate row breaks in matrices
  * Matrices:
    * Are not surrounded by square brackets
	* Do not use commas to separate elements
	* Do still use semicolons to separate rows in a 2D matrix
  * Descriptions are still optional, but instead of appearing at the end of a line, they must appear below the variable names. Descriptions for multiple variables are separated by question marks. If one variable in the vertical block has a description, all must have descriptions, although they can be left blank by not putting text after the question mark.
  * Descriptions for variables in vertical blocks cannot contain question marks. _TODO: Allow them to be escaped?_
  * Only one vertical variable statement may be present in each vertical block. However, the the
  single variable statement may define multiple variables (as shown in example below). In other words, once one or more
  matrices are declared in a vertical block, the vertical block must be terminated with `#VERTICAL` and a new vertical
  block must be started before additional matrices can be declared vertically.
  * Comments can appear in a vertical variable statement both after a line or on an individual line. _TODO: Is this true?_

#### Matrices of different lengths in same vertical block:
Matrices with different lengths can be stored in the same vertical block, but they must be saved in a specific order. The issue arrives because data elements do not need to be 'aligned' with their variable names, titles, descriptions, etc., instead the DDF file just recognizes whitespace separating elements. This means the format can't recognize a 'gap' for the 2nd matrix if an element is present for the 3rd+ element because it would perceive the 3rd element as the 2nd. The result is the following rules:
  * The matrices in a vertical block must be arranged from longest to shortest.
  * A matrix can't skip an element on one row and resume listing elements later. All elements must be on
  consecutive rows until all data have been listed.

__Examples:__

This example contains multiple problems:
```
//  This contains multiple illegal behaviors:
//	1.  'y' is larger than 'x' and thus needs to be declared left of 'x'. As written,
//		the file will think the value 'True' should belong to 'x' and will cause an
//		error to occur.
//	2.  'a' and 'b' are declared in the same vertical block as 'x' and 'y', but
//		not on the same line.
//	3.  A description is present for 'a' and 'c', but not 'b'. Descriptions in vertical
//		blocks are all or nothing - if any variable has one, every variable in that
//		block must have a description.

#VERTICAL
m<d>    m<b>
x       y
?foo	?bar
0       False
1       False
2       False
        True

m<d>    m<d>    m<d>
a       b       c
?foo            ?bar
10      100     1e3
20      90      2e3
30      80      3e3
#VERTICAL
```

The correct way to delcare these variabes would be:
```
//  Fixed, the above example looks like:
//	1.  Declaring 'y' before 'x' ensures that the matrices appear in order or
//		decreasing length.
//	2.  Creating a second vertical block, 'a' and 'b' can be declared legally on
//		separate line from 'x' and 'y'.
//	3.  Adding a question mark to denote a description for 'b' fixes the all-or-nothing
//		problem. You don't need to put any text after it if you don't want to give
//		it a description.
//
// Note: The nicely aligned columns are not required. Any amount of white space
// is sufficient for separating elements.

#VERTICAL
m<b>    m<d>
y       x
?bar    ?foo
False   0
False   1
False   2
True
#VERTICAL

#VERTICAL
m<d>    m<d>    m<d>
a       b       c
?foo    ?       ?bar
10      100     1e3
20      90      2e3
30      80      3e3
#VERTICAL
```

Syntax format:
  * Line 1: `<type-var-1> <type-var-2> ... <type-var-n>` Declare types.
  * Line 2: `<name-var-1> <name-var-2> ... <name-var-n>` Specify names.
  * Line 3: `(?<desc-var-1> ?<desc-var-2> ... ?<desc-var-n>)` Optionally provide descriptions for each variable.
  * Line 4: `<val1-var-1> <val1-var-2> ... <val1-var-n>` First element
  * Line 5: `<val2-var-1> <val2-var-2> ... <val2-var-n>` Second element
  * ...
  * Line m: `<val-var-1> <valm-var-2> ... <valm-var-n>` Last element

Here's an example vertical block:

    #VERTICAL
	m<d> m<d> m<b> m<s>
	Vin  Vout amp_on notes
	?Input voltage (V) ?Output voltage (V) ?Amplifier state ?Measurement
	1	 .99  false	 ""
	//Comments are still a-okay
	2	 2.01 false  ""
	3    5.87 true   "a = +6dB" //Comments after lines are also fine.
	4    8.1  true   "" //Note the pretty column arrangement is only for the viewer's benefit. To DDF readers, whitespace is whitespace
	#VERTICAL
