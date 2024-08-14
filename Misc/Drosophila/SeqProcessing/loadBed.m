function out = loadBed(infp)
%Load bedGraph file (sequencing read coverage)
% You might (probably?) have a bigWig, convert with bigWigToBedGraph (google it) first

if nargin < 1
    [f, p] = uigetfile('*.bedGraph');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

fid = fopen(infp);

%File is a text file of chr start stop value
% Here chr = chromosome, start-stop is region, value is coverage
tmp = textscan(fid, '%s %d %d %f');
fclose(fid);

%Group by chromosome
chrs = tmp{1};
[uchr, ~, uic] = unique(chrs);

chrmaxlen = 6; %i.e. keep 'chr2L' and 'chrM' but reject 'chrUn_CP007071v1'

len = length(uchr);
j = 0;
for i = 1:len
    %Only do 'regular' chromosomes
    if length(uchr{i}) > chrmaxlen
        continue
    end
    %Grab data
    st = tmp{2}( uic == i );
    en = tmp{3}( uic == i );
    val= tmp{4}( uic == i );
    
    %Check that st(2:end) == end(1:end-1) ?
    
    %Assume st(i+1) = en(i), so index = [st, en(end)]
    ind = [st(:)' en(end)];
    ind = ind + 1; %Change from 0-index to 1-index
    mea = val;
    
    j = j+1;
    out(j).chr = uchr{i}; %#ok<AGROW>
    out(j).tra = ind2tra(ind, mea); %#ok<AGROW>
end
