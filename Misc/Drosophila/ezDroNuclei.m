function out = ezDroNuclei(imghis)
%Finds nuclei from 'histone' channel

%Take a frame from the His movie (in this case, negated mCherry channel) and find circles (nuclei)

%UNFINISHED

%Filter
imf = imgaussfilt(imghis, 5);

%Background correct. Need a sense of nuclei size
imbg = imf - imopen(imf, strel('disk', 10));

%Convert to bw


%Then do bwboundaries

%And do some area/eccentricity filtering

%Or maybe better to do like gauss filter + findpeaks 2d?
% Then get a radius by some method?

