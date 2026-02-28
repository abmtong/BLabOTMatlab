function [outrAop, outefpop] = tetNucOpGen(rAopts, efpop, nuc_starts)
%Generates rAopts and ezFactPlot options for tetranucleosomes
% Should be able to work for any placement of nuc now
% nuc_starts is an array of the number of nucleotides from the end of the last repeat
% So for regular single nuc, this is ... 46?
%  For tetra, the template has changed a bit, so nuc_starts is 73, 73+187, ...

if nargin < 3
    nuc_starts = 73 + 187 * [0 1 2 3]; %Tetranucleosome
end

if nargin < 2 || isempty(efpop)
    efpop = struct();
end

%Generate starting positions
nruler = 8*64; %Change if ruler length has changed
pol_footprint = 16;
nuc_starts = nuc_starts + nruler - pol_footprint;

%Delta for start/dyad/end
stdyen = [0 73 146];

%Need to change disp value for rAopts

%And need to change snhop disp and regular disp + shift for others

nnuc = length(nuc_starts);

outrAop = repmat(rAopts, 1, nnuc);
outefpop = repmat(efpop, 1, nnuc);
for i = 1:nnuc
    tmpdisp = nuc_starts(i) + stdyen;
    tmpshift = tmpdisp(1)-1;
    
    outrAop(i).disp = tmpdisp;
    outefpop(i).snhop.disp = tmpdisp;
    outefpop(i).snhop.shift = tmpshift;
    outefpop(i).disp = tmpdisp;
    outefpop(i).shift = tmpshift;
end

%To process the i-th nucleosome, run ezFactPlot( procFranp3( data, outrAop(i) ) , outefpop(i) )