%{
Readme last edited 06/22/2023
@author Alexander Tong (tonga@berkeley.edu)
Code distributed publicly under the GNU GPL v3 license (see COPYING.m)

This is the Matlab code written by me to be used for processing and analysis of optical tweezers data.
 The code was written with Matlab R2016a with all(?) toolboxes, issues with versioning/toolboxes may arise
  Hopefully, those errors are easy-ish to debug

Processing involves converting raw optical tweezers instrument output (QPD values, trap separations) to force and extension
Analysis involves e.g. calculating velocity, stepfinding, etc.
 These are organized by biological system, e.g. the p29 DNA packaging motor, RNAP, protein folding, etc.

This contains a whole lot of code, most of which is a work-in-progress with less-than-stellar organization and documentation.
If you came here from a publication, there (should be) specific readmes for those, named readme_[publication]_[author].m
Feel free to contact me (info above) if you wish to use it and have any questions.

%}