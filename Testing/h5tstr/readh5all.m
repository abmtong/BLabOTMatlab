function out = readh5all(infp)
%reads a hdf5 file, extracting fields by recursive parsing of the h5info file
%goes into groups until there are no groups remaining,
%  then extracts the Datasets field (or, if missing, the Attributes field)


if nargin<1
    dr = fileparts(mfilename('fullpath'));
    [f, p] = uigetfile([dr '.h5']);
    infp = [p f];
end

% infp = [p f];

out = h5groupread(infp);
end