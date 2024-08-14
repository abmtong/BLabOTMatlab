function out = prepProtein(seq, nameprefix, lopts)
%Chops a protein into peptides to send to prepREMDfiles
% Input: Sequence (1 char per aa), name (for file naming), lopts (length options: how to chop into peptides)

if nargin < 1
    nameprefix = 'ross'; 
end

if nargin < 3
    naa = 8; %Peptide length
    ovr = 5; %Overlap
    %FSP used 8 length, 5 overlap
else
    naa = lopts(1);
    ovr = lopts(2);
end

aalen = length(seq);
len = ceil( aalen / (naa-ovr) );


%Let's append some spaces to seq so we don't have to deal with edge cases
seq = [seq repmat(' ', 1, naa)];

out = cell(1,len);
for i = 1:len
    %Crop seq
    i0 = (i-1) * (naa-ovr);
    s = seq( i0 + (1:naa) );
    
    %Create name
    nam = sprintf('%s_%02d_%d-%d', nameprefix, i, i0+1, i0+naa);
    
    out{i} = struct('nam', nam, 'seq', s);
end

out = [out{:}];

