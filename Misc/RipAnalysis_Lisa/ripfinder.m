function out = ripfinder(x, f, inOpts)
%Finds the location, size of rip(s)

%A rip is a [large, instantaneous, negative] change in F 

%To do refoldings, then swap with -f

opts.filwid = 10; %Filter by this much
opts.winlen = 2e2; %Pts to fit a line to for rip size detection

if nargin > 2
    opts = handleOpts(opts,inOpts);
end

xfil = windowFilter(@mean, f, [], opts.filwid);
ffil = windowFilter(@mean, f, [], opts.filwid);

%Get the force changes. Use filwid-th diff to 
% Use difference between filwid pts in order to ignore filter smoothing [but keep the original time resolution]
df = diff(f,opts.filwid);
[~, mi] = max(-df); %May replace with 'find df larger than a threshold'
mi = mi + opts.filwid/2; %Adjust mi to be the middle of the rip

%Fit a line to pre and post-rip section

%Make sure there's enough room on both sides
indlo = mi - opts.filwid - opts.winlen;
indhi = mi + opts.filwid + opts.winlen;

assert(indlo > 0 && indhi <= length(f), 'Error: Rip is too close to the edge of the data')

indpre = ( mi - opts.filwid - opts.winlen + (0:opts.winlen-1) );
indpos = ( mi + opts.filwid + (0:opts.winlen-1) );

%Fit lines to these sections. To F-X or F-D regions?

%Fit to two lines with slope A and slope B ; or just polyfit between the two














