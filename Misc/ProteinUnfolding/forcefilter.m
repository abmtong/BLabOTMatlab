function out = forcefilter(ext, frc, wid)
%Filter (smooth) to try to get an even noise 
%For filtering varying force contour-time graphs, where F gets lowish

%{
1/noise (i.e., k_DNA) is theoretically about linear from 0 to 10pN (see @XWLCslope), so filter differently by force?
Since we're not truly fitting an HMM, we can filter + smooth, so use this for HMM fitting
Algo: Filter by N, N*2, N*4, etc. pts ; stitch together based on which force it is (maybe dsamp and interp the force?)
%}

%input: data, force, filter width (at >10pN or so)

% Let's filter at wid, wd*2, wid*3 ... wid*5 pts
% And use for pN 0-2, 2-4, 4-6, ... 8+ pN

%...lets use median because noise at low pN is not even. Actually way more expensive than mean
xfc = arrayfun(@(x)windowFilter(@mean, ext, wid*x, 1), (1:5), 'Un', 0);

%...lets assume f is monotonic, slowly varying
ffil = windowFilter(@median, frc, wid*5, 1);
%And use this as the force 

out = zeros(size(ext));

out(             ffil < 2 ) = xfc{5}(             ffil < 2 );
out( ffil >= 2 & ffil < 4 ) = xfc{4}( ffil >= 2 & ffil < 4 );
out( ffil >= 4 & ffil < 6 ) = xfc{3}( ffil >= 4 & ffil < 6 );
out( ffil >= 6 & ffil < 8 ) = xfc{2}( ffil >= 6 & ffil < 8 );
out( ffil >= 8 )            = xfc{1}( ffil >= 8 );
